#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: generic title filtering (should be excluded)
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")

# Create generic commits that should NOT trigger cherry-pick detection
make_commit "$repo" app.txt "fix"  # too generic
generic1=$(cd "$repo" && git rev-parse HEAD)
make_commit "$repo" app.txt "update"  # too generic
generic2=$(cd "$repo" && git rev-parse HEAD)
make_commit "$repo" app.txt "add feature"  # too generic
generic3=$(cd "$repo" && git rev-parse HEAD)

# Mark bugs on these
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$generic1" BUG-GEN-001 "Generic fix issue")
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$generic2" BUG-GEN-002 "Generic update issue")

# Create branches with similar generic titles
(cd "$repo" && git checkout -q -b branch1)
make_commit "$repo" app.txt "fix other thing"
(cd "$repo" && git checkout -q -b branch2 master)
make_commit "$repo" app.txt "update something"

# Back to main and check
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch")

# Should NOT detect false cherry-pick matches due to generic titles
require_contains "$output" "Bug détecté: BUG-GEN-001"
require_contains "$output" "Bug détecté: BUG-GEN-002"
require_not_contains "$output" "CORRECTION TROUVÉE"  # No false positives
require_contains "$output" "✅ Aucune correction manquante"

echo "GENERIC-FILTER: PASS"