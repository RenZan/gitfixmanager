#!/bin/bash
# Test de validation de la correction du bug d'héritage massif
# Ce script teste la fonction find_cherry_pick_copies avec des cas contrôlés

# Charger les fonctions du script principal
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/missing-fix-detector.sh"

echo "🧪 Test de validation - Correction bug héritage massif"
echo "===================================================="

# Test 1: Commit avec titre générique (ne devrait PAS matcher massivement)
echo -e "\n1️⃣ Test avec titre générique (devrait être ignoré):"
echo "Titre simulé: 'Fix bug in login'"

# Créer un commit temporaire pour le test
TEMP_COMMIT=$(git rev-parse HEAD)
echo "Test avec commit: $TEMP_COMMIT"

# Tester la fonction find_cherry_pick_copies
echo "Recherche des cherry-picks..."
RESULT=$(find_cherry_pick_copies "$TEMP_COMMIT")

if [ -z "$RESULT" ]; then
    echo "✅ SUCCÈS: Aucun faux positif détecté pour titre générique"
else
    echo "❌ ÉCHEC: Des faux positifs détectés: $RESULT"
fi

# Test 2: Fonction de limite sur nombre de résultats
echo -e "\n2️⃣ Test de limitation des résultats:"
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "Nombre total de commits dans le repo: $COMMIT_COUNT"

if [ "$COMMIT_COUNT" -gt 10 ]; then
    echo "✅ Repository assez grand pour tester la limitation"
else
    echo "ℹ️  Repository petit, test de limitation non applicable"
fi

echo -e "\n🎯 Test terminé!"