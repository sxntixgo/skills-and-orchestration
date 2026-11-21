---
name: dispatch-opencode
description: Sends one written task.md to opencode (the implementer, on a local model) in its own git worktree, in the background, and collects its result. Use when an orchestration task is ready to run, or a reviewed task must go back to opencode with review notes.
---

# Dispatch to opencode

Runs `scripts/dispatch.sh` (in this skill's base directory). Formats and rules:
`../../contract.md`.

## Scope
DOES: start one opencode run per task, in `.worktrees/<id>` on branch `orchestra/<run>/<id>`,
respecting `concurrency`; resume the same opencode session on a send-back; report how it ended.
Does NOT: write the task (→ `write-task-spec`), judge or merge the result (→ `review-and-merge`).

## Required steps
1. **Preconditions.** The task file exists; its `depends_on` are merged into `base_branch`;
   none of its files are owned by a task still dispatched. Otherwise don't dispatch.
2. **Start it in the background** (Bash `run_in_background: true`; never wait in the foreground):
   - first attempt: `bash <skill-dir>/scripts/dispatch.sh <run> <id>`
   - send-back: `bash <skill-dir>/scripts/dispatch.sh <run> <id> --continue`
   Mark the task `dispatched` (attempt n) in `board.md` with the start time.
3. **While it runs,** do other orchestration work (write the next spec, review another result).
   Don't poll; you'll be notified when the command exits.
4. **Read the last line** `DISPATCH <id> exit=<rc> result=<yes|no> log=<path>`:
   | Outcome | Next |
   |---|---|
   | exit=0, result=yes | `review-and-merge` |
   | exit=0, result=no | Treat as rejected: send back once with "write RESULT.md"; check the log tail first |
   | exit=3 (no free slot) | Wait for a running task to finish, then retry |
   | exit=4 (llm unreachable) | Check atlas/ops (Gatus); pause dispatching; tell the user |
   | exit=124 (timeout) | Read the log tail; split the task or take it over |
   | other | Read the log tail (`tail -50 <log>`); fix setup or take it over |
   Log the outcome in `board.md`.

## Red flags
| If you notice… | Do this |
|---|---|
| Running dispatch.sh in the foreground | Background it; runs take minutes |
| Starting more runs than `concurrency` | The script refuses (exit 3); respect it |
| Editing files inside a worktree while opencode runs there | Don't; wait for the exit |
| Reading the whole JSONL log into context | Use `tail`/`grep` on it |
| A new worktree for a send-back | Use `--continue` (same worktree, same session) |

## Done when
The run exited, its outcome is logged in `board.md`, and the next skill (review, retry or
takeover) is chosen.
