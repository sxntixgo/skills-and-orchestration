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

# Startup failure (opencode 2, two runs starting at once): the first try dies with an empty
# sessionID; dispatch keeps that log and retries. Stub opencode: fails <fails> times, then works.
mkdir -p "$tmp/bin"
cat > "$tmp/bin/opencode" <<'EOF'
#!/usr/bin/env bash
n=$(( $(cat "$STUB_COUNT" 2>/dev/null || echo 0) + 1 )); echo $n > "$STUB_COUNT"
if (( n <= STUB_FAILS )); then
  echo '{"type":"error","timestamp":1,"sessionID":"","error":{"type":"unknown","message":"Standalone server exited before reporting readiness"}}'
  exit 1
fi
echo '{"type":"step_start","timestamp":2,"sessionID":"ses_stub1","part":{}}'
echo done > RESULT.md
EOF
chmod +x "$tmp/bin/opencode"
git add -A >/dev/null 2>&1; git commit -q -m fixture >/dev/null 2>&1
startfail() {  # startfail <name> <fails> <want exit> <want result> <want tries>
  local name=$1 out rc last tries
  rm -rf .worktrees/r1/T1 .orchestra/r1/logs; git worktree prune; git branch -qD orchestra/r1/T1 2>/dev/null
  echo 0 > "$tmp/count"
  out=$(PATH="$tmp/bin:$PATH" STUB_COUNT="$tmp/count" STUB_FAILS=$2 DISPATCH_RETRY_S=0 DISPATCH_POLL_S=1 \
    bash "$DS" r1 T1 2>/dev/null); rc=$?; last=$(tail -1 <<<"$out"); tries=$(cat "$tmp/count")
  if [[ $rc -eq $3 && "$last" == "DISPATCH T1 exit=$3 result=$4 log="* && $tries -eq $5 ]]; then echo "ok   $name"
  else echo "FAIL $name: exit $rc, tries $tries, last line: $last"; fail=1; fi
}
startfail "start failure retried, then works -> 0" 1 0 yes 2
[[ -f .orchestra/r1/logs/T1.1.jsonl.startfail-1 && "$(cat .orchestra/r1/logs/T1.session)" == ses_stub1 ]] &&
  echo "ok   failed start log kept, real session recorded" || { echo "FAIL startfail log/session"; fail=1; }
startfail "start failure 3 times -> gives up with opencode's exit" 5 1 no 3

exit $fail
