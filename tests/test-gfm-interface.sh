#!/bin/bash

# Script de test pour la nouvelle interface gfm
# Valide que toutes les fonctionnalités simplifiées fonctionnent

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_REPO="/tmp/gfm-test-$(date +%s)"

echo -e "${CYAN}🧪 Test de l'interface gfm simplifiée${NC}"
echo -e "${CYAN}====================================${NC}"

# Préparer un repo de test
setup_test_repo() {
    echo -e "${BLUE}📁 Création du repository de test...${NC}"
    
    rm -rf "$TEST_REPO"
    mkdir -p "$TEST_REPO"
    cd "$TEST_REPO"
    
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Copier gfm dans le repo de test
    cp "$SCRIPT_DIR/gfm" ./gfm 2>/dev/null || {
        echo -e "${YELLOW}⚠️  gfm non trouvé, création d'un wrapper de test${NC}"
        create_test_wrapper
    }
    chmod +x ./gfm
    
    # Copier le détecteur
    mkdir -p scripts
    cp "$SCRIPT_DIR/scripts/missing-fix-detector.sh" scripts/
    
    echo -e "${GREEN}✅ Repository de test créé : $TEST_REPO${NC}"
}

# Créer un wrapper de test si gfm n'existe pas
create_test_wrapper() {
    cat > ./gfm << 'EOF'
#!/bin/bash
# Wrapper de test pour gfm

DETECTOR="$(pwd)/scripts/missing-fix-detector.sh"

case "${1:-}" in
    "bug"|"b")
        shift
        if [[ $# -eq 0 ]]; then
            echo "Usage: gfm bug <description>"
            exit 1
        fi
        # Générer un ID automatique
        BUG_ID="BUG-$(date +%Y%m%d)-$(openssl rand -hex 2 2>/dev/null || echo $(( RANDOM % 10000 )))"
        COMMIT=${2:-$(git rev-parse HEAD)}
        echo "🏷️  Marquage du bug $BUG_ID sur commit $COMMIT"
        "$DETECTOR" mark-bug "$COMMIT" "$BUG_ID" "$1"
        echo "✅ Bug $BUG_ID marqué avec succès"
        ;;
    "fix"|"f")
        shift
        if [[ $# -eq 0 ]]; then
            echo "Usage: gfm fix <BUG-ID> [bug-commit]"
            exit 1
        fi
        COMMIT=$(git rev-parse HEAD)
        # Trouver le commit du bug automatiquement
        BUG_COMMIT=$(git notes --ref=refs/notes/bugs list | while read commit_hash note_hash; do
            bug_info=$(git notes --ref=refs/notes/bugs show $note_hash 2>/dev/null || echo "")
            if [[ "$bug_info" == *"$1"* ]]; then
                echo $commit_hash
                break
            fi
        done)
        
        if [[ -z "$BUG_COMMIT" ]]; then
            echo "❌ Bug $1 non trouvé"
            exit 1
        fi
        
        echo "🔧 Marquage de la correction pour $1 (bug: $BUG_COMMIT -> fix: $COMMIT)"
        "$DETECTOR" mark-fix "$COMMIT" "$1" "$BUG_COMMIT"
        echo "✅ Correction $1 marquée avec succès"
        ;;
    "check"|"c")
        shift
        TARGET=${1:-$(git rev-parse HEAD)}
        echo "🔍 Vérification des corrections manquantes pour $TARGET"
        "$DETECTOR" check "$TARGET"
        ;;
    "list"|"l")
        shift
        case "${1:-}" in
            "bugs") 
                echo "📝 Liste des bugs :"
                "$DETECTOR" list-bugs 
                ;;
            "fixes") 
                echo "🔧 Liste des corrections :"
                "$DETECTOR" list-fixes 
                ;;
            *) 
                echo "📝 Liste des bugs :"
                "$DETECTOR" list-bugs
                echo
                echo "🔧 Liste des corrections :"
                "$DETECTOR" list-fixes 
                ;;
        esac
        ;;
    "status"|"s")
        echo "📊 Statut du repository :"
        "$DETECTOR" check $(git rev-parse HEAD)
        ;;
    "help"|"h"|"")
        echo "🚀 Git Fix Manager - Interface simplifiée"
        echo ""
        echo "Commandes principales :"
        echo "  gfm bug <description>     Marquer un bug"
        echo "  gfm fix <BUG-ID>         Marquer une correction"
        echo "  gfm check [branch/tag]   Vérifier les corrections"
        echo "  gfm list [bugs|fixes]    Lister bugs/corrections"
        echo "  gfm status              Statut du repository"
        echo ""
        echo "Raccourcis :"
        echo "  gfm b = gfm bug"
        echo "  gfm f = gfm fix"
        echo "  gfm c = gfm check"
        echo "  gfm l = gfm list"
        echo "  gfm s = gfm status"
        ;;
    *)
        echo "❌ Commande inconnue : $1"
        echo "💡 Utilisez 'gfm help' pour l'aide"
        exit 1
        ;;
esac
EOF
}

# Test des fonctionnalités de base
test_basic_functions() {
    echo -e "${BLUE}🧪 Test des fonctionnalités de base...${NC}"
    
    # Créer quelques commits
    echo "Initial code" > file1.txt
    git add file1.txt
    git commit -m "Initial commit"
    
    echo "buggy code" >> file1.txt
    git add file1.txt
    git commit -m "Add feature with bug"
    BUG_COMMIT=$(git rev-parse HEAD)
    
    # Test 1: Marquer un bug
    echo -e "${CYAN}Test 1: Marquer un bug${NC}"
    ./gfm bug "Memory leak in parser"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Test 1 réussi${NC}"
    else
        echo -e "${RED}❌ Test 1 échoué${NC}"
        return 1
    fi
    
    # Récupérer l'ID du bug
    BUG_ID=$(git notes --ref=refs/notes/bugs list | head -1 | while read commit_hash note_hash; do
        git notes --ref=refs/notes/bugs show $note_hash | grep "BUG:" | cut -d: -f2
    done)
    
    echo -e "${CYAN}Bug créé avec ID: $BUG_ID${NC}"
    
    # Corriger le bug
    echo "fixed code" > file1.txt
    git add file1.txt
    git commit -m "Fix memory leak in parser"
    
    # Test 2: Marquer la correction
    echo -e "${CYAN}Test 2: Marquer une correction${NC}"
    ./gfm fix "$BUG_ID"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Test 2 réussi${NC}"
    else
        echo -e "${RED}❌ Test 2 échoué${NC}"
        return 1
    fi
    
    # Test 3: Vérifier (doit être OK)
    echo -e "${CYAN}Test 3: Vérification (should be OK)${NC}"
    ./gfm check
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Test 3 réussi${NC}"
    else
        echo -e "${RED}❌ Test 3 échoué${NC}"
        return 1
    fi
    
    # Test 4: Lister les bugs
    echo -e "${CYAN}Test 4: Lister les bugs${NC}"
    ./gfm list bugs
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Test 4 réussi${NC}"
    else
        echo -e "${RED}❌ Test 4 échoué${NC}"
        return 1
    fi
    
    # Test 5: Lister les corrections
    echo -e "${CYAN}Test 5: Lister les corrections${NC}"
    ./gfm list fixes
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Test 5 réussi${NC}"
    else
        echo -e "${RED}❌ Test 5 échoué${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Tous les tests de base réussis${NC}"
    return 0
}

# Test des raccourcis
test_shortcuts() {
    echo -e "${BLUE}🧪 Test des raccourcis...${NC}"
    
    # Nouveau commit avec bug
    echo "another bug" >> file2.txt
    git add file2.txt
    git commit -m "Add another feature with bug"
    
    # Test raccourci 'b' pour bug
    echo -e "${CYAN}Test raccourci 'b' pour bug${NC}"
    ./gfm b "Null pointer exception"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Raccourci 'b' fonctionne${NC}"
    else
        echo -e "${RED}❌ Raccourci 'b' échoué${NC}"
        return 1
    fi
    
    # Test raccourci 'l' pour list
    echo -e "${CYAN}Test raccourci 'l' pour list${NC}"
    ./gfm l
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Raccourci 'l' fonctionne${NC}"
    else
        echo -e "${RED}❌ Raccourci 'l' échoué${NC}"
        return 1
    fi
    
    # Test raccourci 's' pour status
    echo -e "${CYAN}Test raccourci 's' pour status${NC}"
    ./gfm s
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Raccourci 's' fonctionne${NC}"
    else
        echo -e "${RED}❌ Raccourci 's' échoué${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Tous les raccourcis fonctionnent${NC}"
    return 0
}

# Test du scénario avec correction manquante
test_missing_fix_scenario() {
    echo -e "${BLUE}🧪 Test du scénario avec correction manquante...${NC}"
    
    # Créer une branche avec le bug mais sans la correction
    git checkout -b release/v1.0 HEAD~2  # Revenir avant les corrections
    
    # Vérifier que des corrections manquent
    echo -e "${CYAN}Test détection de corrections manquantes${NC}"
    ./gfm check release/v1.0
    EXIT_CODE=$?
    
    if [[ $EXIT_CODE -ne 0 ]]; then
        echo -e "${GREEN}✅ Corrections manquantes détectées correctement${NC}"
    else
        echo -e "${RED}❌ Devrait détecter des corrections manquantes${NC}"
        return 1
    fi
    
    # Retourner sur main
    git checkout -
    
    echo -e "${GREEN}✅ Scénario de correction manquante validé${NC}"
    return 0
}

# Test de l'aide
test_help() {
    echo -e "${BLUE}🧪 Test de l'aide...${NC}"
    
    ./gfm help
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Aide fonctionnelle${NC}"
    else
        echo -e "${RED}❌ Aide non fonctionnelle${NC}"
        return 1
    fi
    
    # Test aide sans paramètre
    ./gfm
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Aide par défaut fonctionnelle${NC}"
    else
        echo -e "${RED}❌ Aide par défaut non fonctionnelle${NC}"
        return 1
    fi
    
    return 0
}

# Nettoyage
cleanup() {
    echo -e "${BLUE}🧹 Nettoyage...${NC}"
    cd /
    rm -rf "$TEST_REPO"
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

# Affichage du résumé
show_test_summary() {
    echo
    echo -e "${CYAN}📊 Résumé des tests${NC}"
    echo -e "${CYAN}==================${NC}"
    echo -e "${GREEN}✅ Interface gfm simplifiée validée${NC}"
    echo -e "${GREEN}✅ Toutes les commandes fonctionnent${NC}"
    echo -e "${GREEN}✅ Raccourcis opérationnels${NC}"
    echo -e "${GREEN}✅ Détection de corrections manquantes OK${NC}"
    echo -e "${GREEN}✅ Aide contextuelle disponible${NC}"
    echo
    echo -e "${CYAN}🚀 L'interface gfm est prête pour utilisation !${NC}"
}

# Fonction principale
main() {
    setup_test_repo
    
    if test_basic_functions && test_shortcuts && test_missing_fix_scenario && test_help; then
        show_test_summary
        cleanup
        return 0
    else
        echo -e "${RED}❌ Certains tests ont échoué${NC}"
        echo -e "${CYAN}Repository de test conservé : $TEST_REPO${NC}"
        return 1
    fi
}

# Lancement des tests
main "$@"