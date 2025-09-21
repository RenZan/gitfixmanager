#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

declare -a tests=(
  detector-basic.sh
  detector-negative.sh
  detector-propagation.sh
  detector-limit-enforcement.sh
  detector-patch-id.sh
  detector-pr-heuristic.sh
  detector-generic-filter.sh
  detector-retroactive.sh
  detector-performance.sh
  detector-multi-bug.sh
  detector-no-cherry-scan.sh
  detector-consistency.sh
  detector-branch-filter.sh
  detector-aggressive-detection.sh
)

total=${#tests[@]}
pass=0
fail=0
start_ts=$(date +%s)

echo "Running detector focused tests ($total)"
for t in "${tests[@]}"; do
  echo -n "-> $t ... "
  if bash "$t" >/tmp/out.$$ 2>&1; then
    echo "OK"
    pass=$((pass+1))
  else
    echo "FAIL"
    fail=$((fail+1))
    echo "----- OUTPUT ($t) -----"
    sed 's/^/| /' /tmp/out.$$ || true
    echo "------------------------"
  fi
  rm -f /tmp/out.$$
done

duration=$(( $(date +%s) - start_ts ))
echo "Summary: PASS=$pass FAIL=$fail TOTAL=$total in ${duration}s"
[ $fail -eq 0 ] || exit 1
