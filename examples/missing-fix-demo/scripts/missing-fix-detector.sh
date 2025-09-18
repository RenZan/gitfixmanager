#!/bin/bash
# missing-fix-detector.sh
# Script de détection des corrections manquantes sur les branches/tags
# Détecte quand un bug est présent sur une branche mais sa correction existe ailleurs

BUG_NOTES_REF="bugs"
FIX_NOTES_REF="fixes"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Marquer un commit comme bug
mark_bug() {
    local bug_commit=$1
    local bug_id=$2
    local description=$3
    
    if [ -z "$bug_commit" ] || [ -z "$bug_id" ] || [ -z "$description" ]; then
        echo -e "${RED}❌ Usage: mark-bug <commit> <bug-id> <description>${NC}"
        exit 1
    fi
    
    # Vérifier que le commit existe
    if ! git rev-parse --verify "$bug_commit" >/dev/null 2>&1; then
        echo -e "${RED}❌ Erreur: Le commit $bug_commit n'existe pas${NC}"
        exit 1
    fi
    
    git notes --ref=$BUG_NOTES_REF add -m "BUG:$bug_id:$description" "$bug_commit"
    echo -e "${GREEN}✓ Bug $bug_id marqué sur commit $bug_commit${NC}"
    echo -e "  Description: $description"
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
    echo -e "${GREEN}✓ Correction $bug_id marquée sur commit $fix_commit (corrige $bug_commit)${NC}"
}

# Lister tous les bugs marqués
list_bugs() {
    echo -e "${BLUE}🐛 Liste des bugs marqués:${NC}"
    echo "========================="
    
    local found_bugs=false
    git for-each-ref --format='%(refname:short)' refs/notes/$BUG_NOTES_REF 2>/dev/null | while read note_ref; do
        if [ -n "$note_ref" ]; then
            found_bugs=true
        fi
    done
    
    git rev-list --all | while read commit; do
        if git notes --ref=$BUG_NOTES_REF show "$commit" >/dev/null 2>&1; then
            bug_info=$(git notes --ref=$BUG_NOTES_REF show "$commit")
            bug_id=$(echo "$bug_info" | cut -d: -f2)
            bug_desc=$(echo "$bug_info" | cut -d: -f3-)
            commit_short=$(git rev-parse --short "$commit")
            
            echo -e "${YELLOW}Bug ID:${NC} $bug_id"
            echo -e "${YELLOW}Commit:${NC} $commit_short ($commit)"
            echo -e "${YELLOW}Description:${NC} $bug_desc"
            echo ""
        fi
    done
}

# Lister toutes les corrections marquées
list_fixes() {
    echo -e "${BLUE}🔧 Liste des corrections marquées:${NC}"
    echo "================================="
    
    git rev-list --all | while read commit; do
        if git notes --ref=$FIX_NOTES_REF show "$commit" >/dev/null 2>&1; then
            fix_info=$(git notes --ref=$FIX_NOTES_REF show "$commit")
            bug_id=$(echo "$fix_info" | cut -d: -f2)
            bug_commit=$(echo "$fix_info" | cut -d: -f4)
            commit_short=$(git rev-parse --short "$commit")
            bug_commit_short=$(git rev-parse --short "$bug_commit")
            
            echo -e "${GREEN}Fix ID:${NC} $bug_id"
            echo -e "${GREEN}Commit:${NC} $commit_short ($commit)"
            echo -e "${GREEN}Corrige:${NC} $bug_commit_short ($bug_commit)"
            echo ""
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
    
    echo -e "${BLUE}🔍 Analyse de $target_branch pour détecter les corrections manquantes...${NC}"
    echo ""
    
    local missing_fixes=0
    local temp_file="/tmp/missing_fixes_$$"
    rm -f "$temp_file"
    
    # 1. Lister tous les commits de la branche cible
    git rev-list "$target_branch" | while read commit; do
        
        # 2. Vérifier si ce commit a une note de bug
        if git notes --ref=$BUG_NOTES_REF show "$commit" >/dev/null 2>&1; then
            bug_info=$(git notes --ref=$BUG_NOTES_REF show "$commit")
            bug_id=$(echo "$bug_info" | cut -d: -f2)
            bug_desc=$(echo "$bug_info" | cut -d: -f3-)
            commit_short=$(git rev-parse --short "$commit")
            
            echo -e "${YELLOW}🐛 Bug détecté: $bug_id dans commit $commit_short ($bug_desc)${NC}"
            
            # 3. Chercher si une correction existe dans la branche cible
            local fix_in_target=false
            git rev-list "$target_branch" | while read potential_fix; do
                if git notes --ref=$FIX_NOTES_REF show "$potential_fix" 2>/dev/null | grep -q "FIX:$bug_id:"; then
                    fix_in_target=true
                    fix_short=$(git rev-parse --short "$potential_fix")
                    echo -e "  ${GREEN}✅ Correction trouvée dans $target_branch: commit $fix_short${NC}"
                    break
                fi
            done
            
            # 4. Si pas de correction dans target, chercher sur les autres branches
            if [ "$fix_in_target" = false ]; then
                echo -e "  ${YELLOW}⚠️  Aucune correction dans $target_branch, recherche sur les autres branches...${NC}"
                
                # Chercher le fix sur toutes les autres branches
                local fix_found_elsewhere=""
                
                git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/ | while read other_branch; do
                    # Ignorer la branche cible
                    if [ "$other_branch" != "$target_branch" ] && [ "$other_branch" != "origin/$target_branch" ]; then
                        
                        git rev-list "$other_branch" 2>/dev/null | while read potential_fix; do
                            if git notes --ref=$FIX_NOTES_REF show "$potential_fix" 2>/dev/null | grep -q "FIX:$bug_id:fixes-commit:$commit"; then
                                fix_short=$(git rev-parse --short "$potential_fix")
                                echo -e "  ${RED}🚨 CORRECTION TROUVÉE sur $other_branch: commit $fix_short${NC}"
                                echo -e "     ${RED}➜ Bug $bug_id présent dans $target_branch mais corrigé ailleurs!${NC}"
                                
                                # Enregistrer pour le rapport final
                                echo "$bug_id|$commit|$potential_fix|$other_branch|$bug_desc" >> "$temp_file"
                                break
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