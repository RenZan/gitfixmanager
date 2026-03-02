#!/bin/bash
# i18n test for Git Fix Manager

set -e

echo "Testing i18n support..."

# Test English
echo -n "Testing English (GFM_LANG=en)... "
output=$(GFM_LANG=en ./gfm help 2>&1)
if echo "$output" | grep -q "Mark a bug"; then
    echo "OK"
else
    echo "FAIL - 'Mark a bug' not found"
    exit 1
fi

# Test French
echo -n "Testing French (GFM_LANG=fr)... "
output=$(GFM_LANG=fr ./gfm help 2>&1)
if echo "$output" | grep -q "Marquer un bug"; then
    echo "OK"
else
    echo "FAIL - 'Marquer un bug' not found"
    exit 1
fi

# Test default (should be English)
echo -n "Testing default language... "
output=$(./gfm help 2>&1)
if echo "$output" | grep -q "Mark a bug"; then
    echo "OK"
else
    echo "FAIL - Default is not English"
    exit 1
fi

echo "All i18n tests passed!"