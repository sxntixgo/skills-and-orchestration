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
- Ask the user to approve the task graph. Planning is your job: make it effective and efficient
  and go. Ask only when the goal itself is ambiguous (two reasonable readings that lead to
  different features).

## Required steps (one TodoWrite item each)
1. **Set up the run.** Read the plan (or the user's request) and the repo's `CLAUDE.md`/`AGENTS.md`.
   Create `.orchestra/<run>/` (run = `YYYY-MM-DD-<slug>`), add `.orchestra/` and `.worktrees/`
   to `.git/info/exclude`, read or create `.orchestra/config.json` (contract defaults).
   Check: working tree clean on `base_branch`; the repo's test command works. ⛔ STOP if not.
2. **Task graph** (no user approval: plan well and proceed). Write `board.md`: a table
   `id | goal | implementer | depends_on | files | status` (status: todo, dispatched, review,
   sent-back, merged, taken-over, dropped) and an empty `## Log`.
   - Small tasks: one module or endpoint plus its tests; ≤ ~5 files; one test command.
   - **Efficient:** as few tasks as the work allows; no task without a user-visible or tested
     outcome (YAGNI); shared code is its own early task so later tasks reuse it (DRY).
   - **Parallel:** give tasks disjoint files so up to `concurrency` run at once, each in its own
     worktree; add a dependency only where one task truly needs another's code.
   - Self-check before dispatching: every requirement maps to a task; no two concurrent tasks share
     a file; every task has an exact test command. Fix the graph, then go.
3. **Loop until every task is merged or dropped.**
   - Ready tasks = dependencies merged. Take up to `concurrency` of them whose files don't overlap
     with any task currently dispatched.
   - For each: `write-task-spec` → `dispatch-opencode` (or implement it yourself if marked Claude).
   - When a run finishes: `review-and-merge`. Rejected → back to dispatch with review notes
     (attempt + 1). After `max_rejections` (default 3) rejections: `review-and-merge` takes it
     over with the cheapest capable Claude model and marks it `taken-over`.
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
| Waiting for the user to approve the task table | Don't; plan carefully and dispatch |
| A task with no test or no observable outcome | Merge it into another task or drop it (YAGNI) |
| Two concurrent tasks list the same file | Serialize them (add a dependency) |
| A task that needs "and also…" to describe | Split it |
| More running tasks than `concurrency` | Wait; more runs than atlas's slots only queue |
| Merging on RESULT.md's word | Never; `review-and-merge` runs the tests itself |
| A fourth dispatch of the same task | Stop: after 3 rejections it's a takeover |
| About to push or deploy | Don't; report it as a step for the user |

## Done when
- Every task in `board.md` is merged, taken-over or dropped (with reason).
- The full test suite passes on `base_branch`; no worktrees or `orchestra/*` branches remain.
- You reported outcomes per task and what the user still has to do.
