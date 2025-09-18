#!/bin/bash

cd /tmp/gfm-selection-test

echo "=== Test de la fonction find_bug_commit() de gfm ==="

# Sourcer la fonction find_bug_commit depuis le script gfm
source /home/renzan/.local/bin/gfm

# Test de la fonction
bug_id="BUG-20250918-F462"
echo "Test de find_bug_commit pour: $bug_id"

result=$(find_bug_commit "$bug_id")
echo "Résultat: '$result'"

if [[ -n "$result" ]]; then
    echo "SUCCESS: Commit trouvé: $result"
else
    echo "ECHEC: Commit non trouvé"
fi