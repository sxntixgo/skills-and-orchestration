# claude-dispatch — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 3/3 | 3/3 |
| 2 | 4/4 | 4/4 |
| 3 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 10/10 | 13509.667 | 11.18 |
| baseline | 1.0 | 10/10 | 25134.333 | 16.751 |
| **delta** | **+0.0** | | -11624.666 | -5.571 |

Failed assertions:

