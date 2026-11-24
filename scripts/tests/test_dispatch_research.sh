#!/usr/bin/env bash
# Tests for plugins/orchestration/skills/claude-orchestrate-research/scripts/dispatch-research.sh.
# A stub `opencode` on PATH replays canned JSONL, so no model runs.
# Every exit must end with "DISPATCH <id> exit=<rc> findings=<yes|no> log=<path>" (the skill reads it).
# Run: bash scripts/tests/test_dispatch_research.sh
set -uo pipefail
DS="$(cd "$(dirname "$0")/../.." && pwd)/plugins/orchestration/skills/claude-orchestrate-research/scripts/dispatch-research.sh"
tmp=$(mktemp -d); sleeper=; trap '[[ -n $sleeper ]] && kill $sleeper 2>/dev/null; rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export DISPATCH_RETRY_S=0
unset ORCHESTRA_LLM_URL ORCHESTRA_LLM_TOKEN_FILE
fail=0
ok() { echo "ok   $1"; }
no() { echo "FAIL $1: $2"; fail=1; }

# stub opencode: records its args, then plays $STUB (answer | fenced | empty | locked-once | crash)
mkdir -p "$tmp/bin"
cat > "$tmp/bin/opencode" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$STUB_DIR/args"
n=$(( $(cat "$STUB_DIR/calls" 2>/dev/null || echo 0) + 1 )); echo $n > "$STUB_DIR/calls"
step='{"type":"step_start","sessionID":"ses_1"}'
case "$STUB" in
  answer)  echo "$step"; echo '{"type":"text","sessionID":"ses_1","part":{"text":"draft"}}'
           echo "$step"; echo '{"type":"text","sessionID":"ses_1","part":{"text":null}}'   # opencode 2 emits these
           echo '{"type":"text","sessionID":"ses_1","part":{"text":"## Findings\nA [1]"}}' ;;
  fenced)  echo "$step"; echo '{"type":"text","sessionID":"ses_1","part":{"text":"```markdown\n## Findings\nB\n```\n"}}' ;;
  empty)   echo "$step" ;;
  locked-once) if [[ $n == 1 ]]; then echo "Error: database is locked"; exit 1; fi
           echo "$step"; echo '{"type":"text","sessionID":"ses_1","part":{"text":"after retry"}}' ;;
  crash)   echo "Error: boom"; exit 7 ;;
esac
EOF
chmod +x "$tmp/bin/opencode"
export PATH="$tmp/bin:$PATH" STUB_DIR="$tmp"

mkdir -p "$tmp/repo" && cd "$tmp/repo" && git init -q -b main && git commit -q --allow-empty -m init

# run <name> <want rc> <want findings> [args...]  (default args: r1 T1)
run() {
  local name=$1 want=$2 wantf=$3 out rc last; shift 3; [[ $# -gt 0 ]] || set -- r1 T1
  rm -f "$tmp/calls"
  out=$(bash "$DS" "$@" 2>/dev/null); rc=$?; last=$(tail -1 <<<"$out")
  if [[ $rc -eq $want && "$last" =~ ^DISPATCH\ T1\ exit=$want\ findings=$wantf\ log= ]]; then ok "$name"
  else no "$name" "exit $rc, last line: $last"; fi
}
F=runs/r1/findings/T1.md

run "missing task file -> 2" 2 no

mkdir -p runs/r1/tasks runs/r1/running && echo "# sub-question" > runs/r1/tasks/T1.md
echo '{"concurrency":1}' > runs/config.json
sleep 60 & sleeper=$!; echo $sleeper > runs/r1/running/T0.pid
run "no free slot -> 3" 3 no
kill $sleeper 2>/dev/null; wait $sleeper 2>/dev/null; sleeper=

ORCHESTRA_LLM_URL=http://127.0.0.1:9/v1 run "model server unreachable -> 4" 4 no

STUB=answer run "answer -> 0, findings = text after the last step" 0 yes
[[ "$(cat $F)" == $'## Findings\nA [1]' ]] && ok "findings drop the earlier draft" || no "findings content" "$(cat $F)"
[[ "$(cat runs/r1/logs/T1.session 2>/dev/null)" == ses_1 ]] && ok "session id saved" || no "session id" "missing"
[[ ! -e runs/r1/running/T1.pid ]] && ok "slot released" || no "slot" "pid file left"

STUB=fenced run "fenced answer -> 0" 0 yes
[[ "$(cat $F)" == $'## Findings\nB' ]] && ok "outer markdown fence dropped" || no "fence" "$(cat $F)"

STUB=answer run "--continue -> 0" 0 yes r1 T1 --continue
grep -qx -- --session "$tmp/args" && grep -qx ses_1 "$tmp/args" && ok "--continue reuses the session" \
  || no "--continue" "no --session ses_1 in args"
[[ -f runs/r1/logs/T1.2.jsonl ]] && ok "new log per attempt" || no "log numbering" "$(ls runs/r1/logs)"

rm -f $F; STUB=empty run "empty answer -> findings=no" 0 no
[[ ! -e $F ]] && ok "no findings file for an empty answer" || no "empty" "file written"

STUB=locked-once run "database locked -> retried" 0 yes
[[ "$(cat "$tmp/calls")" == 2 ]] && ok "retried once" || no "retry count" "$(cat "$tmp/calls")"

STUB=crash run "opencode exit code passed through" 7 no

exit $fail
