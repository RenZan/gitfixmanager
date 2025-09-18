#!/bin/bash

cd /tmp/gfm-selection-test

echo "=== Test manuel de find_bug_commit ==="

# Test direct du pattern de recherche
bug_id="BUG-20250918-F462"
echo "Recherche de: $bug_id"

echo "Notes disponibles:"
git notes --ref=refs/notes/bugs list

echo
echo "Test de recherche manuelle:"
git notes --ref=refs/notes/bugs list | while read note_hash commit_hash; do
    if [[ -n "$commit_hash" ]]; then
        bug_info=$(git notes --ref=refs/notes/bugs show "$commit_hash" 2>/dev/null || echo "")
        echo "Commit: $commit_hash"
        echo "Bug info: $bug_info"
        if [[ "$bug_info" == *"$bug_id"* ]]; then
            echo "TROUVÉ! Commit: $commit_hash"
        else
            echo "Pas trouvé dans cette note"
        fi
        echo "---"
    fi
done