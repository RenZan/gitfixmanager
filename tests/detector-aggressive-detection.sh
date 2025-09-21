#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"

repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: Validate that patch-id detection is not too aggressive
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")

# Create many commits with similar but different content to stress-test patch-id
for i in {1..10}; do
    make_commit "$repo" app.txt "common commit pattern $i"
done

# Add a real bug
make_commit "$repo" app.txt "feature: real bug here"
bug_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug_commit" BUG-AGGRESSIVE-TEST "Real bug")

# Create a branch and make a real cherry-pick with similar title
(cd "$repo" && git checkout -q -b fix/branch)
make_commit "$repo" app.txt "fix: real bug here - security patch"
fix_commit=$(cd "$repo" && git rev-parse HEAD)

# Mark the fix and test cherry-pick detection
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix_commit" BUG-AGGRESSIVE-TEST "$bug_commit")

# The number of detected cherry-picks should be reasonable (< 5)
# and we should NOT see the aggressive detection alert
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
(cd "$repo" && git checkout -q "$main_branch")

output=$(run_check "$repo" "$main_branch" 2>&1 || true)

# Should NOT contain the aggressive detection alert
require_not_contains "$output" "cherry-picks détectés pour"

# Should still detect the bug correctly
require_contains "$output" "Bug détecté: BUG-AGGRESSIVE-TEST"

echo "AGGRESSIVE-DETECTION: PASS"