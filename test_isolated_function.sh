#!/bin/bash

cd /tmp/gfm-selection-test

echo "=== Test de la fonction find_bug_commit() isolée ==="

# Copie de la fonction find_bug_commit
find_bug_commit() {
    local bug_id="$1"
    local result=""
    
    # Éviter le pipe pour éviter le sous-shell
    local notes_list=$(git notes --ref=refs/notes/bugs list 2>/dev/null)
    
    while read -r note_hash commit_hash; do
        if [[ -n "$commit_hash" ]]; then
            local bug_info=$(git notes --ref=refs/notes/bugs show "$commit_hash" 2>/dev/null || echo "")
            if [[ "$bug_info" == *"$bug_id"* ]]; then
                echo "$commit_hash"
                return 0
            fi
        fi
    done <<< "$notes_list"
    
    return 1
}

# Test de la fonction
bug_id="BUG-20250918-F462"
echo "Test de find_bug_commit pour: $bug_id"

echo "Notes list:"
git notes --ref=refs/notes/bugs list

echo
echo "Test de la fonction:"
result=$(find_bug_commit "$bug_id")
echo "Résultat: '$result'"

if [[ -n "$result" ]]; then
    echo "SUCCESS: Commit trouvé: $result"
else
    echo "ECHEC: Commit non trouvé"
fi