---
name: claude-write-task
description: Writes one implementation task for a less capable implementer model as a precise task.md (goal, allowed files, steps, exact test command, out of scope). Use when handing a single coding task to opencode or another implementer, or when orchestrate needs the next task written.
---

# Write a task spec

The implementer is a smaller local model: good at **narrow, explicit** tasks, poor at vague or
wide ones. The spec is its whole world; what you leave out, it guesses. The format is below (no
need to open `contract.md`).

## Scope
DOES: write or revise ONE `.orchestra/<run>/tasks/<id>.task.md`.
Does NOT: split the plan (→ `claude-orchestrate-development`), run anything (→ `claude-dispatch`),
write the code.

## Steps
1. **Read the code first:** open the files the task touches and the closest existing pattern
   (similar endpoint, test, component) before writing anything; note its `file:line`. If they
   don't exist, say what you looked for, and never invent a pattern's location.
2. **Pin the files** it may change/create; everything else is forbidden. More than ~5 → too big:
   tell the orchestrator to split it.
3. **Pin the check:** the exact test command (run it once: it should fail or not exist yet, and
   not fail for unrelated reasons). New tests → name the cases (happy path, the edge, the error).
4. **Steps:** short imperatives, test-first ("add test X, see it fail, then implement"); exact
   names, routes, fields, signatures; existing helpers to reuse (DRY); only what's needed (YAGNI).
   **Don't copy the plan:** if a committed plan spells out the design, types or test cases, write
   `read docs/plans/<file>.md, section "<heading>"` and add only what it leaves open. Aim for a
   spec well under the size of the code.
5. **Version bumps:** before writing steps, look up each new version's requirements (npm
   `npm view <pkg>@<ver> peerDependencies engines`; Python `requires-python` + pins on PyPI).
   Unmet ones are part of this task or an earlier one: peers that must move (vitest 5 → vite ≥ 6)
   and the runtime wherever pinned (CI `node-version`/`python-version`, Dockerfile `FROM`,
   `.nvmrc`/`.python-version`, devcontainer). Put them in Context.
6. **Out of scope:** the tempting extras (refactors, renames, new deps, formatting other files).
7. **Attempt ≥ 2:** keep everything, bump `attempt`, add `## Notes from review`, one line per
   problem: `file:line — what is wrong — what to do instead`.
8. Save; note the path in `board.md`. As the orchestrator's subagent, reply with the path only
   (or `BLOCKED: <reason>`).

## Format
```markdown
---
id: T3
run: 2026-11-21-csv-export
depends_on: [T1]      # [] if none
attempt: 1
---
# <one-line goal>
## Context
2–6 lines: why, where it fits, the pattern to copy (file:line), version requirements.
## Files
- may change: path/a.py, path/test_a.py
- may create: path/b.py
- must NOT touch: everything else (and never .orchestra/, .git/)
## Steps
1. …
## Done when
- `<exact test command>` passes      ← first backticked text here = the command review runs
- <observable behaviour>
## Out of scope
- …
```

## Red flags
| If you notice… | Do this |
|---|---|
| "Improve", "clean up", "as needed", "etc." anywhere (incl. run slug, title) | Replace with the concrete change |
| A vague request ("clean up X") | Don't write it: ask what to change, or say it must be split |
| No exact test command | Add one; a task without a check can't be reviewed |
| Steps run a test command different from the one under Done when (e.g. `-race` only in Steps) | Use the same command, flags included: review runs only Done when's |
| Long *why*, little *what* | Cut Context to 2–6 lines |
| A new dependency | Name it yourself, or keep it out of scope |
| A version bump with no requirements checked | Check peers/engines; CI and Dockerfile pins are part of it |
| Secrets, deploy, infra, live-data migrations | Mark the task for Claude, not opencode |

## Done when
The task file follows the format, lists files + one runnable test command, and a reader with no
other context could do it.
