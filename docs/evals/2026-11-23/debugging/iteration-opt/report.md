# debugging — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 3/3 |
| 4 | 3/3 | 3/3 |
| 5 | 4/4 | 3/4 |
| 6 | 4/4 | 4/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 21/21 | 47366.333 | 20.109 |
| baseline | 0.958 | 20/21 | 48808.5 | 21.133 |
| **delta** | **+0.042** | | -1442.167 | -1.024 |

Failed assertions:

- case 5 baseline: Runs the failing test to reproduce the bug before changing code — No quoted pre-fix test run or failure output. Only 'I saved notes on how I reproduced and confirmed the cause', which is vague and does not show the test was run first.
