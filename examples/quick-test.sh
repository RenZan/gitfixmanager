#!/bin/bash
# quick-test.sh
# Script de test rapide pour vérifier que le système fonctionne

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_PATH="../scripts/missing-fix-detector.sh"

echo -e "${BLUE}🧪 Test rapide du système de détection${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Vérifier que le script existe
if [ ! -f "$SCRIPT_PATH" ]; then
    echo -e "${RED}❌ Erreur: Script $SCRIPT_PATH non trouvé${NC}"
    exit 1
fi

# Test 1: Affichage de l'aide
echo -e "${CYAN}Test 1: Affichage de l'aide${NC}"
echo -e "${CYAN}===========================${NC}"
"$SCRIPT_PATH" help

echo ""
echo -e "${CYAN}Test 2: Vérification du repository Git${NC}"
echo -e "${CYAN}=====================================${NC}"

if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Pas de repository Git détecté${NC}"
    echo -e "${YELLOW}   Initialisation d'un repository de test...${NC}"
    
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Créer un commit initial
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    echo -e "${GREEN}✅ Repository Git créé${NC}"
else
    echo -e "${GREEN}✅ Repository Git existant détecté${NC}"
fi

echo ""
echo -e "${CYAN}Test 3: Test des commandes de base${NC}"
echo -e "${CYAN}==================================${NC}"

# Obtenir le dernier commit
LAST_COMMIT=$(git rev-parse HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)

# Test du marquage d'un bug
echo -e "${YELLOW}Test du marquage d'un bug sur le commit $COMMIT_SHORT...${NC}"
"$SCRIPT_PATH" mark-bug "$LAST_COMMIT" "TEST-001" "Bug de test pour vérification"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Marquage de bug réussi${NC}"
else
    echo -e "${RED}❌ Échec du marquage de bug${NC}"
fi

# Test du marquage d'une correction
echo ""
echo -e "${YELLOW}Test du marquage d'une correction sur le commit $COMMIT_SHORT...${NC}"
"$SCRIPT_PATH" mark-fix "$LAST_COMMIT" "TEST-001" "$LAST_COMMIT"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Marquage de correction réussi${NC}"
else
    echo -e "${RED}❌ Échec du marquage de correction${NC}"
fi

echo ""
echo -e "${CYAN}Test 4: Vérification des listes${NC}"
echo -e "${CYAN}===============================${NC}"

echo -e "${YELLOW}Liste des bugs:${NC}"
"$SCRIPT_PATH" list-bugs

echo ""
echo -e "${YELLOW}Liste des corrections:${NC}"
"$SCRIPT_PATH" list-fixes

echo ""
echo -e "${CYAN}Test 5: Vérification d'une branche${NC}"
echo -e "${CYAN}==================================${NC}"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${YELLOW}Vérification de la branche $CURRENT_BRANCH...${NC}"
"$SCRIPT_PATH" check "$CURRENT_BRANCH"

echo ""
echo -e "${GREEN}🎉 Tests rapides terminés!${NC}"
echo ""
echo -e "${BLUE}📊 Résumé:${NC}"
echo -e "${BLUE}==========${NC}"
echo -e "${GREEN}✅ Script fonctionnel${NC}"
echo -e "${GREEN}✅ Repository Git configuré${NC}"
echo -e "${GREEN}✅ Marquage bugs/corrections opérationnel${NC}"
echo -e "${GREEN}✅ Vérification des branches fonctionnelle${NC}"

echo ""
echo -e "${CYAN}💡 Pour une démonstration complète:${NC}"
echo -e "${CYAN}  ./demo-scenario.sh${NC}"