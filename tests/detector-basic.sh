#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"

repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: bug present on main, fix only in branch
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")
make_commit "$repo" app.txt "feature: add alpha logic"   # C1
make_commit "$repo" app.txt "feature: add beta logic"    # C2 (bug here)
bug_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug_commit" BUG-101 "Crash in alpha")

# Branch for fix AFTER marking bug so main keeps only the buggy commit
(cd "$repo" && git checkout -q -b fix/alpha)
make_commit "$repo" app.txt "fix: alpha crash resolved"
fix_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix_commit" BUG-101 "$bug_commit")

# Return to main without the fix
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)

main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch" || true)

if ! grep -q "Bug détecté: BUG-101" <<<"$output"; then
	echo "ASSERTION FAILED: missing 'Bug détecté: BUG-101'" >&2
	echo "----- RAW OUTPUT -----" >&2
	echo "$output" >&2
	echo "----------------------" >&2
	exit 1
fi
require_contains "$output" "ACTION REQUISE"
require_contains "$output" "CORRECTION TROUVÉE sur"

echo "BASIC: PASS"