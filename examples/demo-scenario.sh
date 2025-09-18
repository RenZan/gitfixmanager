#!/bin/bash
# demo-scenario.sh
# Script de démonstration du système de détection des corrections manquantes
#
# Ce script crée un scénario complet pour démontrer les fonctionnalités :
# 1. Crée un repository Git de démonstration
# 2. Simule l'introduction de bugs
# 3. Simule les corrections sur différentes branches
# 4. Démontre la détection des corrections manquantes

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Répertoire de démonstration
DEMO_DIR="missing-fix-demo"
SCRIPT_PATH="../scripts/missing-fix-detector.sh"

echo -e "${BLUE}🎬 Démonstration du Script de Détection des Corrections Manquantes${NC}"
echo -e "${BLUE}=================================================================${NC}"
echo ""

# Nettoyer et créer le répertoire de démonstration
if [ -d "$DEMO_DIR" ]; then
    echo -e "${YELLOW}🧹 Nettoyage du répertoire de démonstration existant...${NC}"
    rm -rf "$DEMO_DIR"
fi

echo -e "${CYAN}📁 Création du repository de démonstration...${NC}"
mkdir "$DEMO_DIR"
cd "$DEMO_DIR"

# Initialiser le repository Git
git init
git config user.name "Demo User"
git config user.email "demo@example.com"

# Copier le script dans le répertoire de démonstration
mkdir -p scripts src
cp "$SCRIPT_PATH" scripts/
chmod +x scripts/missing-fix-detector.sh

echo ""
echo -e "${CYAN}📝 Création du code initial...${NC}"

# Créer quelques fichiers sources
cat > src/main.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // Code initial sans bugs
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    free(buffer);
    
    return 0;
}
EOF

cat > src/parser.c << 'EOF'
#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // Fonction de parsing simple
    if (input != NULL) {
        return strlen(input);
    }
    return 0;
}
EOF

cat > README.md << 'EOF'
# Demo Application

Cette application démontre le système de détection des corrections manquantes.

## Fonctionnalités
- Parser d'entrée
- Gestion mémoire
- Interface utilisateur
EOF

# Commit initial
git add .
git commit -m "Initial commit: basic application structure"

echo ""
echo -e "${YELLOW}🐛 Simulation: Introduction de bugs...${NC}"

# Bug 1: Memory leak dans main.c
cat > src/main.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // BUG: Memory leak - malloc sans free
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    // free(buffer); // Oublié !
    
    return 0;
}
EOF

git add src/main.c
git commit -m "Add logging feature"
BUG1_COMMIT=$(git rev-parse HEAD)

echo -e "${RED}   ➜ Bug 1 introduit: Memory leak dans main.c (commit: $(git rev-parse --short $BUG1_COMMIT))${NC}"

# Bug 2: Null pointer dans parser.c
cat > src/parser.c << 'EOF'
#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // BUG: Pas de vérification de input avant strlen
    return strlen(input); // Crash si input est NULL
}
EOF

git add src/parser.c
git commit -m "Optimize parser performance"
BUG2_COMMIT=$(git rev-parse HEAD)

echo -e "${RED}   ➜ Bug 2 introduit: Null pointer dans parser.c (commit: $(git rev-parse --short $BUG2_COMMIT))${NC}"

# Marquer les bugs
echo ""
echo -e "${CYAN}🏷️  Marquage des bugs...${NC}"
./scripts/missing-fix-detector.sh mark-bug "$BUG1_COMMIT" "LEAK-001" "Memory leak in main function"
./scripts/missing-fix-detector.sh mark-bug "$BUG2_COMMIT" "NULL-001" "Null pointer dereference in parser"

# Créer une branche de release avec les bugs
echo ""
echo -e "${CYAN}🌿 Création de la branche release avec les bugs...${NC}"
git checkout -b release/v1.0
echo -e "${YELLOW}   ➜ Branche release/v1.0 créée à partir de main avec les 2 bugs${NC}"

# Retour sur main pour les corrections
git checkout main

echo ""
echo -e "${GREEN}🔧 Simulation: Corrections des bugs sur main...${NC}"

# Correction du bug 1
cat > src/main.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // FIX: Memory leak corrigé
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    free(buffer); // Ajouté pour corriger le leak
    
    return 0;
}
EOF

git add src/main.c
git commit -m "Fix memory leak in main function"
FIX1_COMMIT=$(git rev-parse HEAD)

echo -e "${GREEN}   ➜ Bug 1 corrigé sur main (commit: $(git rev-parse --short $FIX1_COMMIT))${NC}"

# Marquer la correction
./scripts/missing-fix-detector.sh mark-fix "$FIX1_COMMIT" "LEAK-001" "$BUG1_COMMIT"

# Correction du bug 2 sur une branche séparée
echo ""
echo -e "${CYAN}🌿 Création d'une branche hotfix pour le bug 2...${NC}"
git checkout -b hotfix/null-fix

cat > src/parser.c << 'EOF'
#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // FIX: Vérification de input avant utilisation
    if (input == NULL) {
        return 0;
    }
    return strlen(input);
}
EOF

git add src/parser.c
git commit -m "Fix null pointer dereference in parser"
FIX2_COMMIT=$(git rev-parse HEAD)

echo -e "${GREEN}   ➜ Bug 2 corrigé sur hotfix/null-fix (commit: $(git rev-parse --short $FIX2_COMMIT))${NC}"

# Marquer la correction
./scripts/missing-fix-detector.sh mark-fix "$FIX2_COMMIT" "NULL-001" "$BUG2_COMMIT"

echo ""
echo -e "${BLUE}📊 État actuel du repository:${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}• main:${NC} Les 2 bugs + correction du bug 1"
echo -e "${YELLOW}• hotfix/null-fix:${NC} Correction du bug 2"
echo -e "${YELLOW}• release/v1.0:${NC} Les 2 bugs SANS corrections"

echo ""
echo -e "${CYAN}🔍 Démonstration: Détection des corrections manquantes...${NC}"

# Vérifier les corrections manquantes sur release/v1.0
echo ""
echo -e "${YELLOW}1. Vérification de release/v1.0 (mode alerte):${NC}"
echo -e "${YELLOW}==============================================${NC}"
./scripts/missing-fix-detector.sh check release/v1.0

echo ""
echo -e "${YELLOW}2. Suggestions de corrections pour release/v1.0:${NC}"
echo -e "${YELLOW}================================================${NC}"
./scripts/missing-fix-detector.sh suggest release/v1.0

echo ""
echo -e "${YELLOW}3. Liste des bugs marqués:${NC}"
echo -e "${YELLOW}==========================${NC}"
./scripts/missing-fix-detector.sh list-bugs

echo ""
echo -e "${YELLOW}4. Liste des corrections marquées:${NC}"
echo -e "${YELLOW}=================================${NC}"
./scripts/missing-fix-detector.sh list-fixes

echo ""
echo -e "${CYAN}🚀 Démonstration: Application des corrections...${NC}"

# Appliquer les corrections suggérées
git checkout release/v1.0

echo ""
echo -e "${GREEN}Correction 1: Cherry-pick du fix memory leak...${NC}"
git cherry-pick -x "$FIX1_COMMIT"
APPLIED_FIX1=$(git rev-parse HEAD)
./scripts/missing-fix-detector.sh mark-fix "$APPLIED_FIX1" "LEAK-001" "$BUG1_COMMIT"

echo ""
echo -e "${GREEN}Correction 2: Cherry-pick du fix null pointer...${NC}"
git cherry-pick -x "$FIX2_COMMIT"
APPLIED_FIX2=$(git rev-parse HEAD)
./scripts/missing-fix-detector.sh mark-fix "$APPLIED_FIX2" "NULL-001" "$BUG2_COMMIT"

echo ""
echo -e "${CYAN}✅ Vérification finale: release/v1.0 après corrections...${NC}"
./scripts/missing-fix-detector.sh check release/v1.0

echo ""
echo -e "${GREEN}🎉 Démonstration terminée!${NC}"
echo ""
echo -e "${BLUE}📋 Résumé de la démonstration:${NC}"
echo -e "${BLUE}==============================${NC}"
echo -e "${YELLOW}1. ✅ Bugs marqués et corrections marquées${NC}"
echo -e "${YELLOW}2. ✅ Détection automatique des corrections manquantes${NC}"
echo -e "${YELLOW}3. ✅ Suggestions de commandes pour corriger${NC}"
echo -e "${YELLOW}4. ✅ Application des corrections et vérification${NC}"

echo ""
echo -e "${CYAN}💡 Prochaines étapes:${NC}"
echo -e "${CYAN}==================${NC}"
echo -e "${YELLOW}• Tester le mode blocage: ./scripts/missing-fix-detector.sh block <branch>${NC}"
echo -e "${YELLOW}• Installer les hooks: cd .. && ./install-hooks.sh${NC}"
echo -e "${YELLOW}• Tester avec un vrai tag: git tag v1.0.0 && git push origin v1.0.0${NC}"

echo ""
echo -e "${BLUE}📂 Le repository de démonstration est dans: $(pwd)${NC}"
echo -e "${BLUE}   Vous pouvez explorer les branches et l'historique Git${NC}"