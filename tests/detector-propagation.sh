#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: propagation to cherry-picks limited
#############################################
(cd "$repo" && echo base > f.txt && git add f.txt && git commit -q -m "init")
# Create bug commit on main so it's ancestor
make_commit "$repo" f.txt "engine: stabilization patch PR #1234"
orig=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$orig" BUG-400 "Engine instability" >/dev/null)

# Create multiple cherry-picks
for b in branch1 branch2 branch3 branch4; do
  (cd "$repo" && git checkout -q -b $b master 2>/dev/null || git checkout -q -b $b main)
  (cd "$repo" && git cherry-pick -x "$orig" >/dev/null 2>&1 || true)
  (cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)
done

main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))

out=$(run_check "$repo" "$main_branch")
if ! grep -q "Bug détecté: BUG-400" <<<"$out"; then
  echo "ASSERTION FAILED: missing bug detection" >&2
  echo "$out" >&2
  exit 1
fi
# Ensure we never propagate more than 3 notes even with 4 cherry-picks
prop=$(grep -c "Note propagée" <<<"$out" || true)
if [ "$prop" -gt 3 ]; then
  echo "ASSERTION FAILED: over propagation ($prop)" >&2
  exit 1
fi
echo "PROPAGATION: PASS"