#!/usr/bin/env bash
# review-check.sh — the mechanical half of a review, with compact output so it costs few tokens.
#
#   review-check.sh <run> <id>
#
# In .worktrees/<run>/<id>: scope check (changed files vs the task's "may change/create" list),
# the task's test command (first `command` under "## Done when"), then the repo's full test suite
# and lint from .orchestra/config.json (test_cmd, lint_cmd) when set. Prints only summaries and,
# for a failing command, its last 25 lines. Last line is always:
#   CHECK <id> scope=<ok|N-out> result=<yes|no> task=<pass|fail|none> suite=<pass|fail|skip> lint=<pass|fail|skip>
# Exit 0 when everything that ran passed and scope is clean, else 1; 2 = usage/setup error.
set -uo pipefail

run="${1:-}"; id="${2:-}"
[[ -n "$run" && -n "$id" ]] || { echo "usage: review-check.sh <run> <id>" >&2; exit 2; }
root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not inside a git repo" >&2; exit 2; }
cd "$root"
task="$root/.orchestra/$run/tasks/$id.task.md"; wt="$root/.worktrees/$run/$id"
[[ -f "$task" ]] || { echo "missing $task" >&2; exit 2; }
[[ -d "$wt" ]] || { echo "missing worktree $wt" >&2; exit 2; }

cfg=".orchestra/config.json"
conf() { [[ -f "$cfg" ]] && jq -r --arg k "$1" '.[$k] // empty' "$cfg" 2>/dev/null; }
test_cmd="$(conf test_cmd)"; lint_cmd="$(conf lint_cmd)"
tmo=(); command -v timeout >/dev/null && tmo=(timeout 20m)

# Allowed files: the "may change:" and "may create:" lines (comma/space separated, backticks ok, globs ok)
allowed=$(grep -iE '^[[:space:]]*-[[:space:]]*may (change|create):' "$task" | sed -E 's/^[^:]*://' | tr -d '`' | tr ',' ' ')
# Task test command: first `...` on the lines under "## Done when"
task_cmd=$(awk '/^## Done when/{f=1;next} /^## /{f=0} f' "$task" | grep -o '`[^`]*`' | head -1 | tr -d '`')

ok=1
# --- scope
out=()
while IFS= read -r f; do
  [[ -z "$f" || "$f" == "RESULT.md" ]] && continue
  hit=0
  for a in $allowed; do
    # shellcheck disable=SC2053
    [[ "$f" == $a || "$f" == "$a"/* ]] && { hit=1; break; }
  done
  (( hit )) || out+=("$f")
done < <(git -C "$wt" status --porcelain --untracked-files=all | sed -E 's/^.{3}//; s/.* -> //')
if (( ${#out[@]} )); then scope="${#out[@]}-out"; ok=0; echo "SCOPE out of scope: ${out[*]}"; else scope=ok; echo "SCOPE ok"; fi
new=$(git -C "$wt" ls-files --others --exclude-standard | grep -vcx 'RESULT.md')
st=$(git -C "$wt" --no-pager diff HEAD --shortstat | sed 's/^ //')
echo "DIFF tracked: ${st:-none}; new files: $new"
res=no; [[ -s "$wt/RESULT.md" ]] && res=yes

# --- commands
runc() {  # runc <label> <command>: prints one status line (+ tail on failure), sets last
  local label="$1" cmd="$2" outf rc
  outf=$(mktemp); (cd "$wt" && ${tmo[@]+"${tmo[@]}"} bash -c "$cmd") >"$outf" 2>&1; rc=$?
  if (( rc == 0 )); then last=pass; echo "$label pass: $(grep -E '[0-9]+ (passed|failed|tests?)|^ok |PASS|FAIL' "$outf" | tail -2 | tr '\n' ' ' | cut -c1-200)"
  else last=fail; ok=0; echo "$label FAIL rc=$rc ($cmd), last 25 lines:"; tail -25 "$outf"; fi
  rm -f "$outf"
}
if [[ -n "$task_cmd" ]]; then runc TASK "$task_cmd"; t=$last; else t=none; ok=0; echo "TASK none: no \`command\` under '## Done when'"; fi
if [[ -n "$test_cmd" && "$test_cmd" != "$task_cmd" ]]; then runc SUITE "$test_cmd"; s=$last; else s=skip; fi
if [[ -n "$lint_cmd" ]]; then runc LINT "$lint_cmd"; l=$last; else l=skip; fi

echo "CHECK $id scope=$scope result=$res task=$t suite=$s lint=$l"
(( ok )) && exit 0 || exit 1
