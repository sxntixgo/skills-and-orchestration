# security-review — eval 2026-11-23

new = working tree (0f6b1d6+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 4/4 | 4/4 |
| 3 | 4/4 | 4/4 |
| 4 | 4/4 | 4/4 |
| 5 | 4/4 | 4/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 20/20 | 13642.8 | 22.682 |
| baseline | 1.0 | 20/20 | 5751.6 | 11.252 |
| **delta** | **+0.0** | | +7891.2 | +11.43 |

Failed assertions:

