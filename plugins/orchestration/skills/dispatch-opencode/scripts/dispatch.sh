#!/usr/bin/env bash
# dispatch.sh — run ONE orchestration task with opencode in its own git worktree.
#
#   dispatch.sh <run> <id>            first attempt (creates .worktrees/<id>, branch orchestra/<run>/<id>)
#   dispatch.sh <run> <id> --continue send-back: same worktree, same opencode session, new attempt
#
# Run it from anywhere inside the target repo, in the background (it can take many minutes).
# Last line printed is always:  DISPATCH <id> exit=<rc> result=<yes|no> log=<path>
# Exit codes: 0 opencode finished (check result=), 2 usage/setup error, 3 no free slot,
#             4 llm endpoint unreachable, 124 timed out, other = opencode's own exit code.
set -uo pipefail

run="${1:-}"; id="${2:-}"; mode="${3:-}"
[[ -n "$run" && -n "$id" ]] || { echo "usage: dispatch.sh <run> <id> [--continue]" >&2; exit 2; }

root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not inside a git repo" >&2; exit 2; }
cd "$root"
dir=".orchestra/$run"; task="$root/$dir/tasks/$id.task.md"
[[ -f "$task" ]] || { echo "missing $task" >&2; exit 2; }
mkdir -p "$dir/logs" "$dir/running"

cfg=".orchestra/config.json"
conf() { [[ -f "$cfg" ]] && jq -r --arg k "$1" '.[$k] // empty' "$cfg" 2>/dev/null; }
model="$(conf model)";            model="${model:-atlas/qwen3.8-flash-next}"
concurrency="$(conf concurrency)"; concurrency="${concurrency:-1}"
timeout_min="$(conf task_timeout_min)"; timeout_min="${timeout_min:-30}"
base="$(conf base_branch)";       base="${base:-main}"

# Free slot? (pid files of dispatches still alive)
alive=0
for p in "$dir"/running/*.pid; do
  [[ -e "$p" ]] || continue
  if kill -0 "$(cat "$p")" 2>/dev/null; then alive=$((alive + 1)); else rm -f "$p"; fi
done
(( alive < concurrency )) || { echo "no free slot ($alive running, concurrency $concurrency)" >&2; exit 3; }

# Endpoint up? (only when the atlas token is mounted, as in the devcontainers)
tok=/opt/secrets/atlas-token
if [[ -r "$tok" ]]; then
  code=$(curl -s -o /dev/null -m 15 -w '%{http_code}' -H "Authorization: Bearer $(cat "$tok")" \
    https://llm.example.internal/v1/models)
  [[ "$code" == 200 ]] || { echo "llm.h answered $code" >&2; exit 4; }
fi

# Worktree
wt="$root/.worktrees/$id"; branch="orchestra/$run/$id"
grep -qxF '.orchestra/' .git/info/exclude 2>/dev/null || printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
if [[ "$mode" != "--continue" ]]; then
  [[ -e "$wt" ]] && { echo "$wt exists; use --continue or remove it" >&2; exit 2; }
  git worktree add -q -b "$branch" "$wt" "$base" || exit 2
else
  [[ -d "$wt" ]] || { echo "no worktree $wt to continue" >&2; exit 2; }
  rm -f "$wt/RESULT.md"
fi

n=$(ls "$dir/logs/$id".*.jsonl 2>/dev/null | wc -l | tr -d ' '); n=$((n + 1))
log="$root/$dir/logs/$id.$n.jsonl"
session_args=()
if [[ "$mode" == "--continue" && -s "$dir/logs/$id.session" ]]; then
  session_args=(--session "$(cat "$dir/logs/$id.session")")
  msg="The task file was updated after review (see 'Notes from review'). Fix those points, rerun the task's test command, then rewrite RESULT.md."
else
  msg="Implement the attached task. Use the implement-task skill, then write RESULT.md with the report-result skill."
fi

tmo=()
command -v timeout >/dev/null && tmo=(timeout "${timeout_min}m")

echo $$ > "$dir/running/$id.pid"
"${tmo[@]}" opencode run --agent implementer --model "$model" --format json --dir "$wt" \
  --title "$run/$id#$n" "${session_args[@]}" "$msg" -f "$task" > "$log" 2>&1   # -f is greedy: keep it last
rc=$?
rm -f "$dir/running/$id.pid"

sid=$(grep -o '"sessionID":"[^"]*"' "$log" | head -1 | cut -d'"' -f4)
[[ -n "$sid" ]] && echo "$sid" > "$dir/logs/$id.session"
res=no; [[ -s "$wt/RESULT.md" ]] && res=yes
echo "DISPATCH $id exit=$rc result=$res log=$log"
exit "$rc"
