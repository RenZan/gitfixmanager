#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: performance test with many commits
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")

# Create 50 commits to simulate real repository
for i in {1..50}; do
  make_commit "$repo" app.txt "commit $i: various changes and improvements"
done

# Mark some as bugs
bug1=$(cd "$repo" && git rev-parse HEAD~10)
bug2=$(cd "$repo" && git rev-parse HEAD~25)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug1" BUG-PERF-001 "Performance issue")
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug2" BUG-PERF-002 "Memory leak")

# Create fixes on branches
(cd "$repo" && git checkout -q -b hotfix/perf)
make_commit "$repo" app.txt "fix: resolve performance bottleneck"
fix1=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix1" BUG-PERF-001 "$bug1")

(cd "$repo" && git checkout -q -b hotfix/memory master)
make_commit "$repo" app.txt "fix: plug memory leak"
fix2=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix2" BUG-PERF-002 "$bug2")

# Performance test: time the check
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))

start_time=$(date +%s)
output=$(run_check "$repo" "$main_branch")
end_time=$(date +%s)
duration=$((end_time - start_time))

# Should complete in reasonable time (< 5 seconds for 50 commits)
if [ "$duration" -gt 5 ]; then
  echo "ASSERTION FAILED: performance too slow ($duration seconds)" >&2
  exit 1
fi

# Should detect both missing fixes
fixes_count=$(grep -c "CORRECTION TROUVÉE" <<<"$output" || true)
if [ "$fixes_count" -ne 2 ]; then
  echo "ASSERTION FAILED: expected 2 fixes, got $fixes_count" >&2
  echo "$output" >&2
  exit 1
fi

echo "PERFORMANCE: PASS (${duration}s for 50 commits)"