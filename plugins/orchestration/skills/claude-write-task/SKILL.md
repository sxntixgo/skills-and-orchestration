---
name: claude-write-task
description: Writes one implementation task for a less capable implementer model as a precise task.md (goal, allowed files, steps, exact test command, out of scope). Use when handing a single coding task to opencode or another implementer, or when orchestrate needs the next task written.
---

# Write a task spec

The implementer is a capable but smaller local model. It does well with **narrow, explicit**
tasks and poorly with vague or wide ones. Your spec is its whole world: anything you leave out,
it will guess. Format: `<id>.task.md` in `../../contract.md` (relative to this skill's base directory).

## Scope
DOES: write or revise ONE `.orchestra/<run>/tasks/<id>.task.md`.
Does NOT: split the plan (→ `claude-orchestrate-development`), run anything (→ `claude-dispatch`), write the code.

## Required steps
1. **Read the code first.** Open the files the task touches and the closest existing pattern
   (a similar endpoint, test, component). Note `file:line` of the pattern to copy.
2. **Pin the files.** List every file it may change or create. Everything else is forbidden.
   More than ~5 files → the task is too big: tell `claude-orchestrate-development` to split it.
3. **Pin the check.** Write the exact test command that proves it (run it once now: it should
   fail or not exist yet, and must not fail for unrelated reasons). If the task needs new tests,
   say which cases (happy path, the edge, the error) — `writing-tests` helps pick them.
4. **Write steps** as short imperatives in order, always test-first (TDD: "add test X, see it
   fail, then implement"). Name functions, routes, fields exactly. Give types/signatures when
   they matter. Point to existing helpers to reuse (DRY), and specify only what's needed (YAGNI).
5. **Version bumps: check what the new versions require.** When the task upgrades a package
   (or a runtime), look up each new version's requirements *before* writing the steps:
   npm `npm view <pkg>@<ver> peerDependencies engines`; Python `requires-python` and its
   dependency pins on PyPI. Every requirement the repo doesn't meet yet is part of the task
   (or an earlier task): a peer that must move too (vitest 5 → vite ≥ 6), and the runtime
   wherever it is pinned — CI workflow (`node-version`, `python-version`), Dockerfile `FROM`,
   `.nvmrc`/`.python-version`, devcontainer. Put the found requirements in Context.
6. **Out of scope.** Name the tempting extras (refactors, renames, new deps, formatting other files).
7. **Attempt ≥ 2:** add `## Notes from review` with each problem as `file:line — what is wrong —
   what to do instead`. Keep everything else; bump `attempt`.
8. Save the file; note the path in `board.md`.

## Red flags
| If you notice… | Do this |
|---|---|
| "Improve", "clean up", "as needed", "etc." | Replace with the concrete change |
| No exact test command | Add one; a task without a check can't be reviewed |
| The spec explains *why* at length but not *what* | Cut to 2–6 lines of context |
| New dependency needed | Decide it yourself and name it, or keep it out of scope |
| A version bump with no requirements checked | Check peers/engines first; CI and Dockerfile pins are part of the task |
| Secrets, deploy, infra or migrations of live data | Mark the task for Claude, not opencode |

## Done when
The task file exists, follows the contract, lists files + one runnable test command, and a
reader with no other context could do it.
