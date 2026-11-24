# software-development — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 3/3 | 0/3 |
| 3 | 3/3 | 1/3 |
| 4 | 3/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 13/13 | 14849.0 | 21.304 |
| baseline | 0.5 | 7/13 | 22072.0 | 22.293 |
| **delta** | **+0.5** | | -7223.0 | -0.989 |

Failed assertions:

- case 2 baseline: Handles loading, empty, error, and success states explicitly (not just the happy path) — Only planned, not implemented: "I'll add loading, empty ("No users found") and error ("Couldn't load users") states." The answer says "No code written," so this is stated intent with no component handling any state.
- case 2 baseline: Writes tests first for the states and fetch behavior — No tests are written. It only promises: "I'll write the plan, then build it test-first... with tests for each state." Its status line reads "BLOCKED on user answers. No code written."
- case 2 baseline: Uses semantic/accessible markup and keeps the component small — There is no markup at all, and no mention of semantic elements, roles, or accessibility. The hook/presentational split ("a `useUsers` hook plus a presentational `UserList`") is a plan only and does not cover the markup half.
- case 3 baseline: Implements the smallest function meeting the current requirement — No function implemented; answer stops at Stage 1: "I wouldn't write any code or tests and wouldn't touch project files."
- case 3 baseline: Still writes tests first and keeps it simple (KISS) — Only states intent ("with tests written first"); explicitly writes no tests: "I wouldn't write any code or tests."
- case 4 baseline: Makes the minimal change to pass and checks nearby boundaries (single item, null) — Minimal change is present ("if (items.length === 0) return 0;") and a single-item boundary is added. Null/undefined input is never considered or tested, so the boundary check is incomplete.
