#!/bin/bash

# Test final complet du système Git Fix Manager simplifié
# Valide l'installation, l'interface, et tous les scénarios

set -e

# Configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TEST_PASSED=0
TEST_FAILED=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}${BOLD}🧪 Test Final - Git Fix Manager v2.0${NC}"
echo -e "${CYAN}========================================${NC}"

# Fonction de test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -en "${BLUE}📋 Test: $test_name${NC} ... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED${NC}"
        ((TEST_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((TEST_FAILED++))
        return 1
    fi
}

# Test d'existence des fichiers
test_files_exist() {
    echo -e "${BLUE}🔍 Vérification des fichiers...${NC}"
    
    run_test "Script principal gfm" "[[ -f '$SCRIPT_DIR/gfm' ]]"
    run_test "Détecteur principal" "[[ -f '$SCRIPT_DIR/scripts/missing-fix-detector.sh' ]]"
    run_test "Hook pre-push" "[[ -f '$SCRIPT_DIR/hooks/pre-push' ]]"
    run_test "Installation intelligente" "[[ -f '$SCRIPT_DIR/install-smart.sh' ]]"
    run_test "README mis à jour" "[[ -f '$SCRIPT_DIR/README.md' ]]"
    run_test "Exemples de démo" "[[ -d '$SCRIPT_DIR/examples' ]]"
}

# Test de syntaxe des scripts
test_script_syntax() {
    echo -e "${BLUE}🔍 Vérification de la syntaxe...${NC}"
    
    run_test "Syntaxe gfm" "bash -n '$SCRIPT_DIR/gfm'"
    run_test "Syntaxe détecteur" "bash -n '$SCRIPT_DIR/scripts/missing-fix-detector.sh'"
    run_test "Syntaxe hook" "bash -n '$SCRIPT_DIR/hooks/pre-push'"
    run_test "Syntaxe install-smart" "bash -n '$SCRIPT_DIR/install-smart.sh'"
}

# Test de l'aide
test_help_system() {
    echo -e "${BLUE}🔍 Système d'aide...${NC}"
    
    cd "$SCRIPT_DIR"
    
    # Initialiser un repo git temporaire si nécessaire
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        git init >/dev/null 2>&1
        git config user.email "test@example.com" >/dev/null 2>&1
        git config user.name "Test User" >/dev/null 2>&1
        echo "test" > test.txt
        git add test.txt >/dev/null 2>&1
        git commit -m "Initial test commit" >/dev/null 2>&1
    fi
    
    run_test "Aide générale" "./gfm help"
    run_test "Aide bug" "./gfm help bug"
    run_test "Aide fix" "./gfm help fix"
    run_test "Aide check" "./gfm help check"
    run_test "Version" "./gfm --version"
}

# Test des commandes principales
test_main_commands() {
    echo -e "${BLUE}🔍 Commandes principales...${NC}"
    
    cd "$SCRIPT_DIR"
    
    # Test des commandes sans paramètres (devraient afficher l'aide)
    run_test "Commande bug sans args" "./gfm bug 2>&1 | grep -q 'Description du bug requise'"
    run_test "Commande fix sans args" "./gfm fix 2>&1 | grep -q 'ID du bug requis'"
}

# Test de la documentation
test_documentation() {
    echo -e "${BLUE}🔍 Documentation...${NC}"
    
    run_test "README contient gfm" "grep -q 'gfm bug' '$SCRIPT_DIR/README.md'"
    run_test "README contient exemples" "grep -q 'Exemples Réels' '$SCRIPT_DIR/README.md'"
    run_test "README contient installation" "grep -q 'install-smart.sh' '$SCRIPT_DIR/README.md'"
    run_test "README contient aide" "grep -q 'gfm help' '$SCRIPT_DIR/README.md'"
}

# Test de l'interface simplifiée
test_simplified_interface() {
    echo -e "${BLUE}🔍 Interface simplifiée...${NC}"
    
    cd "$SCRIPT_DIR"
    
    run_test "Version dans gfm" "grep -q 'VERSION=\"2.0.0\"' '$SCRIPT_DIR/gfm'"
    run_test "Icônes dans gfm" "grep -q 'BUG_ICON=' '$SCRIPT_DIR/gfm'"
    run_test "Mode interactif" "grep -q 'interactive_mode' '$SCRIPT_DIR/gfm'"
    run_test "Auto-détection" "grep -q 'detect_context' '$SCRIPT_DIR/gfm'"
    run_test "Aide contextuelle" "grep -q 'show_help' '$SCRIPT_DIR/gfm'"
}

# Test de compatibilité WSL
test_wsl_compatibility() {
    echo -e "${BLUE}🔍 Compatibilité WSL...${NC}"
    
    run_test "Shebang bash" "head -1 '$SCRIPT_DIR/gfm' | grep -q '#!/bin/bash'"
    run_test "Pas de dépendances Linux spécifiques" "! grep -q 'apt-get\\|yum\\|pacman' '$SCRIPT_DIR/gfm'"
    run_test "Variables d'environnement portables" "grep -q 'SCRIPT_DIR=' '$SCRIPT_DIR/gfm'"
}

# Test de robustesse
test_robustness() {
    echo -e "${BLUE}🔍 Robustesse...${NC}"
    
    run_test "Gestion d'erreurs" "grep -q 'set -e' '$SCRIPT_DIR/gfm'"
    run_test "Vérifications préliminaires" "grep -q 'check_prerequisites' '$SCRIPT_DIR/gfm'"
    run_test "Messages d'erreur colorés" "grep -q 'ERROR_ICON' '$SCRIPT_DIR/gfm'"
    run_test "Vérification Git" "grep -q 'git rev-parse --git-dir' '$SCRIPT_DIR/gfm'"
}

# Test de l'expérience utilisateur
test_user_experience() {
    echo -e "${BLUE}🔍 Expérience utilisateur...${NC}"
    
    run_test "Icônes émojis" "grep -q '🐛\\|🔧\\|✅' '$SCRIPT_DIR/gfm'"
    run_test "Couleurs définies" "grep -q 'RED=.*033' '$SCRIPT_DIR/gfm'"
    run_test "Messages informatifs" "grep -q 'INFO_ICON' '$SCRIPT_DIR/gfm'"
    run_test "Confirmations interactives" "grep -q 'Confirmer' '$SCRIPT_DIR/gfm'"
}

# Test des exemples
test_examples() {
    echo -e "${BLUE}🔍 Exemples et démos...${NC}"
    
    run_test "Répertoire examples" "[[ -d '$SCRIPT_DIR/examples' ]]"
    run_test "Script de démo" "[[ -f '$SCRIPT_DIR/examples/demo-simple.sh' ]]"
    run_test "Test d'intégration" "[[ -f '$SCRIPT_DIR/test-gfm-interface.sh' ]]"
}

# Test des fonctionnalités avancées
test_advanced_features() {
    echo -e "${BLUE}🔍 Fonctionnalités avancées...${NC}"
    
    run_test "Génération d'ID automatique" "grep -q 'generate_bug_id' '$SCRIPT_DIR/gfm'"
    run_test "Auto-détection de contexte" "grep -q 'detect_context' '$SCRIPT_DIR/gfm'"
    run_test "Recherche de commit de bug" "grep -q 'find_bug_commit' '$SCRIPT_DIR/gfm'"
    run_test "Mode interactif complet" "grep -q 'interactive_mode' '$SCRIPT_DIR/gfm'"
}

# Fonction principale de test
main() {
    echo -e "${CYAN}🚀 Démarrage des tests...${NC}"
    echo
    
    test_files_exist
    echo
    test_script_syntax
    echo
    test_help_system
    echo
    test_main_commands
    echo
    test_documentation
    echo
    test_simplified_interface
    echo
    test_wsl_compatibility
    echo
    test_robustness
    echo
    test_user_experience
    echo
    test_examples
    echo
    test_advanced_features
    
    echo
    echo -e "${CYAN}${BOLD}📊 RÉSUMÉ DES TESTS${NC}"
    echo -e "${CYAN}==================${NC}"
    echo -e "${GREEN}✅ Tests réussis    : $TEST_PASSED${NC}"
    echo -e "${RED}❌ Tests échoués    : $TEST_FAILED${NC}"
    echo -e "${BLUE}📊 Total           : $((TEST_PASSED + TEST_FAILED))${NC}"
    
    if [[ $TEST_FAILED -eq 0 ]]; then
        echo
        echo -e "${GREEN}${BOLD}🎉 TOUS LES TESTS SONT PASSÉS !${NC}"
        echo -e "${GREEN}${BOLD}✨ Git Fix Manager v2.0 est prêt pour utilisation${NC}"
        echo
        echo -e "${CYAN}🚀 Prochaines étapes :${NC}"
        echo -e "  1. ${CYAN}./install-smart.sh${NC}     # Installation complète"
        echo -e "  2. ${CYAN}gfm help${NC}               # Découvrir les commandes"
        echo -e "  3. ${CYAN}gfm interactive${NC}        # Mode guidé pour débutants"
        echo -e "  4. ${CYAN}gfm bug \"test\"${NC}         # Votre premier bug"
        echo
        return 0
    else
        echo
        echo -e "${RED}${BOLD}❌ CERTAINS TESTS ONT ÉCHOUÉ${NC}"
        echo -e "${YELLOW}⚠️  Vérifiez les erreurs ci-dessus avant utilisation${NC}"
        echo
        return 1
    fi
}

# Test spécifique pour l'intégration
test_integration() {
    local temp_dir="/tmp/gfm-integration-test-$$"
    
    echo -e "${BLUE}🔍 Test d'intégration complet...${NC}"
    
    # Créer un environnement de test isolé
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    # Copier les fichiers nécessaires
    cp -r "$SCRIPT_DIR"/* .
    
    # Initialiser un repo Git
    git init >/dev/null 2>&1
    git config user.email "test@integration.com" >/dev/null 2>&1
    git config user.name "Integration Test" >/dev/null 2>&1
    
    # Créer un commit initial
    echo "Initial code" > app.py
    git add app.py >/dev/null 2>&1
    git commit -m "Initial commit" >/dev/null 2>&1
    
    echo -e "${CYAN}  📁 Environnement de test créé : $temp_dir${NC}"
    
    # Test du workflow complet
    local success=true
    
    # 1. Test marking bug (simulation avec echo au lieu d'interaction)
    echo -e "${CYAN}  🐛 Test marquage d'un bug...${NC}"
    if echo -e "\n" | ./gfm bug "Test integration bug" >/dev/null 2>&1; then
        echo -e "${GREEN}    ✅ Bug marqué avec succès${NC}"
    else
        echo -e "${RED}    ❌ Échec du marquage de bug${NC}"
        success=false
    fi
    
    # 2. Test listing
    echo -e "${CYAN}  📝 Test listing des bugs...${NC}"
    if ./gfm list bugs >/dev/null 2>&1; then
        echo -e "${GREEN}    ✅ Listing fonctionnel${NC}"
    else
        echo -e "${RED}    ❌ Échec du listing${NC}"
        success=false
    fi
    
    # 3. Test check
    echo -e "${CYAN}  ✅ Test vérification...${NC}"
    if ./gfm check >/dev/null 2>&1; then
        echo -e "${GREEN}    ✅ Vérification fonctionnelle${NC}"
    else
        echo -e "${RED}    ❌ Échec de la vérification${NC}"
        success=false
    fi
    
    # Nettoyage
    cd /
    rm -rf "$temp_dir"
    
    if $success; then
        echo -e "${GREEN}  🎉 Test d'intégration réussi${NC}"
        ((TEST_PASSED++))
    else
        echo -e "${RED}  ❌ Test d'intégration échoué${NC}"
        ((TEST_FAILED++))
    fi
}

# Exécution des tests avec option
case "${1:-}" in
    "--integration"|"-i")
        test_integration
        ;;
    "--help"|"-h")
        echo "Test Final - Git Fix Manager v2.0"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --integration, -i    Test d'intégration complet"
        echo "  --help, -h          Cette aide"
        echo ""
        echo "Sans option: lance tous les tests de base"
        ;;
    "")
        main
        ;;
    *)
        echo -e "${RED}Option inconnue: $1${NC}"
        echo "Utilisez --help pour l'aide"
        exit 1
        ;;
esac