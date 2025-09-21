#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

(cd "$repo" && echo base > a.txt && git add a.txt && git commit -q -m "init")
make_commit "$repo" a.txt "feat: independent module"
make_commit "$repo" a.txt "feat: another change"

# Mark a bug on HEAD
bug_commit=$(cd "$repo" && git rev-parse HEAD)
"$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug_commit" BUG-300 "Independent bug" >/dev/null

# Run check on main: no fix elsewhere should be reported
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
out=$(run_check "$repo" "$main_branch")
require_not_contains "$out" "CORRECTION TROUVÉE"
require_not_contains "$out" "ACTION REQUISE"
require_contains "$out" "✅ Aucune correction manquante"

echo "NEGATIVE: PASS"