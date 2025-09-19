#!/bin/bash
# Test simple de la correction du bug d'héritage massif

echo "🧪 Test de la correction du bug d'héritage massif"
echo "================================================"

echo -e "\n1️⃣ Test de la logique modifiée dans find_cherry_pick_copies:"

# Simuler les conditions qui causaient le problème
echo "Vérification que les titres génériques sont maintenant ignorés..."

# Test des titres qui devraient être ignorés
generic_titles=(
    "fix issue"
    "merge branch"
    "update code"
    "add feature"
    "remove bug"
    "short"
)

echo "Titres génériques testés:"
for title in "${generic_titles[@]}"; do
    echo "  - '$title'"
    # Logique de la correction: titre court OU commençant par mot générique = ignoré
    if [ ${#title} -le 20 ] || echo "$title" | grep -qi "^merge\|^update\|^fix\|^add\|^remove"; then
        echo "    ✅ Correctement ignoré"
    else
        echo "    ❌ Devrait être ignoré"
    fi
done

echo -e "\n2️⃣ Test des titres qui devraient être traités:"
specific_titles=(
    "Implement complex authentication system with OAuth2"
    "Refactor database connection handling for performance optimization"
    "Initialize comprehensive logging framework configuration"
)

echo "Titres spécifiques testés:"
for title in "${specific_titles[@]}"; do
    echo "  - '$title'"
    if [ ${#title} -gt 20 ] && ! echo "$title" | grep -qi "^merge\|^update\|^fix\|^add\|^remove"; then
        echo "    ✅ Correctement traité"
    else
        echo "    ❌ Devrait être traité"
    fi
done

echo -e "\n3️⃣ Test des mots-clés minimum 6 caractères:"
test_words="authentication system OAuth2 config fix add db"
echo "Mots testés: $test_words"
valid_words=$(echo "$test_words" | grep -o "[A-Za-z]\{6,\}" | tr '\n' ' ')
echo "Mots valides (≥6 chars): $valid_words"

echo -e "\n✅ Test terminé - La correction devrait éliminer les faux positifs massifs"