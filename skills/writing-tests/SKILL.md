---
name: writing-tests
description: Enumerates and writes test cases for a change — happy path, edges, boundaries, and error paths — in the project's test framework. Use when adding or improving tests, or when the TDD loop needs to know which cases to write.
---

# Writing Tests

Test observable behavior, not implementation. First enumerate the cases that
matter, then write them in the project's existing framework and style.

## Scope
This skill DOES:
- Enumerate the cases for a unit of behavior (happy / edge / boundary / error).
- Write those tests in the project's framework, following its conventions.

This skill does NOT:
- Implement or refactor the production code → that's `software-development`.
- Chase a coverage percentage for its own sake → cover behavior and risk.

## Workflow
Surface these as TodoWrite items. Checkpoint the case list to
`./.claude-skills-work/writing-tests/<unit>/cases.md` so it survives interruption.

### Step 1 — Identify the unit and its contract
State what the unit should do: inputs, outputs, side effects, and the observable
"done" behavior. This is what you test — not private helpers or internal state.

### Step 2 — Enumerate cases
For the unit, list cases across these categories (see
`references/test-design.md` for the techniques):
- **Happy path** — the main expected behavior(s).
- **Boundaries** — empty, zero, one, max, off-by-one, first/last.
- **Edges** — nulls/undefined, unexpected types, duplicates, ordering, unicode.
- **Error paths** — invalid input, dependency failure/timeout, unauthorized.
Write the list to the checkpoint file before coding tests.

### Step 3 — Write the tests
- One behavior per test; a clear name that states the expectation
  ("returns 409 when the email already exists").
- Arrange–Act–Assert; assert on behavior/output, not internal calls, unless the
  side effect IS the behavior.
- Keep tests independent and deterministic (no shared mutable state, no real
  clock/network/random — use test doubles at the seams).
- Match the project's framework, file layout, and naming.

### Step 4 — Run and confirm
Run the tests. In a TDD flow they must fail first for the RIGHT reason, then
pass once the code is written. A test that can't fail tests nothing.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Testing implementation details / private methods | Test observable behavior instead |
| Only the happy path | Add boundary + error cases before finishing |
| Asserting on mock call counts as the point | Assert on the resulting behavior/output |
| A flaky test (time, network, order) | Inject a test double at the seam; make it deterministic |
| Writing tests to hit a coverage number | Cover behavior and risk, not lines |
| One test asserting many unrelated things | Split into focused tests |

## Done when
- Every behavior of the unit has a test across happy/boundary/edge/error.
- Tests are independent, deterministic, clearly named, and run green (or fail
  correctly first, in TDD).

## References (load only when needed)
- `references/test-design.md` — techniques: equivalence partitioning, boundary
  values, choosing test doubles, and what makes a test valuable.
