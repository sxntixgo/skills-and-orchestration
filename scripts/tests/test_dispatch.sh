#!/usr/bin/env bash
# Tests for plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh early exits: every exit
# (not only opencode's) must end with the "DISPATCH <id> exit=<rc> ..." line the skill reads.
# Does not start opencode. Run: bash scripts/tests/test_dispatch.sh
set -uo pipefail
DS="$(cd "$(dirname "$0")/../.." && pwd)/plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh"
tmp=$(mktemp -d); trap 'kill $sleeper 2>/dev/null; rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
fail=0
check() {  # check <name> <expected exit> <args...>
  local name=$1 want=$2 out rc last; shift 2
  out=$(cd "$tmp/repo" && bash "$DS" "$@" 2>/dev/null); rc=$?; last=$(tail -1 <<<"$out")
  if [[ $rc -eq $want && "$last" == "DISPATCH T1 exit=$want result=no log=-" ]]; then echo "ok   $name"
  else echo "FAIL $name: exit $rc, last line: $last"; fail=1; fi
}
mkdir -p "$tmp/repo" && cd "$tmp/repo" && git init -q -b main && git commit -q --allow-empty -m init

check "missing task file -> 2" 2 r1 T1

mkdir -p .orchestra/r1/tasks .orchestra/r1/running && echo "# task" > .orchestra/r1/tasks/T1.task.md
echo '{"concurrency":1}' > .orchestra/config.json
sleep 60 & sleeper=$!; echo $sleeper > .orchestra/r1/running/T0.pid
check "no free slot -> 3" 3 r1 T1

kill $sleeper 2>/dev/null; wait $sleeper 2>/dev/null
ORCHESTRA_LLM_URL=http://127.0.0.1:9/v1 check "model server unreachable -> 4" 4 r1 T1

exit $fail
