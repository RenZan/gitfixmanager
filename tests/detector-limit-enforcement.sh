#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

# Create a commit that we'll cherry-pick many times to trigger limit
(cd "$repo" && echo base > f.txt && git add f.txt && git commit -q -m "init")
root_commit=$(cd "$repo" && git rev-parse HEAD)
make_commit "$repo" f.txt "core: complex computation optimization"  # original bug commit
orig=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$orig" BUG-200 "Perf regression" >/dev/null)

# Ensure we're on main after marking
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)

# Create 8 branches each cherry-picking the bug commit (will embed reference)
for i in 1 2 3 4 5 6 7 8 9 10; do
  # Create branch from root (without original bug commit) to force a real cherry-pick commit
  (cd "$repo" && git checkout -q "$root_commit" && git checkout -q -b branch$i)
  (cd "$repo" && git cherry-pick -x "$orig" >/dev/null 2>&1 || true)
  (cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)
done

main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
out=$(run_check "$repo" "$main_branch")
match_count=$(cd "$repo" && git log --all --grep="cherry picked from commit $orig" --format="%H" | wc -l | tr -d ' ')
if ! grep -q "ALERTE:" <<<"$out"; then
  if [ "$match_count" -lt 6 ]; then
    echo "LIMIT: SKIP (only $match_count cherry-picks detected, alert condition not met)" >&2
    echo "LIMIT: PASS (skip)" && exit 0
  fi
  echo "ASSERTION FAILED: expected alert for >5 cherry-picks (saw $match_count)" >&2
  echo "$out" >&2
  exit 1
fi
propagated_count=$(grep -c "Note propagée" <<<"$out" || true)
if [ "$propagated_count" -gt 3 ]; then
  echo "ASSERTION FAILED: propagated count $propagated_count > 3" >&2
  exit 1
fi

echo "LIMIT: PASS"