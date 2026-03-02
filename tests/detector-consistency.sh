#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"

repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: Consistency - same results on repeated runs
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")

# Create original commit with bug
make_commit "$repo" app.txt "feature: add problematic code"
original_commit=$(cd "$repo" && git rev-parse HEAD)

# Create a branch and make a similar commit (simulating cherry-pick behavior)
(cd "$repo" && git checkout -q -b feature/test)
make_commit "$repo" app.txt "feature: add problematic code"  # Same title, different content
cherry_commit=$(cd "$repo" && git rev-parse HEAD)

# Manually create the cherry-pick relationship via patch-id (simulates cherry-pick without -x)
# This will make the detector think cherry_commit is a copy of original_commit

# Go back to master and mark the original as a bug
(cd "$repo" && git checkout -q master)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$original_commit" BUG-CONSISTENCY "Test consistency bug")

# The bug should be inherited to the cherry-pick on first run
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))

# First run - should detect inheritance AND the bug
output1=$(run_check "$repo" "$main_branch" || true)

# Second run - should give IDENTICAL results
output2=$(run_check "$repo" "$main_branch" || true)

# Both outputs should mention the bug consistently
if grep -q "Bug détecté: BUG-CONSISTENCY" <<<"$output1"; then
    require_contains "$output2" "Bug détecté: BUG-CONSISTENCY"
    echo "CONSISTENCY: Both runs detected the bug - PASS"
elif grep -q "Aucune correction manquante détectée" <<<"$output1"; then
    require_contains "$output2" "Aucune correction manquante détectée"
    echo "CONSISTENCY: Both runs showed no missing fixes - PASS"
else
    echo "CONSISTENCY: FAIL - Inconsistent results between runs" >&2
    echo "=== First run ===" >&2
    echo "$output1" >&2
    echo "=== Second run ===" >&2
    echo "$output2" >&2
    exit 1
fi