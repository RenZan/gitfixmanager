#!/usr/bin/env bash
set -euo pipefail

# Common helpers for detector tests
# List of temp repos to cleanup
TEMP_REPOS=()

# Cleanup function
cleanup_temp_repos() {
  for repo in "${TEMP_REPOS[@]}"; do
    if [[ -d "$repo" ]]; then
      rm -rf "$repo" 2>/dev/null || true
    fi
  done
}

# Setup trap for cleanup on exit
trap cleanup_temp_repos EXIT

# Creates an isolated temp git repo, echoes path
create_temp_repo() {
  local dir
  dir=$(mktemp -d 2>/dev/null || mktemp -d -t gfmtest)
  (cd "$dir" && git init -q && git config user.name "Test" && git config user.email test@example.com)
  TEMP_REPOS+=("$dir")
  echo "$dir"
}

make_commit() {
  local repo=$1; shift
  local file=$1; shift
  local msg=$1; shift
  (cd "$repo" && echo "$(date +%s%N) $RANDOM" >> "$file" && git add "$file" && git commit -q -m "$msg")
}

add_bug_note() {
  local repo=$1; shift
  local commit=$1; shift
  local id=$1; shift
  local desc=$1; shift
  (cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-bug "$commit" "$id" "$desc" >/dev/null)
}

add_fix_note() {
  local repo=$1; shift
  local commit=$1; shift
  local bugid=$1; shift
  local bug_commit=$1; shift
  (cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" mark-fix "$commit" "$bugid" "$bug_commit" >/dev/null)
}

# Run detector check, capture stderr+stdout
run_check() {
  local repo=$1; shift
  local branch=$1; shift
  (cd "$repo" && "$GFM_ROOT/scripts/missing-fix-detector.sh" check "$branch" 2>&1 || true)
}

require_contains() {
  local hay=$1; shift
  local needle=$1; shift
  if ! grep -q --fixed-strings "$needle" <<<"$hay"; then
    echo "ASSERTION FAILED: missing '$needle'" >&2
    return 1
  fi
}

require_not_contains() {
  local hay=$1; shift
  local needle=$1; shift
  if grep -q --fixed-strings "$needle" <<<"$hay"; then
    echo "ASSERTION FAILED: found unexpected '$needle'" >&2
    return 1
  fi
}
