# claude-orchestrate-development — eval 2026-11-23

new = working tree (0f6b1d6+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 4/4 | 4/4 |
| 3 | 4/4 | 4/4 |
| 4 | 3/3 | 3/3 |
| 5 | 3/3 | 3/3 |
| 6 | 4/4 | 4/4 |
| 7 | 6/6 | 6/6 |
| 8 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 31/31 | 15985.75 | 19.764 |
| baseline | 1.0 | 31/31 | 15944.125 | 19.623 |
| **delta** | **+0.0** | | +41.625 | +0.141 |

Failed assertions:

