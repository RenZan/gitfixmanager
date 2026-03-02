#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"

repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: Only bugs, no fixes - should skip cherry-pick scan
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")
make_commit "$repo" app.txt "feature: add buggy code"
bug_commit=$(cd "$repo" && git rev-parse HEAD)

# Mark bug but NO fix
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug_commit" BUG-999 "Test bug without fix")

main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch" || true)

# Should contain the optimization message indicating cherry-pick scan was skipped
require_contains "$output" "Aucune note de correction trouvée, scan de cherry-picks ignoré"

# Should NOT contain the cherry-pick search message
require_not_contains "$output" "Héritage automatique des notes depuis les commits originaux"

echo "NO-CHERRY-SCAN: PASS"