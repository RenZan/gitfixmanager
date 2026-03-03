#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"

repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: Branch filtering for interactive bug selection
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")

# Bug on main
make_commit "$repo" app.txt "feature: bug in main"
main_bug=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$main_bug" BUG-MAIN "Bug only in main")

# Create a branch and add a different bug there
(cd "$repo" && git checkout -q -b feature/branch)
make_commit "$repo" app.txt "feature: bug in branch"
branch_bug=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$branch_bug" BUG-BRANCH "Bug only in branch")

# Test list-bugs (should show both)
output_all=$(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" list-bugs 2>/dev/null)
require_contains "$output_all" "BUG-MAIN"
require_contains "$output_all" "BUG-BRANCH"

# Test list-bugs-current on feature/branch (should show both - branch inherits main)
output_branch=$(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" list-bugs-current 2>/dev/null)
require_contains "$output_branch" "BUG-MAIN"  # inherited from main
require_contains "$output_branch" "BUG-BRANCH"  # specific to branch

# Switch to main and test list-bugs-current (should show only main bug)
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
(cd "$repo" && git checkout -q "$main_branch")
output_main=$(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" list-bugs-current 2>/dev/null)
require_contains "$output_main" "BUG-MAIN"
require_not_contains "$output_main" "BUG-BRANCH"

echo "BRANCH-FILTER: PASS"