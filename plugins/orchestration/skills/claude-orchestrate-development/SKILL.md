---
name: claude-orchestrate-development
description: Runs a feature or plan as a set of small tasks implemented by opencode (a local model) in separate git worktrees, with Claude planning, dispatching, reviewing and merging. Use when the user asks to orchestrate, delegate implementation to opencode, or build a planned feature with Claude as orchestrator and opencode as implementor.
---

# Orchestrate

Claude is the orchestrator and reviewer; opencode is the implementor. You turn a plan into
small tasks, hand them out, check every result, and merge. What you need is on this page; don't
open `contract.md` or the other skills' files (the spec and review subagents read their own).

## Scope
Input: a **written, committed plan** (e.g. `docs/plans/*-plan.md`, built on a design settled
with the user). A one-line request, a todo task or an idea is not a
plan: get one first (step 0). The *design* is the user's call; only the *task graph* is yours.

This skill DOES:
- Split a plan into tasks with dependencies and **file ownership** (no two tasks that may run
  at the same time change the same file).
- Pick the implementer per task: opencode by default; Claude itself for tasks that are tiny,
  cross-cutting, security-sensitive, or need judgment the local model lacks.
- Drive the loop write → dispatch → review → merge, within `concurrency` from config.
- Keep `.orchestra/<run>/board.md` current so the run can resume in a later session.

This skill does NOT:
- Write each task's text (→ `claude-write-task`), run opencode (→ `claude-dispatch`), or judge
  a result (→ `claude-review-merge`). Use those.
- Push, open PRs, or deploy. The user does that (or asks for it separately).
- Ask the user to approve the task graph. Planning is your job: make it effective and efficient
  and go. Ask only when the goal itself is ambiguous (two reasonable readings that lead to
  different features).

## Context budget (why the run costs what it costs)
Every turn re-reads the whole conversation, and every dispatch that finishes is a new turn. A
long orchestrator session is the biggest token cost, more than writing or reviewing code. So:
- **The orchestrator thread holds only the plan, `board.md` and one-line outcomes.** Never read
  source files, diffs, test output or opencode logs here. Specs and reviews run in **subagents**
  (Agent tool, `model` from config: `spec_model`, `review_model`); their reading stays in their
  context and only a short reply comes back. This is the one place subagents are worth it
  (measured: ~200k tokens re-read per orchestrator turn by the end of a 17-task run). Without the
  Agent tool, run those skills inline and keep the same one-line outcomes in `board.md`.
- **One session per plan phase.** When a phase's tasks are all merged/dropped (or after ~8 merges
  in a phase-less plan): run the phase review (step 4), update `board.md`, then STOP and tell the
  user: "Phase N done. Start a new session and say: resume run `<run>`." `board.md` + the plan are
  the whole state; a fresh session re-reads ~20k tokens per turn instead of ~200k.
- **Don't fix opencode's code inline.** Small problems go back as review notes (`--continue`);
  bigger ones follow takeover. Accept-with-nits stays as it is.

## Required steps (one TodoWrite item each)
0. **Plan gate.** Is there a written plan that covers this work (a path from the user, or in
   `docs/plans/`)? If not: ⛔ STOP orchestrating. Settle the design with the user (the
   `brainstorming` skill if installed; otherwise ask one question at a time about purpose,
   scope and constraints, offer 2–3 approaches, get approval), then save a phased plan with
   per-task test commands in `docs/plans/` (`writing-plans` if installed), commit it, and come
   back here with that plan. Never invent the design (stack, architecture, scope) inside
   `board.md`. Skip only for a small change the request already pins down (e.g. "bump X to 2.1
   and fix the tests").
1. **Set up the run.** Read the plan and the repo's `CLAUDE.md`/`AGENTS.md`.
   Create `.orchestra/<run>/` (run = `YYYY-MM-DD-<slug>`), add `.orchestra/` and `.worktrees/`
   to `.git/info/exclude`, read or create `.orchestra/config.json` (defaults: `concurrency` 2,
   `max_rejections` 3, `task_timeout_min` 30, `base_branch` main, `spec_model`/`review_model`
   sonnet; set `test_cmd`/`lint_cmd` from the repo's `CLAUDE.md`).
   Check: working tree clean on `base_branch`; the repo's test command works. ⛔ STOP if not.
2. **Task graph** (no user approval: plan well and proceed). Write `board.md`: a table
   `id | phase | goal | implementer | depends_on | files | status` (status: todo, dispatched, review,
   sent-back, merged, taken-over, dropped) and an empty `## Log`.
   - Small tasks: one module or endpoint plus its tests; ≤ ~5 files; one test command.
   - **Worth a spec:** the spec should be much shorter than the code it produces. A task whose
     spec would be as long as its code (a 20-line helper, a constant, a rename) is merged into a
     neighbouring task, not dispatched alone.
   - Note the plan phase per task (`phase` column) and mark tasks touching auth, secrets, input
     parsing, files or the network as `review: opus` in the goal cell.
   - **Efficient:** as few tasks as the work allows; no task without a user-visible or tested
     outcome (YAGNI); shared code is its own early task so later tasks reuse it (DRY).
   - **Parallel:** give tasks disjoint files so up to `concurrency` run at once, each in its own
     worktree; add a dependency only where one task truly needs another's code.
   - Self-check before dispatching: every requirement maps to a task; no two concurrent tasks share
     a file; every task has an exact test command. Fix the graph, then go.
3. **Loop until every task is merged or dropped.**
   - Ready tasks = dependencies merged. Take up to `concurrency` of them whose files don't overlap
     with any task currently dispatched.
   - For each: spec via a subagent running `claude-write-task` (it replies with the task path
     only), then `claude-dispatch` here. Tasks marked Claude: a subagent on the cheapest capable
     model implements them in a worktree, then they are reviewed like opencode's.
     **Model ladder** (Claude tasks and takeovers): `haiku` = mechanical, fully specified, ≤ 2
     files; `sonnet` (default) = normal feature work; `opus` = judgment, security, concurrency,
     a design flaw. Start at the lowest that fits; after one rejection go up one row.
   - When a run finishes: a subagent runs `claude-review-merge` (model `review_model`, or `opus`
     for tasks marked `review: opus`) and replies with its verdict line. One review subagent at a
     time (each may merge into `base_branch`); reviews are short next to opencode runs.
     Rejected → back to dispatch (attempt + 1). After
     `max_rejections` (default 3): takeover on the model ladder (full task + review notes + the
     rules TDD/YAGNI/DRY in the prompt), reviewed again, marked `taken-over` + model.
   - After every state change: update `board.md` (table + one Log line with time and outcome).
4. **End of phase.** A subagent on `opus` reviews the whole phase (with the `code-review` skill
   if installed)
   (`git diff <phase start>..<base_branch>`) for what per-task reviews can't see: duplication
   across tasks, inconsistent patterns, missing integration. Findings become new tasks in the
   next phase (or a fix task now). Log it, then stop the session (see Context budget).
5. **Finish** (last phase). All tests pass on `base_branch`; worktrees and `orchestra/*` branches
   removed. Report: tasks by outcome (opencode first try / after send-back / taken over),
   commits, test results, anything left for the user (push, deploy, follow-ups).

## Subagent prompts (keep the replies short)
- **Spec:** "Use the `claude-write-task` skill (orchestration plugin) to write
  `.orchestra/<run>/tasks/<id>.task.md` for: <row from board.md> + plan section `<path>#<heading>`.
  Reply with one line: the path, or `BLOCKED: <reason>`."
- **Review:** "Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task
  `<id>` in repo `<root>`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` |
  `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`."
If a skill isn't loaded in the subagent, tell it the SKILL.md path to read instead.

## Resuming (also: every new phase session)
Read `board.md` and the plan only. For `dispatched` tasks check whether the run is still going
(log growing, process alive) or finished (RESULT.md in the worktree). Continue the loop from there.

## Red flags
| If you notice… | Do this |
|---|---|
| Waiting for the user to approve the task table | Don't; plan carefully and dispatch |
| Choosing the stack or architecture while writing `board.md` | Stop: no plan yet → design with the user, then a written plan (step 0) |
| A task with no test or no observable outcome | Merge it into another task or drop it (YAGNI) |
| Two concurrent tasks list the same file | Serialize them (add a dependency) |
| A task that needs "and also…" to describe | Split it |
| More running tasks than `concurrency` | Wait; more runs than atlas's slots only queue |
| Merging on RESULT.md's word | Never; `claude-review-merge` runs the tests itself |
| A fourth dispatch of the same task | Stop: after 3 rejections it's a takeover |
| About to push or deploy | Don't; report it as a step for the user |
| Reading a diff, source file or log in the orchestrator thread | Hand it to a subagent |
| Fixing opencode's bug yourself in this thread | Send it back with notes, or takeover |
| A phase finished and the session continues into the next | Phase review, then stop and hand off |
| A spec about as long as the code it asks for | Merge the task into a neighbour |

## Done when
- Every task in `board.md` is merged, taken-over or dropped (with reason).
- The full test suite passes on `base_branch`; no worktrees or `orchestra/*` branches remain.
- You reported outcomes per task and what the user still has to do.
