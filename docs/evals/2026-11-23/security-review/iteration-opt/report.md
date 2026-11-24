# security-review — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 4/4 | 4/4 |
| 3 | 4/4 | 4/4 |
| 4 | 4/4 | 4/4 |
| 5 | 4/4 | 4/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 20/20 | 15324.4 | 22.586 |
| baseline | 1.0 | 20/20 | 26738.4 | 29.427 |
| **delta** | **+0.0** | | -11414.0 | -6.841 |

Failed assertions:

