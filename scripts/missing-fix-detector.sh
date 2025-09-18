#!/bin/bash
# missing-fix-detector.sh
# Script de détection des corrections manquantes sur les branches/tags
# Détecte quand un bug est présent sur une branche mais sa correction existe ailleurs

BUG_NOTES_REF="bugs"
FIX_NOTES_REF="fixes"

## Lister toutes les corrections marquées
list_fixes() {
    echo -e "${BLUE}🔧 Liste des corrections marquées:${NC}"
    echo "=================================="
    
    local one_year_ago=$(date -d "1 year ago" +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d 2>/dev/null || echo "2023-01-01")
    
    # Utiliser git notes list directement pour les fixes, plus efficace
    git notes --ref=$FIX_NOTES_REF list 2>/dev/null | while read note_obj commit; do
        if [[ -n "$commit" ]]; then
            # Vérifier si le commit est récent (dernière année)
            if git rev-list --since="$one_year_ago" --pretty=format: --abbrev-commit "$commit" >/dev/null 2>&1; then
                fix_info=$(git notes --ref=$FIX_NOTES_REF show "$commit" 2>/dev/null)
                if [[ -n "$fix_info" ]]; then
                    bug_id=$(echo "$fix_info" | cut -d: -f2)
                    bug_commit=$(echo "$fix_info" | cut -d: -f4)
                    commit_short=$(git rev-parse --short "$commit")
                    bug_commit_short=$(git rev-parse --short "$bug_commit")
                    
                    echo -e "${GREEN}Fix ID:${NC} $bug_id"
                    echo -e "${GREEN}Commit:${NC} $commit_short ($commit)"
                    echo -e "${GREEN}Corrige:${NC} $bug_commit_short ($bug_commit)"
                    echo ""
                fi
            fi
        fi
    done
}ichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier l'identité Git avant de créer des notes
check_git_identity() {
    local git_name=$(git config user.name 2>/dev/null)
    local git_email=$(git config user.email 2>/dev/null)
    
    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        echo -e "${RED}❌ Identité Git non configurée${NC}"
        echo -e "${YELLOW}💡 Configurez votre identité avec:${NC}"
        echo -e "   ${BLUE}git config --global user.name \"Votre Nom\"${NC}"
        echo -e "   ${BLUE}git config --global user.email \"votre.email@example.com\"${NC}"
        echo -e "${YELLOW}💡 Ou pour ce repository uniquement (sans --global):${NC}"
        echo -e "   ${BLUE}git config user.name \"Votre Nom\"${NC}"
        echo -e "   ${BLUE}git config user.email \"votre.email@example.com\"${NC}"
        return 1
    fi
    return 0
}

# Trouver le commit original d'un commit cherry-pickée
find_cherry_pick_original() {
    local commit=$1
    local commit_msg=$(git show --format='%B' -s "$commit" 2>/dev/null)
    
    # Chercher le pattern "(cherry picked from commit xxxxxxx)"
    local original_commit=$(echo "$commit_msg" | grep -o "cherry picked from commit [a-f0-9]\{7,40\}" | sed 's/cherry picked from commit //')
    
    if [ -n "$original_commit" ]; then
        echo "$original_commit"
        return 0
    fi
    return 1
}

# Trouver tous les commits cherry-pickés d'un commit original
find_cherry_pick_copies() {
    local original_commit=$1
    local one_year_ago=$(date -d "1 year ago" +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d 2>/dev/null || echo "2023-01-01")
    
    # Chercher dans toutes les branches les commits qui référencent ce commit original (dernière année seulement)
    git log --all --since="$one_year_ago" --grep="cherry picked from commit $original_commit" --format="%H" 2>/dev/null
}

# Propager automatiquement les notes vers les commits cherry-pickés
propagate_to_cherry_picks() {
    local commit=$1
    local ref_type=$2  # "bugs" ou "fixes"
    local note_content=$3
    
    # Trouver tous les cherry-picks de ce commit
    local cherry_picks=$(find_cherry_pick_copies "$commit")
    
    if [ -n "$cherry_picks" ]; then
        echo "$cherry_picks" | while read cherry_commit; do
            if [ -n "$cherry_commit" ]; then
                # Vérifier si une note n'existe pas déjà
                if ! git notes --ref="$ref_type" show "$cherry_commit" >/dev/null 2>&1; then
                    git notes --ref="$ref_type" add -m "$note_content" "$cherry_commit" 2>/dev/null
                    local short_cherry=$(git rev-parse --short "$cherry_commit")
                    local short_original=$(git rev-parse --short "$commit")
                    echo -e "${BLUE}  ↳ Note propagée vers cherry-pick: $short_cherry (depuis $short_original)${NC}"
                fi
            fi
        done
    fi
}

# Obtenir tous les commits liés (original + cherry-picks)
get_related_commits() {
    local commit=$1
    local related_commits="$commit"
    
    # Si c'est un cherry-pick, ajouter le commit original
    local original=$(find_cherry_pick_original "$commit")
    if [ -n "$original" ]; then
        related_commits="$related_commits $original"
    fi
    
    # Ajouter tous les cherry-picks de ce commit
    local cherry_picks=$(find_cherry_pick_copies "$commit")
    if [ -n "$cherry_picks" ]; then
        related_commits="$related_commits $cherry_picks"
    fi
    
    # Si on avait trouvé un original, chercher aussi ses autres cherry-picks
    if [ -n "$original" ]; then
        local original_cherry_picks=$(find_cherry_pick_copies "$original")
        if [ -n "$original_cherry_picks" ]; then
            related_commits="$related_commits $original_cherry_picks"
        fi
    fi
    
    # Retourner la liste unique
    echo "$related_commits" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Propager automatiquement les notes depuis les commits originaux
propagate_from_original() {
    local commit=$1
    local ref_type=$2  # "bugs" ou "fixes"
    
    # Vérifier si ce commit est un cherry-pick
    local original_commit=$(find_cherry_pick_original "$commit")
    
    if [ -n "$original_commit" ]; then
        # Récupérer la note du commit original
        local original_note=$(git notes --ref="$ref_type" show "$original_commit" 2>/dev/null)
        
        if [ -n "$original_note" ]; then
            # Vérifier si une note n'existe pas déjà sur ce commit
            if ! git notes --ref="$ref_type" show "$commit" >/dev/null 2>&1; then
                git notes --ref="$ref_type" add -m "$original_note" "$commit" 2>/dev/null
                local short_cherry=$(git rev-parse --short "$commit")
                local short_original=$(git rev-parse --short "$original_commit")
                echo -e "${BLUE}  ↳ Note héritée depuis original: $short_original → $short_cherry${NC}"
                return 0
            fi
        fi
    fi
    return 1
}

# Marquer un commit comme bug
mark_bug() {
    local bug_commit=$1
    local bug_id=$2
    local description=$3
    
    if [ -z "$bug_commit" ] || [ -z "$bug_id" ] || [ -z "$description" ]; then
        echo -e "${RED}❌ Usage: mark-bug <commit> <bug-id> <description>${NC}"
        exit 1
    fi
    
    # Vérifier l'identité Git avant de créer des notes
    if ! check_git_identity; then
        exit 1
    fi
    
    # Vérifier que le commit existe
    if ! git rev-parse --verify "$bug_commit" >/dev/null 2>&1; then
        echo -e "${RED}❌ Erreur: Le commit $bug_commit n'existe pas${NC}"
        exit 1
    fi
    
    git notes --ref=$BUG_NOTES_REF add -m "BUG:$bug_id:$description" "$bug_commit"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erreur lors du marquage du bug${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Bug $bug_id marqué sur commit $bug_commit${NC}"
    echo -e "  Description: $description"
    
    # Propager automatiquement vers les commits cherry-pickés
    echo -e "${BLUE}🔄 Recherche de commits cherry-pickés...${NC}"
    propagate_to_cherry_picks "$bug_commit" "$BUG_NOTES_REF" "BUG:$bug_id:$description"
}

# Marquer un commit comme correction d'un bug spécifique
mark_fix() {
    local fix_commit=$1
    local bug_id=$2
    local bug_commit=$3
    
    if [ -z "$fix_commit" ] || [ -z "$bug_id" ] || [ -z "$bug_commit" ]; then
        echo -e "${RED}❌ Usage: mark-fix <commit> <bug-id> <bug-commit>${NC}"
        exit 1
    fi
    
    # Vérifier l'identité Git avant de créer des notes
    if ! check_git_identity; then
        exit 1
    fi
    
    # Vérifier que les commits existent
    if ! git rev-parse --verify "$fix_commit" >/dev/null 2>&1; then
        echo -e "${RED}❌ Erreur: Le commit de correction $fix_commit n'existe pas${NC}"
        exit 1
    fi
    
    if ! git rev-parse --verify "$bug_commit" >/dev/null 2>&1; then
        echo -e "${RED}❌ Erreur: Le commit de bug $bug_commit n'existe pas${NC}"
        exit 1
    fi
    
    git notes --ref=$FIX_NOTES_REF add -m "FIX:$bug_id:fixes-commit:$bug_commit" "$fix_commit"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erreur lors du marquage de la correction${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Correction $bug_id marquée sur commit $fix_commit (corrige $bug_commit)${NC}"
    
    # Propager automatiquement vers les commits cherry-pickés
    echo -e "${BLUE}🔄 Recherche de commits cherry-pickés...${NC}"
    propagate_to_cherry_picks "$fix_commit" "$FIX_NOTES_REF" "FIX:$bug_id:fixes-commit:$bug_commit"
}

# Lister tous les bugs marqués (version ultra-rapide)
list_bugs() {
    echo -e "${BLUE}🐛 Liste des bugs à corriger:${NC}"
    echo "========================="
    
    # Version ultra-simple et efficace limitée à la dernière année
    local found_any=false
    local one_year_ago=$(date -d "1 year ago" +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d 2>/dev/null || echo "2023-01-01")
    
    # Utiliser git notes list pour obtenir les commits qui ont des notes, mais vérifier l'âge
    git notes --ref=$BUG_NOTES_REF list 2>/dev/null | while read note_obj commit; do
        if [[ -n "$commit" ]]; then
            # Vérifier si le commit est récent (dernière année)
            if git rev-list --since="$one_year_ago" --pretty=format: --abbrev-commit "$commit" >/dev/null 2>&1; then
                bug_info=$(git notes --ref=$BUG_NOTES_REF show "$commit" 2>/dev/null)
                if [[ -n "$bug_info" ]]; then
                    bug_id=$(echo "$bug_info" | cut -d: -f2)
                    bug_desc=$(echo "$bug_info" | cut -d: -f3-)
                    commit_short=$(git rev-parse --short "$commit" 2>/dev/null)
                    
                    echo -e "${YELLOW}Bug ID:${NC} $bug_id"
                    echo -e "${YELLOW}Commit:${NC} $commit_short"
                    echo -e "${YELLOW}Description:${NC} $bug_desc"
                    echo ""
                fi
            fi
        fi
    done
    
    # Vérifier si des notes existent
    if ! git notes --ref=$BUG_NOTES_REF list >/dev/null 2>&1; then
        echo -e "${YELLOW}💡 Aucun bug marqué trouvé${NC}"
        echo -e "${YELLOW}💡 Utilisez 'gfm bug \"description\"' pour marquer un bug${NC}"
    fi
}

# Lister toutes les corrections marquées
list_fixes() {
    echo -e "${BLUE}🔧 Liste des corrections marquées:${NC}"
    echo "================================="
    
    local one_year_ago=$(date -d "1 year ago" +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d 2>/dev/null || echo "2023-01-01")
    
    # Utiliser git notes list directement pour les fixes, plus efficace
    git notes --ref=$FIX_NOTES_REF list 2>/dev/null | while read note_obj commit; do
        if [[ -n "$commit" ]]; then
            # Vérifier si le commit est récent (dernière année)
            if git rev-list --since="$one_year_ago" --pretty=format: --abbrev-commit "$commit" >/dev/null 2>&1; then
                fix_info=$(git notes --ref=$FIX_NOTES_REF show "$commit" 2>/dev/null)
                if [[ -n "$fix_info" ]]; then
                    bug_id=$(echo "$fix_info" | cut -d: -f2)
                    bug_commit=$(echo "$fix_info" | cut -d: -f4)
                    commit_short=$(git rev-parse --short "$commit")
                    bug_commit_short=$(git rev-parse --short "$bug_commit")
                    
                    echo -e "${GREEN}Fix ID:${NC} $bug_id"
                    echo -e "${GREEN}Commit:${NC} $commit_short ($commit)"
                    echo -e "${GREEN}Corrige:${NC} $bug_commit_short ($bug_commit)"
                    echo ""
                fi
            fi
        fi
    done
}

# Détecter les corrections manquantes sur une branche/tag
detect_missing_fixes() {
    local target_branch=$1
    local block_on_missing=${2:-false}  # true pour bloquer, false pour juste alerter
    
    if [ -z "$target_branch" ]; then
        echo -e "${RED}Usage: detect_missing_fixes <branch-or-tag> [block|alert]${NC}"
        exit 1
    fi
    
    # Vérifier que la branche/tag existe
    if ! git rev-parse --verify "$target_branch" >/dev/null 2>&1; then
        echo -e "${RED}❌ Erreur: La branche/tag $target_branch n'existe pas${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔍 Analyse de $target_branch pour détecter les corrections manquantes (dernière année)...${NC}"
    echo ""
    
    # Date limite - dernière année
    local one_year_ago=$(date -d "1 year ago" +%Y-%m-%d 2>/dev/null || date -v-1y +%Y-%m-%d 2>/dev/null || echo "2023-01-01")
    
    # 0. D'abord, hériter automatiquement les notes des commits originaux vers les cherry-picks
    echo -e "${BLUE}🔄 Héritage automatique des notes depuis les commits originaux...${NC}"
    local target_commits=$(git rev-list --since="$one_year_ago" "$target_branch")
    for commit in $target_commits; do
        # Essayer d'hériter les notes de bugs
        propagate_from_original "$commit" "$BUG_NOTES_REF" >/dev/null 2>&1
        # Essayer d'hériter les notes de fixes
        propagate_from_original "$commit" "$FIX_NOTES_REF" >/dev/null 2>&1
    done
    echo ""
    
    local missing_fixes=0
    local temp_file="/tmp/missing_fixes_$$"
    rm -f "$temp_file"
    
    # 1. Lister tous les commits de la branche cible (dernière année seulement)
    for commit in $target_commits; do
        
        # 2. Vérifier si ce commit a une note de bug
        if git notes --ref=$BUG_NOTES_REF show "$commit" >/dev/null 2>&1; then
            bug_info=$(git notes --ref=$BUG_NOTES_REF show "$commit")
            bug_id=$(echo "$bug_info" | cut -d: -f2)
            bug_desc=$(echo "$bug_info" | cut -d: -f3-)
            commit_short=$(git rev-parse --short "$commit")
            
            echo -e "${YELLOW}🐛 Bug détecté: $bug_id dans commit $commit_short ($bug_desc)${NC}"
            
            # 3. Chercher si une correction existe dans la branche cible
            local fix_in_target=false
            
            # Obtenir tous les commits liés (original + cherry-picks) pour ce bug
            local related_commits=$(get_related_commits "$commit")
            
            for potential_fix in $target_commits; do
                # Vérifier si cette correction référence n'importe lequel des commits liés
                local fix_note=$(git notes --ref=$FIX_NOTES_REF show "$potential_fix" 2>/dev/null)
                if [ -n "$fix_note" ]; then
                    for related_commit in $related_commits; do
                        if echo "$fix_note" | grep -q "FIX:$bug_id:fixes-commit:$related_commit"; then
                            fix_in_target=true
                            fix_short=$(git rev-parse --short "$potential_fix")
                            echo -e "  ${GREEN}✅ Correction trouvée dans $target_branch: commit $fix_short${NC}"
                            break 2  # Sortir des deux boucles
                        fi
                    done
                fi
            done
            
            # 4. Si pas de correction dans target, chercher sur les autres branches
            if [ "$fix_in_target" = false ]; then
                echo -e "  ${YELLOW}⚠️  Aucune correction dans $target_branch, recherche sur les autres branches...${NC}"
                
                # Créer une liste des branches à vérifier
                local branches_to_check="/tmp/branches_$$"
                git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/ | grep -v "^$target_branch$" | grep -v "^origin/$target_branch$" > "$branches_to_check"
                
                local fix_found_elsewhere=false
                
                # Chercher le fix sur toutes les autres branches (dernière année seulement)
                while read -r other_branch; do
                    if [ -n "$other_branch" ]; then
                        # Créer une liste des commits de cette branche (dernière année)
                        local commits_to_check="/tmp/commits_$$"
                        git rev-list --since="$one_year_ago" "$other_branch" 2>/dev/null > "$commits_to_check"
                        
                        # Vérifier chaque commit de cette branche
                        while read -r potential_fix; do
                            if [ -n "$potential_fix" ]; then
                                # Vérifier si cette correction référence n'importe lequel des commits liés
                                local fix_note=$(git notes --ref=$FIX_NOTES_REF show "$potential_fix" 2>/dev/null)
                                if [ -n "$fix_note" ]; then
                                    for related_commit in $related_commits; do
                                        if echo "$fix_note" | grep -q "FIX:$bug_id:fixes-commit:$related_commit"; then
                                            fix_short=$(git rev-parse --short "$potential_fix")
                                            related_short=$(git rev-parse --short "$related_commit")
                                            echo -e "  ${RED}🚨 CORRECTION TROUVÉE sur $other_branch: commit $fix_short${NC}"
                                            echo -e "     ${RED}➜ Corrige commit lié $related_short (bug $bug_id présent dans $target_branch)${NC}"
                                            
                                            # Enregistrer pour le rapport final
                                            echo "$bug_id|$commit|$potential_fix|$other_branch|$bug_desc" >> "$temp_file"
                                            fix_found_elsewhere=true
                                            break 2  # Sortir des deux boucles
                                        fi
                                    done
                                fi
                            fi
                        done < "$commits_to_check"
                        rm -f "$commits_to_check"
                        
                        # Si trouvé, on peut arrêter de chercher
                        if [ "$fix_found_elsewhere" = true ]; then
                            break
                        fi
                    fi
                done < "$branches_to_check"
                rm -f "$branches_to_check"
            fi
        fi
    done
    
    # 5. Générer le rapport final
    if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
        echo ""
        echo -e "${RED}🚨 RAPPORT DES CORRECTIONS MANQUANTES${NC}"
        echo -e "${RED}======================================${NC}"
        
        while IFS='|' read -r bug_id bug_commit fix_commit fix_branch bug_desc; do
            bug_short=$(git rev-parse --short "$bug_commit")
            fix_short=$(git rev-parse --short "$fix_commit")
            
            echo ""
            echo -e "${RED}❌ Bug ID: $bug_id${NC}"
            echo -e "   Description: $bug_desc"
            echo -e "   Bug présent dans $target_branch: $bug_short ($bug_commit)"
            echo -e "   Correction disponible sur $fix_branch: $fix_short ($fix_commit)"
            echo -e "${YELLOW}   ➜ ACTION REQUISE: Cherry-pick $fix_short vers $target_branch${NC}"
            echo ""
            missing_fixes=$((missing_fixes + 1))
        done < "$temp_file"
        
        local total_missing=$(wc -l < "$temp_file")
        echo -e "${RED}📊 Total: $total_missing correction(s) manquante(s)${NC}"
        
        # Bloquer ou alerter selon le paramètre
        if [ "$block_on_missing" = "true" ]; then
            echo -e "${RED}❌ BLOCAGE: Impossible de taguer $target_branch avec des corrections manquantes${NC}"
            rm -f "$temp_file"
            exit 1
        else
            echo -e "${YELLOW}⚠️  ALERTE: Des corrections sont disponibles mais pas appliquées sur $target_branch${NC}"
            rm -f "$temp_file"
            return $total_missing
        fi
    else
        echo -e "${GREEN}✅ Aucune correction manquante détectée sur $target_branch${NC}"
        rm -f "$temp_file"
    fi
}

# Suggérer les commandes de correction
suggest_cherry_picks() {
    local target_branch=$1
    
    if [ -z "$target_branch" ]; then
        echo -e "${RED}Usage: suggest <branch-or-tag>${NC}"
        exit 1
    fi
    
    local temp_file="/tmp/missing_fixes_$$"
    
    # D'abord détecter les corrections manquantes
    detect_missing_fixes "$target_branch" "false"
    
    echo ""
    echo -e "${BLUE}💡 COMMANDES SUGGÉRÉES POUR CORRIGER:${NC}"
    echo -e "${BLUE}=====================================${NC}"
    
    if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
        while IFS='|' read -r bug_id bug_commit fix_commit fix_branch bug_desc; do
            fix_short=$(git rev-parse --short "$fix_commit")
            
            echo -e "${YELLOW}# Pour corriger le bug $bug_id:${NC}"
            echo "git checkout $target_branch"
            echo "git cherry-pick -x $fix_commit"
            echo -e "${YELLOW}# Puis marquer la correction:${NC}"
            echo "./scripts/missing-fix-detector.sh mark-fix \$(git rev-parse HEAD) $bug_id $bug_commit"
            echo ""
        done < "$temp_file"
        
        echo -e "${GREEN}# Une fois toutes les corrections appliquées, vérifier:${NC}"
        echo "./scripts/missing-fix-detector.sh check $target_branch"
    else
        echo -e "${GREEN}✅ Aucune correction à appliquer sur $target_branch${NC}"
    fi
    
    rm -f "$temp_file"
}

# Afficher l'aide
show_help() {
    echo "Script de Détection des Corrections Manquantes"
    echo "=============================================="
    echo ""
    echo "Usage: $0 {mark-bug|mark-fix|check|block|suggest|list-bugs|list-fixes|help}"
    echo ""
    echo "COMMANDES DE MARQUAGE:"
    echo "  mark-bug <commit> <bug-id> <description>     - Marquer un commit comme bug"
    echo "  mark-fix <commit> <bug-id> <bug-commit>      - Marquer un commit comme correction"
    echo ""
    echo "COMMANDES DE VÉRIFICATION:"
    echo "  check <branch-or-tag>                        - Vérifier et alerter (non bloquant)"
    echo "  block <branch-or-tag>                        - Vérifier et bloquer si problème"
    echo "  suggest <branch-or-tag>                      - Proposer les cherry-picks à faire"
    echo ""
    echo "COMMANDES D'INFORMATION:"
    echo "  list-bugs                                     - Lister tous les bugs marqués"
    echo "  list-fixes                                    - Lister toutes les corrections marquées"
    echo "  help                                          - Afficher cette aide"
    echo ""
    echo "EXEMPLES:"
    echo "  # Marquer un bug"
    echo "  $0 mark-bug abc1234 \"BUG-001\" \"Memory leak in module X\""
    echo ""
    echo "  # Marquer une correction"
    echo "  $0 mark-fix def5678 \"BUG-001\" abc1234"
    echo ""
    echo "  # Vérifier une branche"
    echo "  $0 check release/v1.0"
    echo ""
    echo "  # Bloquer si corrections manquantes"
    echo "  $0 block release/v1.0"
    echo ""
    echo "  # Obtenir les commandes pour corriger"
    echo "  $0 suggest release/v1.0"
}

# Menu principal
case "$1" in
    mark-bug)
        mark_bug "$2" "$3" "$4"
        ;;
    mark-fix)
        mark_fix "$2" "$3" "$4"
        ;;
    check)
        # Mode alerte seulement
        detect_missing_fixes "$2" "false"
        ;;
    block)
        # Mode blocage
        detect_missing_fixes "$2" "true"
        ;;
    suggest)
        suggest_cherry_picks "$2"
        ;;
    list-bugs)
        list_bugs
        ;;
    list-fixes)
        list_fixes
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Commande inconnue: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac