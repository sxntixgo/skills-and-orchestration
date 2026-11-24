---
name: software-development
description: Builds a backend or frontend feature end-to-end with a test-driven loop and DRY/YAGNI/KISS discipline. Use when implementing a feature, endpoint, component, or bugfix, or when asked to write/change production code.
---

# Software Development

Build the smallest correct slice, test-first, keep it simple, and run it. Everything you need is
on this page.

## Scope
DOES: understand → plan the slice → TDD loop (red → green → refactor) → DRY/YAGNI/KISS → run it.
Does NOT: invent requirements; build for hypothetical futures; stop at "it compiles". For a long
list of test cases, `writing-tests` helps (if installed).

## Stages (TodoWrite item each; notes in `./.claude-skills-work/software-development/<task>/`)
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
   undefined, zero, max). **Bugfix:** first a test reproducing the bug (fails), then the minimal
   fix, then tests for the bug's neighbours (empty → also one item and null).
4. **DRY / YAGNI / KISS** (after green): remove duplicated *knowledge* (not look-alikes that
   change for different reasons); delete unused params, config, "just in case" branches; fewer
   moving parts, clear names, shallow nesting.
5. **Run it:** the full tests AND the real behaviour (call the endpoint, render the component,
   run the function). Report what you ran and observed; if you couldn't run something, say so.

## Red flags
| If you notice… | Do this |
|---|---|
| Code before a failing test | Write the test first |
| Building for a future requirement | Delete it (YAGNI) |
| Stopping to ask when only details are open | State the assumption and build |
| A clever solution | The simplest that passes (KISS) |
| Logic copied a third time | Extract the shared knowledge (DRY) |
| A fetch with only the happy path | Add loading/empty/error states |
| "Types pass, so it works" | Run it |

## Done when
The slice's behaviour is covered by tests written first, all pass; no speculative or duplicated
logic; you ran the real behaviour and reported what you saw.
