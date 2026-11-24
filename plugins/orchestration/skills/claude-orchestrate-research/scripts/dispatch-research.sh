#!/usr/bin/env bash
# dispatch-research.sh — run ONE research sub-question with an opencode researcher.
#
#   dispatch-research.sh <run> <id>              first attempt
#   dispatch-research.sh <run> <id> --continue   re-dispatch with review notes (same opencode session)
#
# Run inside the research workspace (repo root or below), in the background.
# Reads runs/<run>/tasks/<id>.md; writes the researcher's final answer to runs/<run>/findings/<id>.md.
# The researcher can't write files: its last message IS the findings.
# Last line: DISPATCH <id> exit=<rc> findings=<yes|no> log=<path>
# Exit: 0 finished, 2 usage/setup, 3 no free slot, 4 llm unreachable, 124 timeout, other = opencode's.
set -uo pipefail
run="${1:-}"; id="${2:-}"; mode="${3:-}"
[[ -n "$run" && -n "$id" ]] || { echo "usage: dispatch-research.sh <run> <id> [--continue]" >&2; exit 2; }
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$root"
dir="runs/$run"; task="$root/$dir/tasks/$id.md"
[[ -f "$task" ]] || { echo "missing $task" >&2; exit 2; }
mkdir -p "$dir/logs" "$dir/findings" "$dir/running"

cfg="runs/config.json"
conf() { [[ -f "$cfg" ]] && jq -r --arg k "$1" '.[$k] // empty' "$cfg" 2>/dev/null; }
model="$(conf model)";                 model="${model:-atlas/qwen3.8-flash-next}"
concurrency="$(conf concurrency)";     concurrency="${concurrency:-3}"
timeout_min="$(conf task_timeout_min)"; timeout_min="${timeout_min:-25}"

alive=0
for p in "$dir"/running/*.pid; do
  [[ -e "$p" ]] || continue
  if kill -0 "$(cat "$p")" 2>/dev/null; then alive=$((alive + 1)); else rm -f "$p"; fi
done
(( alive < concurrency )) || { echo "no free slot ($alive running, concurrency $concurrency)" >&2; exit 3; }

# Endpoint up? Only when the model server is configured (the private devcontainers set both):
#   ORCHESTRA_LLM_URL         OpenAI-compatible base URL, e.g. http://localhost:1234/v1
#   ORCHESTRA_LLM_TOKEN_FILE  optional file holding its bearer token
if [[ -n "${ORCHESTRA_LLM_URL:-}" ]]; then
  auth=(); tok="${ORCHESTRA_LLM_TOKEN_FILE:-}"
  [[ -n "$tok" && -r "$tok" ]] && auth=(-H "Authorization: Bearer $(cat "$tok")")
  code=$(curl -s -o /dev/null -m 15 -w '%{http_code}' ${auth[@]+"${auth[@]}"} "${ORCHESTRA_LLM_URL%/}/models")
  [[ "$code" == 200 ]] || { echo "model server answered $code" >&2; exit 4; }
fi

n=$(ls "$dir/logs/$id".*.jsonl 2>/dev/null | wc -l | tr -d ' '); n=$((n + 1))
log="$root/$dir/logs/$id.$n.jsonl"
session_args=()
if [[ "$mode" == "--continue" && -s "$dir/logs/$id.session" ]]; then
  session_args=(--session "$(cat "$dir/logs/$id.session")")
  msg="The task file now has 'Notes from review'. Address every note (search and read more where needed), then reply with the COMPLETE findings again in the opencode-research format."
else
  msg="Research the attached sub-question with the opencode-research skill. Your final reply must be the findings in that skill's format, nothing else."
fi
tmo=(); command -v timeout >/dev/null && tmo=(timeout "${timeout_min}m")

echo $$ > "$dir/running/$id.pid"
# opencode keeps its state in SQLite: two runs starting at the same moment can fail with
# "database is locked" before a session exists. Retry those (only those) after a random pause.
for try in 1 2 3; do
  "${tmo[@]}" opencode run --agent researcher --model "$model" --format json --dir "$root/$dir" \
  --title "research $run/$id#$n" "${session_args[@]}" "$msg" -f "$task" > "$log" 2>&1   # -f last: greedy
  rc=$?
  grep -q '"sessionID"' "$log" || ! grep -q "database is locked" "$log" || [[ $try == 3 ]] && break
  sleep $((3 + RANDOM % 8))
done
rm -f "$dir/running/$id.pid"

sid=$(grep -o '"sessionID":"[^"]*"' "$log" | head -1 | cut -d'"' -f4)
[[ -n "$sid" ]] && echo "$sid" > "$dir/logs/$id.session"
# Final answer = the text parts after the last step_start
out=$(grep '^{' "$log" | jq -rs '(map(.type) | rindex("step_start")) as $i
        | if $i == null then "" else (.[$i:] | map(select(.type == "text") | .part.text) | join("")) end' 2>/dev/null)
f=no
# Models sometimes wrap the whole reply in a ```markdown fence: drop an outer fence only.
out=$(printf '%s\n' "$out" | awk 'NF && !s {s=1; if ($0 ~ /^```/) next} {l[++n]=$0}
  END {while (n && l[n] ~ /^[[:space:]]*$/) n--; if (n && l[n] ~ /^```[[:space:]]*$/) n--; for (i=1;i<=n;i++) print l[i]}')
if [[ -n "${out//[[:space:]]/}" ]]; then printf '%s\n' "$out" > "$dir/findings/$id.md"; f=yes; fi
echo "DISPATCH $id exit=$rc findings=$f log=$log"
exit "$rc"
