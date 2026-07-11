# Test design techniques

Use these to turn a unit's contract into a small, high-value set of cases.

## Equivalence partitioning
Group inputs that the code should treat the same way; test ONE representative
per group instead of many similar values. Example: for "age must be 18–65",
the groups are `<18`, `18–65`, `>65` — three tests, not thirty.

## Boundary value analysis
Bugs cluster at edges. For each partition boundary, test the value just below,
at, and just above it: `17, 18, 19` and `64, 65, 66`. Also the universal
boundaries: empty, single element, full/max, zero, negative, off-by-one.

## Error and failure paths
Every input that can be wrong, and every dependency that can fail, is a case:
invalid/missing/malformed input, unauthorized, not-found, conflict, dependency
timeout or exception. Assert the specific failure (status, message, no partial
write), not just "it threw".

## Choosing test doubles
Replace real collaborators at the seam so tests are fast and deterministic:
- **Stub** — canned return values (a repo that returns a fixed user).
- **Fake** — a working lightweight implementation (in-memory DB).
- **Mock/spy** — assert an interaction happened, but ONLY when the interaction
  is the behavior under test (e.g. "an email was sent"). Otherwise assert on
  outputs, not calls.
Prefer the lightest double that works. Don't mock what you don't own — wrap it.

## What makes a test valuable
- **Tests behavior, not implementation** — survives a refactor that preserves
  behavior. If renaming a private method breaks the test, it was too coupled.
- **Can fail** — you've seen it red for the right reason. A test that always
  passes tests nothing.
- **Independent & deterministic** — no order dependence, no real clock, network,
  filesystem, or randomness unless controlled.
- **Readable as a spec** — the name and body tell a reader what the unit
  guarantees.

## How many tests?
Enough to cover each equivalence class, the boundaries, and the realistic
failure modes — no more. Ten near-duplicate happy-path tests add cost without
confidence; one missing error-path test is a real gap. Cover risk, not lines.
