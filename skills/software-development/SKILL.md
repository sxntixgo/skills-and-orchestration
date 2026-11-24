---
name: software-development
description: Builds a backend or frontend feature end-to-end with a test-driven loop and DRY/YAGNI/KISS discipline, including one phase of a written plan (honoring per-task model assignments) and adding tests to existing code. Use when implementing a feature, endpoint, component, bugfix or planned phase, when asked to write/change production code, or when adding or improving tests.
---

# Software Development

Build the smallest correct slice, test-first, keep it simple, and run it. Everything you need is
on this page.

## Scope
DOES: understand → plan the slice → TDD loop (red → green → refactor) → DRY/YAGNI/KISS → run it.
Does NOT: invent requirements; build for hypothetical futures; stop at "it compiles"; chase a
coverage number (**100% line coverage is not the goal**: cover behaviour and risk; an untested
trivial line is fine, an untested failure mode is not).

## Stages (TodoWrite item each; notes in `./.claude-skills-work/software-development/<task>/`)
0. **Building from a plan** ("build Phase 3", "implement T3.2"): find the plan (`PLAN.md`,
   `SPEC.md`, `docs/plans/*`, or named in `CLAUDE.md`) and read that phase's section first.
   ⛔ No plan, or the phase isn't in it → STOP and ask (say what you looked for); never invent
   one. Restate the phase's done-criteria. A task with an assigned model runs on that model:
   on a different one, delegate it to a subagent with that exact `model:`; never downgrade to
   save time. Build only this phase; work from other phases → decline and note it there. At the
   end, update the plan (new agreed work with its model; prune finished entries) and don't
   `git commit` unless asked.
1. **Understand.** Restate inputs, outputs, and the observable "done" in 1–2 sentences.
   - Build now when the core behaviour is clear; state small assumptions ("ISO 8601 dates, since
     that's what the API sends") and move on.
   - Speculative asks ("configurable, extensible, any future format") → build only today's
     need, say in one line why the rest waits (YAGNI), and keep going.
   - ⛔ STOP and ask only when you'd be guessing the core behaviour itself.
2. **Plan the slice:** the one or few files and seams; extend existing patterns.
   - Backend: contract first (inputs, outputs, status codes: 201 created, 400 invalid, 404, 409
     conflict); validate at the boundary; thin handler → logic → data; parameterized queries;
     authn + authz per resource; no secrets/PII in logs or responses; transactions for
     multi-step writes.
   - Frontend: explicit **loading, empty, error, success** states for every fetch; semantic HTML
     (`<button>`, `<ul>`, labels), keyboard-operable; small component, derived state; ignore
     stale responses; no new state/CSS library for one feature.
3. **TDD loop**, per behaviour: **red** — write the test, run it, see it fail for the right
   reason; **green** — the simplest code that passes; **refactor** — clean up, rerun.
   Cases: happy path, each validation/error path, and boundaries (empty, one item, null/
   undefined, zero, max; just below/at/above each limit; one value per class of input the code
   treats alike), unicode/duplicates/ordering where relevant. **Bugfix:** first a test
   reproducing the bug (fails), then the minimal fix, then tests for the bug's neighbours (empty
   → also one item and null).
   **Tests themselves:** one behaviour per test, named for the expectation ("returns 409 when the
   email exists"); Arrange–Act–Assert; assert outputs and effects, not internal calls (a mock
   assertion only when the interaction IS the behaviour, e.g. an email sent; error paths assert
   the specific failure and no partial write); deterministic (fake the clock, network,
   randomness at the seams; wrap what you don't own); the project's framework and layout.
   **Only adding tests** (existing code): list the cases first, write them, run them; a test
   that can't fail tests nothing.
4. **DRY / YAGNI / KISS** (after green): remove duplicated *knowledge* (not look-alikes that
   change for different reasons); delete unused params, config, "just in case" branches; fewer
   moving parts, clear names, shallow nesting.
5. **Run it:** the full tests, the repo's lint/typecheck/build, AND the real behaviour (call the
   endpoint, render the component, run the function); don't leave dev servers running. Report
   files changed, what you ran and observed, and deviations from the plan; if you couldn't run
   something, say so.

## Red flags
| If you notice… | Do this |
|---|---|
| Code before a failing test | Write the test first |
| "Build Phase N" with no plan found | STOP and ask |
| Coding a task off its assigned model | Subagent on that model |
| Pulling another phase's work in | Decline; note it for its phase |
| Building for a future requirement | Delete it (YAGNI) |
| Stopping to ask when only details are open | State the assumption and build |
| A clever solution | The simplest that passes (KISS) |
| Logic copied a third time | Extract the shared knowledge (DRY) |
| A fetch with only the happy path | Add loading/empty/error states |
| A test checking internal calls / private methods | Assert behaviour |
| Tests written for a coverage number | Cover behaviour and risk; say 100% isn't the goal |
| "Types pass, so it works" | Run it |

## Done when
The slice's behaviour is covered by tests written first, all pass; no speculative or duplicated
logic; you ran the real behaviour and reported what you saw.
