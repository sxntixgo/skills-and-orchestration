---
name: build-phase
description: Builds ONE planned phase/milestone of a project from a written spec — reading the plan, honoring a per-task model assignment, staying in scope, verifying, and reporting. Use when implementing a discrete phase or work package from a PLAN.md/SPEC.md, especially when the plan assigns models to tasks.
---

# Build a Phase

Build ONE phase of a planned project. The plan is the *what*; this is the *how*: which phase,
which model, scope control, plan hygiene, reporting.

## Scope
DOES: find the spec, scope the phase to its done-criteria, build it, verify, update the plan,
report.
Does NOT: pull later-phase work forward, add speculative abstractions or invent requirements;
`git commit` (the human owns commits). Siblings, if installed: `software-development` (build
loop), `writing-tests` (cases), `debugging`, `code-review`/`security-review`; without them follow
the short rules below.

## Steps (TodoWrite item each)
1. **Read the plan.** Look for `PLAN.md`/`SPEC.md`/`docs/plans/*` or a file named in
   `CLAUDE.md`, and the section for THIS phase. ⛔ **STOP and ask** if you didn't find a plan or
   the phase isn't defined in it: say what you looked for. Never invent a plan or a phase.
   Write the phase's done-criteria to a note.
2. **Orient:** `CLAUDE.md`/`AGENTS.md`; the target code's style and helpers; the repo's
   test/lint/typecheck/build commands (use those; add no tools).
3. **Scope & model.** Restate the done-criteria. A task with an assigned model runs on that
   model: on a different one, spawn a subagent with that exact `model:` (one per task); never
   downgrade to save time. Honor project rules on who writes tests. ⛔ STOP if the model or
   scope is ambiguous. Requests to add other phases' work → decline, note it for its phase.
4. **Build** test-first: failing test → simplest code → refactor (DRY/YAGNI/KISS), strictly
   inside this phase.
5. **Verify:** tests pass, typecheck/lint clean, build green, the real behaviour exercised (not
   just types). Don't leave dev servers running.
6. **Update the plan:** add newly agreed work with its model; prune finished entries whose
   decisions now live in code/`CLAUDE.md`.
7. **Report:** files changed, test results (counts + names), verification output, deviations
   with reasons. No commit unless asked.

## Red flags
| If you notice… | Do this |
|---|---|
| Coding before reading the plan section | Read it; restate done-criteria |
| No plan found | STOP and ask; don't assume one |
| Implementing off the assigned model | Subagent on the assigned model |
| Building Phase N+1 work now | Decline; one phase at a time |
| Code before a failing test | Test first |
| About to `git commit` | Don't |

## Done when
Done-criteria met and covered by tests written first; real behaviour observed; plan updated;
report given with files, results, verification and deviations.
