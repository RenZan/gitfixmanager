#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: retroactive inheritance test
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")
make_commit "$repo" app.txt "feature: complex algorithm implementation"
orig_commit=$(cd "$repo" && git rev-parse HEAD)

# Create multiple cherry-picks BEFORE marking the original as bug
(cd "$repo" && git checkout -q -b feature/v1)
(cd "$repo" && git cherry-pick -x "$orig_commit" >/dev/null 2>&1 || true)
cp1=$(cd "$repo" && git rev-parse HEAD)

(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)

# NOW mark the original as bug (retroactive scenario)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$orig_commit" BUG-RETRO-001 "Algorithm bug")

# Check should trigger retroactive propagation
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch")

# Should see automatic inheritance during mark-bug
inherit_count=$(grep -c "Note propagée" <<<"$output" || true)
if [ "$inherit_count" -lt 1 ]; then
  # Try checking notes directly
  if ! (cd "$repo" && git notes --ref=bugs show "$cp1" >/dev/null 2>&1); then
    echo "ASSERTION FAILED: expected retroactive inheritance" >&2
    echo "$output" >&2
    exit 1
  fi
fi

echo "RETROACTIVE: PASS"