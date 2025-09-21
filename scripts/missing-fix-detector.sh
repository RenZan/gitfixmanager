#!/bin/bash
# missing-fix-detector.sh
# Script de détection des corrections manquantes sur les branches/tags
# Détecte quand un bug est présent sur une branche mais sa correction existe ailleurs

BUG_NOTES_REF="bugs"
FIX_NOTES_REF="fixes"

# Cache pour les hash courts
declare -A SHORT_HASH_CACHE

# Fonction pour obtenir les hash courts
get_short_hash() {
    local commit=$1
    if [[ -z "${SHORT_HASH_CACHE[$commit]}" ]]; then
        SHORT_HASH_CACHE[$commit]=$(git rev-parse --short "$commit" 2>/dev/null || echo "N/A")
    fi
    echo "${SHORT_HASH_CACHE[$commit]}"
}

# Couleurs pour l'affichage
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
    
    # Chercher des patterns alternatifs (Pull Request, etc.)
    # Format: "Cherry picked from !PR_NUMBER" ou "cherry picked from !PR_NUMBER"
    local pr_number=$(echo "$commit_msg" | grep -i "cherry picked from !" | grep -o "![0-9]\+" | sed 's/!//')
    
    if [ -n "$pr_number" ]; then
        # Essayer de trouver le commit original par le message de commit et la description
        local commit_title=$(echo "$commit_msg" | head -1)
        # Chercher dans toutes les branches des commits avec un titre similaire
        local potential_original=$(git log --all --oneline --grep="$pr_number" --format="%H" | head -1)
        
        if [ -n "$potential_original" ] && [ "$potential_original" != "$commit" ]; then
            echo "$potential_original"
            return 0
        fi
    fi
    
    return 1
}

# Trouver tous les commits cherry-pickés d'un commit original
find_cherry_pick_copies() {
    local original_commit=$1
    local results=""
    
    # Méthode 1: Chercher par référence directe au commit
    local direct_refs=$(git log --all --grep="cherry picked from commit $original_commit" --format="%H" 2>/dev/null)
    results="$results $direct_refs"
    
    # Méthode 2: Chercher par titre de commit similaire (pour les PR cherry-picks)
    local original_title=$(git show --format="%s" -s "$original_commit" 2>/dev/null)
    if [ -n "$original_title" ]; then
        # Seulement si le titre est assez spécifique (plus de 20 caractères et non générique)
        if [ ${#original_title} -gt 20 ] && ! echo "$original_title" | grep -qi "^merge\|^update\|^fix\|^add\|^remove"; then
            # Extraire des mots-clés spécifiques et longs (minimum 6 caractères)
            local key_words=$(echo "$original_title" | grep -o "[A-Za-z]\{6,\}" | head -3 | tr '\n' ' ')
            
            if [ -n "$key_words" ]; then
                # Chercher les commits contenant ces mots-clés spécifiques
                for word in $key_words; do
                    local matching_commits=$(git log --all --grep="$word" --format="%H" 2>/dev/null)
                    for commit in $matching_commits; do
                        if [ "$commit" != "$original_commit" ]; then
                            # Vérification très stricte : doit explicitement mentionner cherry-pick
                            local commit_msg=$(git show --format='%B' -s "$commit" 2>/dev/null)
                            if echo "$commit_msg" | grep -qi "cherry.*pick\|picked.*from"; then
                                results="$results $commit"
                            fi
                        fi
                    done
                done
            fi
        fi
    fi
    
    # Méthode 3: Chercher par numéro de PR mentionné dans le message (très strict)
    local original_msg=$(git show --format='%B' -s "$original_commit" 2>/dev/null)
    # Seulement chercher des formats PR explicites et spécifiques
    local pr_numbers=$(echo "$original_msg" | grep -o "PR[ #][0-9]\{3,\}" | grep -o "[0-9]\{3,\}" | head -2)
    for pr in $pr_numbers; do
        if [ -n "$pr" ] && [ ${#pr} -ge 3 ]; then
            # Recherche très stricte : doit mentionner explicitement PR + numéro
            local pr_commits=$(git log --all --grep="PR[ #]*$pr\b\|#$pr\b" --format="%H" 2>/dev/null)
            for commit in $pr_commits; do
                if [ "$commit" != "$original_commit" ]; then
                    # Double vérification : le commit doit explicitement mentionner cherry-pick OU PR
                    local commit_msg=$(git show --format='%B' -s "$commit" 2>/dev/null)
                    if echo "$commit_msg" | grep -qi "cherry.*pick\|picked.*from\|PR[ #]*$pr"; then
                        results="$results $commit"
                    fi
                fi
            done
        fi
    done
    
    # Méthode 4: NOUVEAU - Chercher par patch-id (contenu identique) pour cherry-picks sans -x
    # OPTIMISÉ: Recherche drastiquement limitée pour éviter les faux positifs
    local original_patch_id=$(git show "$original_commit" 2>/dev/null | git patch-id --stable 2>/dev/null | cut -d' ' -f1)
    if [ -n "$original_patch_id" ]; then
        local original_title=$(git show --format="%s" -s "$original_commit" 2>/dev/null)
        
        # LIMITATION CONTRÔLÉE: 20 commits max mais sur 1 an pour plus de couverture
        local all_commits=$(git log --all --format="%H" --since="1 year ago" 2>/dev/null | head -20)
        for commit in $all_commits; do
            if [ "$commit" != "$original_commit" ]; then
                local patch_id=$(git show "$commit" 2>/dev/null | git patch-id --stable 2>/dev/null | cut -d' ' -f1)
                if [ -n "$patch_id" ] && [ "$patch_id" = "$original_patch_id" ]; then
                    # Validation titre permissive: au moins un mot de 4+ caractères en commun
                    local cand_title=$(git show --format="%s" -s "$commit" 2>/dev/null)
                    
                    if [ -n "$original_title" ] && [ -n "$cand_title" ]; then
                        # Extraire les mots significatifs (>3 caractères) 
                        local orig_words=$(echo "$original_title" | grep -o '[A-Za-z]\{4,\}' | sort -u)
                        local cand_words=$(echo "$cand_title" | grep -o '[A-Za-z]\{4,\}' | sort -u)
                        
                        # Si au moins UN mot en commun, accepter
                        local common_words=$(comm -12 <(echo "$orig_words") <(echo "$cand_words") | wc -l)
                        if [ "$common_words" -gt 0 ]; then
                            results="$results $commit"
                        fi
                    else
                        # Si pas de titre, accepter (cas edge)
                        results="$results $commit"
                    fi
                fi
            fi
        done
    fi
    
    # Dédupliquer, nettoyer et LIMITER pour éviter l'héritage massif
    local clean_results=$(echo "$results" | tr ' ' '\n' | grep -v "^$" | grep -v "^$original_commit$" | sort -u)
    local result_count=$(echo "$clean_results" | wc -l)
    
    # SÉCURITÉ: Si plus de 5 résultats, c'est suspect - ne retourner que les 3 premiers
    if [ "$result_count" -gt 5 ]; then
        echo "🚨 ALERTE: $result_count cherry-picks détectés pour $original_commit - Limitation à 3" >&2
        echo "$clean_results" | head -3 | tr '\n' ' '
    else
        echo "$clean_results" | tr '\n' ' '
    fi
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

# Scanner tous les commits pour détecter les cherry-picks non hérités
scan_and_inherit_cherry_picks() {
    local ref_type=$1  # "bugs" ou "fixes"
    local branch_filter=${2:-"--all"}  # Par défaut toutes les branches
    
    echo -e "${BLUE}🔄 Scan automatique des cherry-picks pour héritage...${NC}"
    
    # Obtenir tous les commits avec des notes
    local commits_with_notes=$(git notes --ref="$ref_type" list 2>/dev/null | cut -d' ' -f2)
    
    if [ -z "$commits_with_notes" ]; then
        return 0
    fi
    
    local inherited_count=0
    
    # Pour chaque commit avec une note, chercher ses cherry-picks
    for commit_with_note in $commits_with_notes; do
        local note_content=$(git notes --ref="$ref_type" show "$commit_with_note" 2>/dev/null)
        
        if [ -n "$note_content" ]; then
            # Chercher tous les cherry-picks de ce commit avec notre fonction améliorée
            local cherry_picks=$(find_cherry_pick_copies "$commit_with_note")
            
            # Traiter chaque cherry-pick trouvé
            for cherry_commit in $cherry_picks; do
                if [ -n "$cherry_commit" ] && [ "$cherry_commit" != "$commit_with_note" ]; then
                    # Vérifier si une note n'existe pas déjà
                    if ! git notes --ref="$ref_type" show "$cherry_commit" >/dev/null 2>&1; then
                        git notes --ref="$ref_type" add -m "$note_content" "$cherry_commit" 2>/dev/null
                        if [ $? -eq 0 ]; then
                            local short_cherry=$(git rev-parse --short "$cherry_commit" 2>/dev/null || echo "N/A")
                            local short_original=$(git rev-parse --short "$commit_with_note" 2>/dev/null || echo "N/A")
                            echo -e "${GREEN}  ✓ Note héritée: $short_original → $short_cherry${NC}"
                            inherited_count=$((inherited_count + 1))
                        fi
                    fi
                fi
            done
        fi
    done
    
    if [ $inherited_count -gt 0 ]; then
        echo -e "${GREEN}📝 $inherited_count note(s) héritée(s) automatiquement${NC}"
    fi
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
    
    # Propager automatiquement vers les commits cherry-pickés (avec et sans -x)
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
    
    # Propager automatiquement vers les commits cherry-pickés (avec et sans -x)
    echo -e "${BLUE}🔄 Recherche de commits cherry-pickés...${NC}"
    propagate_to_cherry_picks "$fix_commit" "$FIX_NOTES_REF" "FIX:$bug_id:fixes-commit:$bug_commit"
}

# Lister tous les bugs marqués
list_bugs() {
    echo -e "${BLUE}🐛 Liste des bugs à corriger (toutes branches):${NC}"
    echo "========================="
    
    local found_any=false
    
    # Utiliser git notes list pour obtenir tous les commits qui ont des notes de bugs (toutes branches)
    git notes --ref=$BUG_NOTES_REF list 2>/dev/null | while read note_obj commit; do
        if [[ -n "$commit" ]]; then
            bug_info=$(git notes --ref=$BUG_NOTES_REF show "$commit" 2>/dev/null)
            if [[ -n "$bug_info" ]]; then
                bug_id=$(echo "$bug_info" | cut -d: -f2)
                bug_desc=$(echo "$bug_info" | cut -d: -f3-)
                commit_short=$(get_short_hash "$commit")
                found_any=true
                
                echo -e "${YELLOW}Bug ID:${NC} $bug_id"
                echo -e "${YELLOW}Commit:${NC} $commit_short"
                echo -e "${YELLOW}Description:${NC} $bug_desc"
                echo ""
            fi
        fi
    done
    
    # Vérifier si des notes existent
    if ! git notes --ref=$BUG_NOTES_REF list >/dev/null 2>&1; then
        echo -e "${YELLOW}💡 Aucun bug marqué trouvé${NC}"
        echo -e "${YELLOW}💡 Utilisez 'gfm bug \"description\"' pour marquer un bug${NC}"
    fi
}

# Lister seulement les bugs de la branche courante
list_bugs_current_branch() {
    local target_branch="${1:-HEAD}"
    echo -e "${BLUE}🐛 Liste des bugs dans la branche courante:${NC}"
    echo "========================="
    
    local found_any=false
    
    # Utiliser git notes list puis filtrer par la branche
    git notes --ref=$BUG_NOTES_REF list 2>/dev/null | while read note_obj commit; do
        if [[ -n "$commit" ]]; then
            # Vérifier si ce commit est dans la branche cible
            if git merge-base --is-ancestor "$commit" "$target_branch" 2>/dev/null; then
                bug_info=$(git notes --ref=$BUG_NOTES_REF show "$commit" 2>/dev/null)
                if [[ -n "$bug_info" ]]; then
                    bug_id=$(echo "$bug_info" | cut -d: -f2)
                    bug_desc=$(echo "$bug_info" | cut -d: -f3-)
                    commit_short=$(get_short_hash "$commit")
                    found_any=true
                    
                    echo -e "${YELLOW}Bug ID:${NC} $bug_id"
                    echo -e "${YELLOW}Commit:${NC} $commit_short"
                    echo -e "${YELLOW}Description:${NC} $bug_desc"
                    echo ""
                fi
            fi
        fi
    done
    
    # Vérifier si des bugs ont été trouvés
    if ! git notes --ref=$BUG_NOTES_REF list >/dev/null 2>&1; then
        echo -e "${YELLOW}💡 Aucun bug marqué trouvé${NC}"
    fi
}

# Lister toutes les corrections marquées
list_fixes() {
    echo -e "${BLUE}🔧 Liste des corrections marquées (toutes branches):${NC}"
    echo "================================="
    
    # Utiliser git notes list pour les fixes
    git notes --ref=$FIX_NOTES_REF list 2>/dev/null | while read note_obj commit; do
        if [[ -n "$commit" ]]; then
            fix_info=$(git notes --ref=$FIX_NOTES_REF show "$commit" 2>/dev/null)
            if [[ -n "$fix_info" ]]; then
                bug_id=$(echo "$fix_info" | cut -d: -f2)
                bug_commit=$(echo "$fix_info" | cut -d: -f4)
                commit_short=$(get_short_hash "$commit")
                bug_commit_short=$(get_short_hash "$bug_commit")
                
                echo -e "${GREEN}Fix ID:${NC} $bug_id"
                echo -e "${GREEN}Commit:${NC} $commit_short ($commit)"
                echo -e "${GREEN}Corrige:${NC} $bug_commit_short ($bug_commit)"
                echo ""
            fi
        fi
    done
    
    # Vérifier si des notes existent
    if ! git notes --ref=$FIX_NOTES_REF list >/dev/null 2>&1; then
        echo -e "${YELLOW}💡 Aucune correction marquée trouvée${NC}"
        echo -e "${YELLOW}💡 Utilisez 'gfm fix BUG-ID' pour marquer une correction${NC}"
    fi
}

# Fonction pour identifier précisément la branche contenant un commit
get_branch_containing_commit() {
    local commit="$1"
    
    # Méthode simple et efficace: prendre la première branche qui contient le commit
    local branch=$(git branch --contains "$commit" 2>/dev/null | head -1 | sed 's/^[[:space:]\*]*//')
    
    # Si c'est vide, essayer les branches distantes
    if [ -z "$branch" ]; then
        branch=$(git branch -r --contains "$commit" 2>/dev/null | head -1 | sed 's/^[[:space:]]*//' | sed 's/origin\///')
    fi
    
    # Nettoyer et retourner
    if [ -n "$branch" ] && [ "$branch" != "HEAD" ] && [ "$branch" != "(HEAD" ]; then
        echo "$branch"
    else
        echo "branche-inconnue"
    fi
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
    
    echo -e "${BLUE}🔍 Analyse de $target_branch pour détecter les corrections manquantes...${NC}"
    echo ""
    
    # Étape 1: Récupérer tous les commits avec bugs et fixes en une seule fois
    local bug_commits=$(git notes --ref=$BUG_NOTES_REF list 2>/dev/null | cut -d' ' -f2)
    local fix_commits=$(git notes --ref=$FIX_NOTES_REF list 2>/dev/null | cut -d' ' -f2)
    
    # OPTIMISATION: Ne scanner pour les cherry-picks que s'il y a des fixes existants
    if [ -n "$fix_commits" ]; then
        echo -e "${BLUE}🔄 Héritage automatique des notes depuis les commits originaux...${NC}"
        
        # NOUVEAU: Scanner activement pour hériter les notes des cherry-picks
        scan_and_inherit_cherry_picks "$BUG_NOTES_REF" "$target_branch"
        scan_and_inherit_cherry_picks "$FIX_NOTES_REF" "$target_branch"
        
        # Étape 2: Vérification avec git branch --contains
        # au lieu de créer un fichier temporaire
        
        for commit in $bug_commits; do
            # Essayer d'hériter les notes de bugs
            propagate_from_original "$commit" "$BUG_NOTES_REF" >/dev/null 2>&1
            # Essayer d'hériter les notes de fixes
            propagate_from_original "$commit" "$FIX_NOTES_REF" >/dev/null 2>&1
        done
        
        # Recharger les listes après héritage car de nouvelles notes ont pu être ajoutées
        bug_commits=$(git notes --ref=$BUG_NOTES_REF list 2>/dev/null | cut -d' ' -f2)
        fix_commits=$(git notes --ref=$FIX_NOTES_REF list 2>/dev/null | cut -d' ' -f2)
    else
        echo -e "${YELLOW}ℹ️  Aucune note de correction trouvée, scan de cherry-picks ignoré${NC}"
    fi
    echo ""
    
    local missing_fixes=0
    local temp_file="/tmp/missing_fixes_$$"
    rm -f "$temp_file"
    
    # Analyser seulement les bugs présents dans target_branch
    for commit in $bug_commits; do
        # Vérifier si ce commit de bug est dans la branche cible
        if ! git merge-base --is-ancestor "$commit" "$target_branch" 2>/dev/null; then
            continue  # Skip si pas dans cette branche
        fi
        
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
            
            # Vérifier directement si fix est dans target_branch
            for potential_fix in $fix_commits; do
                # Vérification: ce fix est-il dans target_branch ?
                if git merge-base --is-ancestor "$potential_fix" "$target_branch" 2>/dev/null; then
                    # Vérifier si cette correction référence n'importe lequel des commits liés
                    local fix_note=$(git notes --ref=$FIX_NOTES_REF show "$potential_fix" 2>/dev/null)
                    if [ -n "$fix_note" ]; then
                        for related_commit in $related_commits; do
                            if echo "$fix_note" | grep -q "FIX:$bug_id:fixes-commit:$related_commit"; then
                                fix_in_target=true
                                fix_short=$(get_short_hash "$potential_fix")
                                echo -e "  ${GREEN}✅ Correction trouvée dans $target_branch: commit $fix_short${NC}"
                                break 2  # Sortir des deux boucles
                            fi
                        done
                    fi
                fi
            done
            
            # 4. Si pas de correction dans target, chercher via git notes list
            if [ "$fix_in_target" = false ]; then
                echo -e "  ${YELLOW}⚠️  Aucune correction dans $target_branch, recherche via git notes list...${NC}"
                
                local fix_found_elsewhere=false
                
                # Analyser directement tous les commits avec corrections
                # via git notes list, puis vérifier s'ils corrigent notre bug ET ne sont pas dans target_branch
                for potential_fix in $fix_commits; do
                    # Vérifier si cette correction référence notre bug
                    local fix_note=$(git notes --ref=$FIX_NOTES_REF show "$potential_fix" 2>/dev/null)
                    if [ -n "$fix_note" ]; then
                        for related_commit in $related_commits; do
                            if echo "$fix_note" | grep -q "FIX:$bug_id:fixes-commit:$related_commit"; then
                                # CLEF: vérifier que ce fix n'est PAS déjà dans target_branch
                                if ! git merge-base --is-ancestor "$potential_fix" "$target_branch" 2>/dev/null; then
                                    fix_short=$(get_short_hash "$potential_fix")
                                    related_short=$(get_short_hash "$related_commit")
                                    
                                    # Identification DIRECTE de la branche contenant le correctif
                                    local fix_location=$(git branch --contains "$potential_fix" 2>/dev/null | head -1 | sed 's/^[[:space:]\*]*//')
                                    
                                    # Si vide, essayer les branches distantes
                                    if [ -z "$fix_location" ]; then
                                        fix_location=$(git branch -r --contains "$potential_fix" 2>/dev/null | head -1 | sed 's/^[[:space:]]*//' | sed 's/origin\///')
                                    fi
                                    
                                    # Si toujours vide, utiliser fallback
                                    if [ -z "$fix_location" ] || [ "$fix_location" = "HEAD" ]; then
                                        fix_location="autres branches"
                                    fi
                                    
                                    echo -e "  ${RED}🚨 CORRECTION TROUVÉE sur $fix_location: commit $fix_short${NC}"
                                    echo -e "     ${RED}➜ Corrige commit lié $related_short (bug $bug_id présent dans $target_branch)${NC}"
                                    
                                    # Enregistrer pour le rapport final
                                    echo "$bug_id|$commit|$potential_fix|$fix_location|$bug_desc" >> "$temp_file"
                                    fix_found_elsewhere=true
                                    break 2  # Correction trouvée, pas besoin de chercher plus
                                fi
                            fi
                        done
                    fi
                done
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
    fi
    
    # Nettoyage des fichiers temporaires
    rm -f "$temp_file"
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
    echo "Usage: $0 {mark-bug|mark-fix|check|block|suggest|list-bugs|list-bugs-current|list-fixes|help}"
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
    echo "  list-bugs                                     - Lister tous les bugs marqués (toutes branches)"
    echo "  list-bugs-current [branch]                   - Lister les bugs de la branche courante seulement"
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
    list-bugs-current)
        list_bugs_current_branch "$2"
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