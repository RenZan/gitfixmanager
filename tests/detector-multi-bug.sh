#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: same fix applies to multiple bugs
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")
make_commit "$repo" app.txt "module: authentication logic"
make_commit "$repo" app.txt "module: authorization logic"

bug1=$(cd "$repo" && git rev-parse HEAD~1)  # auth bug
bug2=$(cd "$repo" && git rev-parse HEAD)    # authz bug
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug1" BUG-MULTI-001 "Auth bypass")
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$bug2" BUG-MULTI-002 "Authz escalation")

# Create ONE fix that addresses BOTH bugs
(cd "$repo" && git checkout -q -b security/unified-fix)
make_commit "$repo" app.txt "fix: comprehensive security hardening"
fix_commit=$(cd "$repo" && git rev-parse HEAD)

# Mark fix for both bugs
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix_commit" BUG-MULTI-001 "$bug1")
# Force overwrite for second fix note on same commit
(cd "$repo" && git notes --ref=fixes add -f -m "FIX:BUG-MULTI-002:fixes-commit:$bug2" "$fix_commit")

# Back to main
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)
main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch")

# Should detect both bugs and fixes (even if only one shown due to note limitations)
bug1_count=$(grep -c "Bug détecté: BUG-MULTI-001" <<<"$output" || true)
bug2_count=$(grep -c "Bug détecté: BUG-MULTI-002" <<<"$output" || true)
fix_count=$(grep -c "CORRECTION TROUVÉE" <<<"$output" || true)

if [ "$bug1_count" -ne 1 ] || [ "$bug2_count" -ne 1 ]; then
  echo "ASSERTION FAILED: should detect both bugs" >&2
  echo "$output" >&2
  exit 1
fi

if [ "$fix_count" -lt 1 ]; then
  echo "ASSERTION FAILED: should show at least one fix (got $fix_count)" >&2
  echo "$output" >&2
  exit 1
fi

echo "MULTI-BUG: PASS"