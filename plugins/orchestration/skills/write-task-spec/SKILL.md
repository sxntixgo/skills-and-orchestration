---
name: write-task-spec
description: Writes one implementation task for a less capable implementer model as a precise task.md (goal, allowed files, steps, exact test command, out of scope). Use when handing a single coding task to opencode or another implementer, or when orchestrate needs the next task written.
---

# Write a task spec

The implementer is a capable but smaller local model. It does well with **narrow, explicit**
tasks and poorly with vague or wide ones. Your spec is its whole world: anything you leave out,
it will guess. Format: `<id>.task.md` in `../../contract.md` (relative to this skill's base directory).

## Scope
DOES: write or revise ONE `.orchestra/<run>/tasks/<id>.task.md`.
Does NOT: split the plan (→ `orchestrate`), run anything (→ `dispatch-opencode`), write the code.

## Required steps
1. **Read the code first.** Open the files the task touches and the closest existing pattern
   (a similar endpoint, test, component). Note `file:line` of the pattern to copy.
2. **Pin the files.** List every file it may change or create. Everything else is forbidden.
   More than ~5 files → the task is too big: tell `orchestrate` to split it.
3. **Pin the check.** Write the exact test command that proves it (run it once now: it should
   fail or not exist yet, and must not fail for unrelated reasons). If the task needs new tests,
   say which cases (happy path, the edge, the error) — `writing-tests` helps pick them.
4. **Write steps** as short imperatives in order, test-first when tests are listed. Name
   functions, routes, fields exactly. Give types/signatures when they matter.
5. **Out of scope.** Name the tempting extras (refactors, renames, new deps, formatting other files).
6. **Attempt ≥ 2:** add `## Notes from review` with each problem as `file:line — what is wrong —
   what to do instead`. Keep everything else; bump `attempt`.
7. Save the file; note the path in `board.md`.

## Red flags
| If you notice… | Do this |
|---|---|
| "Improve", "clean up", "as needed", "etc." | Replace with the concrete change |
| No exact test command | Add one; a task without a check can't be reviewed |
| The spec explains *why* at length but not *what* | Cut to 2–6 lines of context |
| New dependency needed | Decide it yourself and name it, or keep it out of scope |
| Secrets, deploy, infra or migrations of live data | Mark the task for Claude, not opencode |

## Done when
The task file exists, follows the contract, lists files + one runnable test command, and a
reader with no other context could do it.
