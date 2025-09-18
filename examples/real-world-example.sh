#!/bin/bash
# real-world-example.sh
# Exemple réaliste d'utilisation du système dans un projet

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌍 Exemple d'utilisation réelle du système${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

echo -e "${CYAN}Scénario: Préparation d'une release v2.1.0${NC}"
echo -e "${CYAN}============================================${NC}"

cat << 'EOF'

📋 Contexte:
Votre équipe prépare la release v2.1.0 d'une application web.
Plusieurs bugs ont été corrigés sur différentes branches depuis la v2.0.0,
mais vous voulez vous assurer qu'aucune correction n'est oubliée.

🎯 Objectif:
Créer un tag v2.1.0 propre avec toutes les corrections nécessaires.

EOF

echo -e "${YELLOW}Étape 1: Identification des bugs connus${NC}"
echo -e "${YELLOW}=======================================${NC}"

cat << 'EOF'

Voici les bugs identifiés dans votre historique:

1. BUG-2024-001: SQL injection dans le module d'authentification
   - Commit: a1b2c3d (introduit dans v2.0.0)
   - Sévérité: Critique
   - Corrigé sur: main

2. BUG-2024-002: Race condition dans le cache Redis
   - Commit: e4f5g6h (introduit après v2.0.0)
   - Sévérité: Haute
   - Corrigé sur: hotfix/redis-race

3. BUG-2024-003: Fuite mémoire dans le traitement des images
   - Commit: i7j8k9l (introduit après v2.0.0)
   - Sévérité: Moyenne
   - Corrigé sur: feature/image-optimization

EOF

read -p "Appuyez sur Entrée pour continuer avec le marquage..."

echo ""
echo -e "${YELLOW}Étape 2: Marquage des bugs et corrections${NC}"
echo -e "${YELLOW}=========================================${NC}"

cat << 'EOF'

Commandes pour marquer les bugs:

# Bug critique SQL injection
./scripts/missing-fix-detector.sh mark-bug a1b2c3d "BUG-2024-001" "SQL injection in auth module - CRITICAL"

# Bug race condition Redis
./scripts/missing-fix-detector.sh mark-bug e4f5g6h "BUG-2024-002" "Race condition in Redis cache - HIGH"

# Bug fuite mémoire
./scripts/missing-fix-detector.sh mark-bug i7j8k9l "BUG-2024-003" "Memory leak in image processing - MEDIUM"

Commandes pour marquer les corrections:

# Correction du bug SQL injection (sur main)
./scripts/missing-fix-detector.sh mark-fix x1y2z3a "BUG-2024-001" a1b2c3d

# Correction du bug Redis (sur hotfix/redis-race)
./scripts/missing-fix-detector.sh mark-fix b4c5d6e "BUG-2024-002" e4f5g6h

# Correction de la fuite mémoire (sur feature/image-optimization)
./scripts/missing-fix-detector.sh mark-fix f7g8h9i "BUG-2024-003" i7j8k9l

EOF

read -p "Appuyez sur Entrée pour continuer avec la vérification..."

echo ""
echo -e "${YELLOW}Étape 3: Préparation de la branche release${NC}"
echo -e "${YELLOW}=========================================${NC}"

cat << 'EOF'

Création de la branche release à partir de main:

git checkout main
git pull origin main
git checkout -b release/v2.1.0

Cette branche contient probablement certains bugs mais pas toutes les corrections.

EOF

read -p "Appuyez sur Entrée pour continuer avec la détection..."

echo ""
echo -e "${YELLOW}Étape 4: Détection des corrections manquantes${NC}"
echo -e "${YELLOW}=============================================${NC}"

cat << 'EOF'

Vérification de la branche release:

./scripts/missing-fix-detector.sh check release/v2.1.0

Résultat attendu:
🚨 RAPPORT DES CORRECTIONS MANQUANTES
======================================

❌ Bug ID: BUG-2024-002
   Description: Race condition in Redis cache - HIGH
   Bug présent dans release/v2.1.0: e4f5g6h
   Correction disponible sur hotfix/redis-race: b4c5d6e
   ➜ ACTION REQUISE: Cherry-pick b4c5d6e vers release/v2.1.0

❌ Bug ID: BUG-2024-003
   Description: Memory leak in image processing - MEDIUM
   Bug présent dans release/v2.1.0: i7j8k9l
   Correction disponible sur feature/image-optimization: f7g8h9i
   ➜ ACTION REQUISE: Cherry-pick f7g8h9i vers release/v2.1.0

📊 Total: 2 correction(s) manquante(s)

EOF

read -p "Appuyez sur Entrée pour continuer avec les suggestions..."

echo ""
echo -e "${YELLOW}Étape 5: Obtention des commandes de correction${NC}"
echo -e "${YELLOW}===============================================${NC}"

cat << 'EOF'

Génération des suggestions:

./scripts/missing-fix-detector.sh suggest release/v2.1.0

Commandes suggérées:
💡 COMMANDES SUGGÉRÉES POUR CORRIGER:
=====================================

# Pour corriger le bug BUG-2024-002:
git checkout release/v2.1.0
git cherry-pick -x b4c5d6e
# Puis marquer la correction:
./scripts/missing-fix-detector.sh mark-fix $(git rev-parse HEAD) BUG-2024-002 e4f5g6h

# Pour corriger le bug BUG-2024-003:
git checkout release/v2.1.0
git cherry-pick -x f7g8h9i
# Puis marquer la correction:
./scripts/missing-fix-detector.sh mark-fix $(git rev-parse HEAD) BUG-2024-003 i7j8k9l

# Une fois toutes les corrections appliquées, vérifier:
./scripts/missing-fix-detector.sh check release/v2.1.0

EOF

read -p "Appuyez sur Entrée pour continuer avec l'application..."

echo ""
echo -e "${YELLOW}Étape 6: Application des corrections${NC}"
echo -e "${YELLOW}====================================${NC}"

cat << 'EOF'

Application manuelle des corrections:

# S'assurer d'être sur la bonne branche
git checkout release/v2.1.0

# Appliquer la correction Redis
git cherry-pick -x b4c5d6e
if [ $? -eq 0 ]; then
    echo "✅ Correction Redis appliquée"
    ./scripts/missing-fix-detector.sh mark-fix $(git rev-parse HEAD) BUG-2024-002 e4f5g6h
else
    echo "❌ Conflit lors du cherry-pick - résolution manuelle nécessaire"
fi

# Appliquer la correction mémoire
git cherry-pick -x f7g8h9i
if [ $? -eq 0 ]; then
    echo "✅ Correction mémoire appliquée"
    ./scripts/missing-fix-detector.sh mark-fix $(git rev-parse HEAD) BUG-2024-003 i7j8k9l
else
    echo "❌ Conflit lors du cherry-pick - résolution manuelle nécessaire"
fi

EOF

read -p "Appuyez sur Entrée pour continuer avec la validation..."

echo ""
echo -e "${YELLOW}Étape 7: Validation finale${NC}"
echo -e "${YELLOW}=========================${NC}"

cat << 'EOF'

Vérification que toutes les corrections sont appliquées:

./scripts/missing-fix-detector.sh check release/v2.1.0

Résultat attendu:
✅ Aucune correction manquante détectée sur release/v2.1.0

EOF

read -p "Appuyez sur Entrée pour continuer avec le tagging..."

echo ""
echo -e "${YELLOW}Étape 8: Création du tag avec protection${NC}"
echo -e "${YELLOW}========================================${NC}"

cat << 'EOF'

Avec le hook pre-push installé, la création du tag est protégée:

# Créer le tag
git tag -a v2.1.0 -m "Release v2.1.0 - All critical fixes included"

# Pousser le tag (protégé par le hook)
git push origin v2.1.0

Si des corrections sont manquantes, le hook bloquera automatiquement:

🏷️ Vérification du tag: v2.1.0
🚨 RAPPORT DES CORRECTIONS MANQUANTES
❌ PUSH BLOQUÉ pour le tag v2.1.0
Des corrections sont disponibles mais manquantes sur ce tag

💡 Pour corriger le problème:
1. Exécutez: ./scripts/missing-fix-detector.sh suggest v2.1.0
2. Appliquez les corrections suggérées
3. Recommencez le push

Si toutes les corrections sont présentes:
✅ Tag v2.1.0: Aucune correction manquante
✅ Hook pre-push: Toutes les vérifications sont passées

EOF

echo ""
echo -e "${GREEN}🎉 Exemple d'utilisation réelle terminé!${NC}"
echo ""

echo -e "${BLUE}📊 Résumé du workflow:${NC}"
echo -e "${BLUE}======================${NC}"
echo -e "${YELLOW}1. ✅ Identification et marquage des bugs${NC}"
echo -e "${YELLOW}2. ✅ Marquage des corrections sur différentes branches${NC}"
echo -e "${YELLOW}3. ✅ Création de la branche release${NC}"
echo -e "${YELLOW}4. ✅ Détection automatique des corrections manquantes${NC}"
echo -e "${YELLOW}5. ✅ Application guidée des corrections${NC}"
echo -e "${YELLOW}6. ✅ Validation finale${NC}"
echo -e "${YELLOW}7. ✅ Protection automatique lors du tagging${NC}"

echo ""
echo -e "${CYAN}💡 Avantages de cette approche:${NC}"
echo -e "${CYAN}===============================${NC}"
echo -e "${GREEN}• Traçabilité complète des bugs et corrections${NC}"
echo -e "${GREEN}• Détection automatique des oublis${NC}"
echo -e "${GREEN}• Workflow reproductible${NC}"
echo -e "${GREEN}• Protection contre les releases incomplètes${NC}"
echo -e "${GREEN}• Facilitation des code reviews${NC}"

echo ""
echo -e "${BLUE}🔗 Intégration dans votre workflow:${NC}"
echo -e "${BLUE}====================================${NC}"
echo -e "${YELLOW}• Ajoutez le marquage des bugs dans votre process de review${NC}"
echo -e "${YELLOW}• Marquez les corrections lors des merges${NC}"
echo -e "${YELLOW}• Vérifiez systématiquement avant les releases${NC}"
echo -e "${YELLOW}• Activez les hooks pour une protection automatique${NC}"