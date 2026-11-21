---
name: orchestrate
description: Runs a feature or plan as a set of small tasks implemented by opencode (a local model) in separate git worktrees, with Claude planning, dispatching, reviewing and merging. Use when the user asks to orchestrate, delegate implementation to opencode, or build a planned feature with Claude as orchestrator and opencode as implementor.
---

# Orchestrate

Claude is the orchestrator and reviewer; opencode is the implementor. You turn a plan into
small tasks, hand them out, check every result, and merge. The file formats are in
`../../contract.md` (relative to this skill's base directory): read it first.

## Scope
This skill DOES:
- Split a plan into tasks with dependencies and **file ownership** (no two tasks that may run
  at the same time change the same file).
- Pick the implementer per task: opencode by default; Claude itself for tasks that are tiny,
  cross-cutting, security-sensitive, or need judgment the local model lacks.
- Drive the loop write → dispatch → review → merge, within `concurrency` from config.
- Keep `.orchestra/<run>/board.md` current so the run can resume in a later session.

This skill does NOT:
- Write each task's text (→ `write-task-spec`), run opencode (→ `dispatch-opencode`), or judge
  a result (→ `review-and-merge`). Use those.
- Push, open PRs, or deploy. The user does that (or asks for it separately).
- Invent requirements. Unclear plan → ask.

## Required steps (one TodoWrite item each)
1. **Set up the run.** Read the plan (or the user's request) and the repo's `CLAUDE.md`/`AGENTS.md`.
   Create `.orchestra/<run>/` (run = `YYYY-MM-DD-<slug>`), add `.orchestra/` and `.worktrees/`
   to `.git/info/exclude`, read or create `.orchestra/config.json` (contract defaults).
   Check: working tree clean on `base_branch`; the repo's test command works. ⛔ STOP if not.
2. **Task graph.** Write `board.md`: a table `id | goal | implementer | depends_on | files | status`
   (status: todo, dispatched, review, sent-back, merged, taken-over, dropped) and an empty `## Log`.
   Tasks are small: one module or endpoint plus its tests; ≤ ~5 files; one test command.
   ⛔ STOP: show the table to the user and wait for approval before dispatching anything.
3. **Loop until every task is merged or dropped.**
   - Ready tasks = dependencies merged. Take up to `concurrency` of them whose files don't overlap
     with any task currently dispatched.
   - For each: `write-task-spec` → `dispatch-opencode` (or implement it yourself if marked Claude).
   - When a run finishes: `review-and-merge`. Rejected → back to dispatch with review notes
     (attempt + 1). After `max_sendbacks` rejections: take it over yourself and mark `taken-over`.
   - After every state change: update `board.md` (table + one Log line with time and outcome).
4. **Finish.** All tests pass on `base_branch`; worktrees and `orchestra/*` branches removed.
   Report: tasks by outcome (opencode first try / after send-back / taken over), commits,
   test results, anything left for the user (push, deploy, follow-ups).

## Resuming
Read `board.md`. For `dispatched` tasks check whether the run is still going (log growing,
process alive) or finished (RESULT.md in the worktree). Continue the loop from there.

## Red flags
| If you notice… | Do this |
|---|---|
| Dispatching before the user approved the task table | Stop; show the table |
| Two concurrent tasks list the same file | Serialize them (add a dependency) |
| A task that needs "and also…" to describe | Split it |
| More running tasks than `concurrency` | Wait; atlas serves one request at a time by default |
| Merging on RESULT.md's word | Never; `review-and-merge` runs the tests itself |
| A third attempt for the same task | Take it over yourself |
| About to push or deploy | Don't; report it as a step for the user |

## Done when
- Every task in `board.md` is merged, taken-over or dropped (with reason).
- The full test suite passes on `base_branch`; no worktrees or `orchestra/*` branches remain.
- You reported outcomes per task and what the user still has to do.
