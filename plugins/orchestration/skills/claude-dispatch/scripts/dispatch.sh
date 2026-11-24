#!/usr/bin/env bash
# dispatch.sh — run ONE orchestration task with opencode in its own git worktree.
#
#   dispatch.sh <run> <id>            first attempt (creates .worktrees/<run>/<id>, branch orchestra/<run>/<id>)
#   dispatch.sh <run> <id> --continue send-back: same worktree, same opencode session, new attempt
#
# Run it from anywhere inside the target repo, in the background (it can take many minutes).
# Last line printed is always:  DISPATCH <id> exit=<rc> result=<yes|no> log=<path>
# Exit codes: 0 opencode finished (check result=), 2 usage/setup error, 3 no free slot,
#             4 llm endpoint unreachable, 124 timed out, 125 stalled (no log output, after retries),
#             other = opencode's own exit code.
set -uo pipefail

run="${1:-}"; id="${2:-}"; mode="${3:-}"
[[ -n "$run" && -n "$id" ]] || { echo "usage: dispatch.sh <run> <id> [--continue]" >&2; exit 2; }

# Every exit prints the DISPATCH line (also early ones: setup error 2, no slot 3, endpoint down 4).
die() { echo "$2" >&2; echo "DISPATCH $id exit=$1 result=no log=-"; exit "$1"; }
root="$(git rev-parse --show-toplevel 2>/dev/null)" || die 2 "not inside a git repo"
cd "$root"
dir=".orchestra/$run"; task="$root/$dir/tasks/$id.task.md"
[[ -f "$task" ]] || die 2 "missing $task"
mkdir -p "$dir/logs" "$dir/running"

cfg=".orchestra/config.json"
conf() { [[ -f "$cfg" ]] && jq -r --arg k "$1" '.[$k] // empty' "$cfg" 2>/dev/null; }
model="$(conf model)";            model="${model:-atlas/qwen3.8-flash-next}"
concurrency="$(conf concurrency)"; concurrency="${concurrency:-2}"
timeout_min="$(conf task_timeout_min)"; timeout_min="${timeout_min:-30}"
# Hang watchdog: kill a run whose log stays EMPTY for stall_empty_s (opencode never started a
# session: the 2026-11-21 T4 hang sat 30 min with an empty log), or stops GROWING for stall_s (long
# enough for a quiet npm install or test run). Then retry once (continuing the session if one exists).
stall_empty_s="$(conf stall_empty_s)"; stall_empty_s="${stall_empty_s:-180}"
stall_s="$(conf stall_s)";             stall_s="${stall_s:-600}"
stall_retries="$(conf stall_retries)"; stall_retries="${stall_retries:-1}"
poll_s="${DISPATCH_POLL_S:-15}"
base="$(conf base_branch)";       base="${base:-main}"

# Free slot? (pid files of dispatches still alive)
alive=0
for p in "$dir"/running/*.pid; do
  [[ -e "$p" ]] || continue
  if kill -0 "$(cat "$p")" 2>/dev/null; then alive=$((alive + 1)); else rm -f "$p"; fi
done
(( alive < concurrency )) || die 3 "no free slot ($alive running, concurrency $concurrency)"

# Endpoint up? Only when the model server is configured (the private devcontainers set both):
#   ORCHESTRA_LLM_URL         OpenAI-compatible base URL, e.g. http://localhost:1234/v1
#   ORCHESTRA_LLM_TOKEN_FILE  optional file holding its bearer token
if [[ -n "${ORCHESTRA_LLM_URL:-}" ]]; then
  auth=(); tok="${ORCHESTRA_LLM_TOKEN_FILE:-}"
  [[ -n "$tok" && -r "$tok" ]] && auth=(-H "Authorization: Bearer $(cat "$tok")")
  code=$(curl -s -o /dev/null -m 15 -w '%{http_code}' ${auth[@]+"${auth[@]}"} "${ORCHESTRA_LLM_URL%/}/models")
  [[ "$code" == 200 ]] || die 4 "model server answered $code"
fi

# Worktree
wt="$root/.worktrees/$run/$id"; branch="orchestra/$run/$id"
grep -qxF '.orchestra/' .git/info/exclude 2>/dev/null || printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
if [[ "$mode" != "--continue" ]]; then
  [[ -e "$wt" ]] && die 2 "$wt exists; use --continue or remove it"
  git worktree add -q -b "$branch" "$wt" "$base" || die 2 "git worktree add failed"
else
  [[ -d "$wt" ]] || die 2 "no worktree $wt to continue"
  rm -f "$wt/RESULT.md"
fi

n=$(ls "$dir/logs/$id".*.jsonl 2>/dev/null | wc -l | tr -d ' '); n=$((n + 1))
log="$root/$dir/logs/$id.$n.jsonl"
session_args=()
if [[ "$mode" == "--continue" && -s "$dir/logs/$id.session" ]]; then
  session_args=(--session "$(cat "$dir/logs/$id.session")")
  msg="The task file was updated after review (see 'Notes from review'). Fix those points, rerun the task's test command, then rewrite RESULT.md."
else
  msg="Implement the attached task. Use the opencode-develop skill; it ends with writing RESULT.md."
fi

tmo=()
command -v timeout >/dev/null && tmo=(timeout "${timeout_min}m")

echo $$ > "$dir/running/$id.pid"

fsize()  { stat -c %s "$1" 2>/dev/null || stat -f %z "$1"; }
fmtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1"; }
# Run opencode once in the background and watch its log. Sets rc (125 = killed as stalled).
run_once() {
  local start now size grp=()
  command -v setsid >/dev/null && grp=(setsid)     # own process group: the kill reaches its tools too
  "${grp[@]}" "${tmo[@]}" opencode run --agent implementer --model "$model" --format json --dir "$wt" \
    --title "$run/$id#$n" "${session_args[@]}" "$msg" -f "$task" > "$log" 2>&1 &   # -f is greedy: keep it last
  local opid=$! stalled=0
  start=$(date +%s)
  while kill -0 "$opid" 2>/dev/null; do
    sleep "$poll_s"; now=$(date +%s); size=$(fsize "$log")
    if { [[ "$size" -eq 0 ]] && (( now - start >= stall_empty_s )); } ||
       { [[ "$size" -gt 0 ]] && (( now - $(fmtime "$log") >= stall_s )); }; then
      stalled=1
      if [[ ${#grp[@]} -gt 0 ]]; then kill -TERM -- "-$opid" 2>/dev/null; else kill -TERM "$opid" 2>/dev/null; fi
      sleep 5; kill -KILL -- "-$opid" 2>/dev/null || kill -KILL "$opid" 2>/dev/null
      break
    fi
  done
  wait "$opid" 2>/dev/null; rc=$?
  (( stalled )) && rc=125
  return 0
}

# Retries: opencode keeps its state in SQLite, so two runs starting at the same moment can fail with
# "database is locked" before a session exists (up to 3 tries, random pause); a stalled run is
# retried stall_retries times (its log kept as <log>.stalled-<k>).
locked_tries=0; stalls=0
while :; do
  run_once
  if [[ $rc -eq 125 ]]; then
    stalls=$((stalls + 1))
    echo "stalled (no log output: empty ${stall_empty_s}s / quiet ${stall_s}s), killed" >&2
    (( stalls > stall_retries )) && break
    mv "$log" "$log.stalled-$stalls"
    sid=$(grep -o '"sessionID":"[^"]*"' "$log.stalled-$stalls" | head -1 | cut -d'"' -f4)
    [[ -n "$sid" ]] && session_args=(--session "$sid")
    continue
  fi
  if ! grep -q '"sessionID"' "$log" && grep -q "database is locked" "$log" && (( ++locked_tries < 3 )); then
    sleep $((3 + RANDOM % 8)); continue
  fi
  break
done
rm -f "$dir/running/$id.pid"

sid=$(grep -o '"sessionID":"[^"]*"' "$log" | head -1 | cut -d'"' -f4)
[[ -n "$sid" ]] && echo "$sid" > "$dir/logs/$id.session"
res=no; [[ -s "$wt/RESULT.md" ]] && res=yes
echo "DISPATCH $id exit=$rc result=$res log=$log"
exit "$rc"
