---
name: writing-tests
description: Enumerates and writes test cases for a change — happy path, edges, boundaries, and error paths — in the project's test framework. Use when adding or improving tests, or when the TDD loop needs to know which cases to write.
---

# Writing Tests

Test observable behaviour, not implementation. List the cases that matter, then write them in
the project's framework and style.

## Scope
DOES: enumerate cases for a unit (happy / boundary / edge / error) and write them.
Does NOT: implement or refactor production code (→ `software-development`); chase a coverage
number. **100% line coverage is not the goal**: cover behaviour and risk; untested trivial lines
are fine, an untested failure mode is not.

## Steps (TodoWrite items; case list in `./.claude-skills-work/writing-tests/<unit>/cases.md`)
1. **Contract:** inputs, outputs, side effects, the observable "done" — that is what you test,
   not private helpers or internal state.
2. **Enumerate** (write the list before coding):
   - **Happy path** — one representative per class of input the code treats alike
     (equivalence partitioning: "age 18–65" → `<18`, `18–65`, `>65`, not thirty values).
   - **Boundaries** — just below, at, just above each limit (`17, 18, 19`); empty, one, max,
     zero, negative.
   - **Edges** — null/undefined, wrong types, duplicates, ordering, unicode.
   - **Errors** — invalid/missing input, unauthorized, not-found, conflict, dependency
     failure/timeout; assert the specific failure (status, message, no partial write).
3. **Write:** one behaviour per test, a name stating the expectation ("returns 409 when the
   email exists"); Arrange–Act–Assert; assert outputs, not internal calls (mocks only when the
   interaction IS the behaviour, e.g. an email sent); independent and deterministic (stub/fake
   clock, network, randomness at the seams; wrap what you don't own); follow the project's
   layout and naming.
4. **Run:** in TDD each test fails first for the right reason, then passes. A test that can't
   fail tests nothing.

## Red flags
| If you notice… | Do this |
|---|---|
| Testing private methods / implementation | Test behaviour |
| Only the happy path | Add boundary + error cases |
| Mock call counts as the assertion | Assert the outcome |
| Flaky (time, network, order) | Inject a double; make it deterministic |
| Tests written for a coverage number | Cover behaviour and risk; say 100% isn't the goal |
| One test asserting many things | Split it |

## Done when
Each behaviour has tests across happy/boundary/edge/error; tests are independent,
deterministic, clearly named, and green (or red for the right reason, in TDD).
