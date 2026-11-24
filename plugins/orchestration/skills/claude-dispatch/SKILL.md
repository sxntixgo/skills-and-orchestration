---
name: claude-dispatch
description: Sends one written task.md to opencode (the implementer, on a local model) in its own git worktree, in the background, and collects its result. Use when an orchestration task is ready to run, or a reviewed task must go back to opencode with review notes.
---

# Dispatch to opencode

Runs `scripts/dispatch.sh` (in this skill's base directory). Everything you need is on this
page: don't open the script or `contract.md`.

## Scope
DOES: start one opencode run per task, in `.worktrees/<run>/<id>` on branch `orchestra/<run>/<id>`,
within `concurrency`; resume the same opencode session on a send-back; report how it ended.
Does NOT: write the task (→ `claude-write-task`), judge or merge the result (→ `claude-review-merge`).

## Steps
1. **Preconditions.** The task file exists; its `depends_on` are merged into `base_branch`; no
   task still dispatched owns any of its files. Otherwise don't dispatch.
2. **Start it in the background** (Bash `run_in_background: true`; runs take minutes):
   first attempt `bash <skill-dir>/scripts/dispatch.sh <run> <id>`; send-back
   `bash <skill-dir>/scripts/dispatch.sh <run> <id> --continue` (same worktree, same opencode
   session; never a new worktree). Mark the task `dispatched` (attempt n, start time) in `board.md`.
3. **While it runs,** do other orchestration work. Don't poll; the exit notifies you.
4. **Read only the last line** `DISPATCH <id> exit=<rc> result=<yes|no> log=<path|->`:
   | Outcome | Meaning → next |
   |---|---|
   | exit=0, result=yes | finished → `claude-review-merge` |
   | exit=0, result=no | no RESULT.md → check the log tail, send back once with "write RESULT.md" |
   | exit=2 | setup error (missing task, worktree exists/missing) → fix it, redispatch |
   | exit=3 | no free slot → wait for a running task, retry |
   | exit=4 | **the model server (LLM endpoint) is unreachable** → pause all dispatching, check the server / ops status, tell the user; don't retry in a loop |
   | exit=124 | timeout → read the log tail; split the task or take it over |
   | exit=125 | stalled and already retried → check the model server before one more try; else pause and tell the user |
   | other | opencode's own error → `tail -50 <log>`; fix setup or take over |
   Log the outcome in `board.md`.

## Red flags
| If you notice… | Do this |
|---|---|
| dispatch.sh in the foreground | Background it |
| More runs than `concurrency` | The script refuses (exit 3); respect it |
| Editing a worktree while opencode runs there | Wait for the exit |
| Editing dispatch.sh while a dispatch runs | Don't: bash reads it as it runs |
| Reading the whole JSONL log | `tail`/`grep` it |
| A new worktree for a send-back | `--continue` |

## Done when
The run exited, its outcome is in `board.md`, and the next step (review, retry, takeover) is chosen.
