#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: PR number heuristic detection
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")
make_commit "$repo" app.txt "feat: authentication system PR #1234"
orig_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$orig_commit" BUG-PR-001 "Auth bypass")

# Create branch and cherry-pick with PR reference
(cd "$repo" && git checkout -q -b release/v2)
(cd "$repo" && git cherry-pick -x "$orig_commit" >/dev/null 2>&1 || true)
make_commit "$repo" app.txt "hotfix: fix auth issue from PR #1234"
fix_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix_commit" BUG-PR-001 "$orig_commit")

# Back to main
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)

main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch")

# Should detect PR number link and show missing fix
require_contains "$output" "Bug détecté: BUG-PR-001"
require_contains "$output" "CORRECTION TROUVÉE sur release/v2"
require_contains "$output" "ACTION REQUISE"

echo "PR-HEURISTIC: PASS"