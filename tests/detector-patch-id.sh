#!/usr/bin/env bash
set -euo pipefail
GFM_ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$(dirname "$0")/detector-common.sh"
repo=$(create_temp_repo)
export GFM_ROOT

#############################################
# Scenario: cherry-pick sans -x (patch-id detection)
#############################################
(cd "$repo" && echo base > app.txt && git add app.txt && git commit -q -m "init")
make_commit "$repo" app.txt "feature: important security fix"
orig_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$orig_commit" BUG-PATCH-001 "Security vulnerability")

# Create fix on branch
(cd "$repo" && git checkout -q -b hotfix/security)
make_commit "$repo" app.txt "fix: resolve security issue"
fix_commit=$(cd "$repo" && git rev-parse HEAD)
(cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$fix_commit" BUG-PATCH-001 "$orig_commit")

# Cherry-pick WITHOUT -x to main (simulates manual cherry-pick)
(cd "$repo" && git checkout -q master 2>/dev/null || git checkout -q main)
(cd "$repo" && git cherry-pick --no-commit "$fix_commit" && git commit -m "fix: security patch applied manually")
cherry_commit=$(cd "$repo" && git rev-parse HEAD)

main_branch=$(cd "$repo" && (git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master))
output=$(run_check "$repo" "$main_branch")

# Should detect patch-id match and inherit fix note
if ! grep -q "Note héritée:" <<<"$output"; then
  echo "ASSERTION FAILED: missing note inheritance via patch-id" >&2
  echo "$output" >&2
  exit 1
fi

if ! grep -q "✅ Correction trouvée dans $main_branch" <<<"$output"; then
  echo "ASSERTION FAILED: should detect fix via patch-id" >&2
  echo "$output" >&2
  exit 1
fi

# Verify the cherry-pick commit actually got the fix note
(cd "$repo" && git notes --ref=fixes show "$cherry_commit" >/dev/null) || {
  echo "ASSERTION FAILED: cherry-pick commit should have inherited fix note" >&2
  exit 1
}

echo "PATCH-ID: PASS"