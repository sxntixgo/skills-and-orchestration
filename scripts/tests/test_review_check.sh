#!/usr/bin/env bash
# Tests for plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh
# Builds a throwaway repo with one orchestration task and worktree, then checks the verdict line
# and exit code for: a clean pass, an out-of-scope file, a failing task test, and a task with no
# test command. Run: bash scripts/tests/test_review_check.sh
set -uo pipefail
RC="$(cd "$(dirname "$0")/../.." && pwd)/plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
fail=0
check() {  # check <name> <expected exit> <expected substring of last line>
  local out rc last; out=$(cd "$tmp/repo" && bash "$RC" r1 T1 2>&1); rc=$?; last=$(tail -1 <<<"$out")
  if [[ $rc -eq $2 && "$last" == *"$3"* ]]; then echo "ok   $1"; else echo "FAIL $1: exit $rc, last: $last"; fail=1; fi
}

mkdir -p "$tmp/repo" && cd "$tmp/repo" && git init -q -b main && git commit -q --allow-empty -m init
mkdir -p .orchestra/r1/tasks
echo '{"test_cmd":"test -f a.txt && echo 3 passed","lint_cmd":"true"}' > .orchestra/config.json
cat > .orchestra/r1/tasks/T1.task.md <<'EOF'
---
id: T1
---
# goal
## Files
- may change: `src/x.py`, tests/*.py
- may create: a.txt
## Done when
- `grep -q hello a.txt && echo "1 passed"` passes
## Out of scope
EOF
printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
git worktree add -q -b orchestra/r1/T1 .worktrees/r1/T1 main
wt=.worktrees/r1/T1

echo hello > $wt/a.txt; echo done > $wt/RESULT.md
check "clean pass" 0 "scope=ok result=yes task=pass suite=pass lint=pass"

mkdir -p $wt/other && echo x > $wt/other/y.py
check "out-of-scope file" 1 "scope=1-out"
rm -rf $wt/other

echo bye > $wt/a.txt
check "failing task test" 1 "task=fail"
echo hello > $wt/a.txt

sed -i.bak '/^## Done when/,/^## Out/{/`/d;}' .orchestra/r1/tasks/T1.task.md
check "no task test command" 1 "task=none"

exit $fail
