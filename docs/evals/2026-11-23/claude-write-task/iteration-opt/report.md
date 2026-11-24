# claude-write-task — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 5/6 | 6/6 |
| 2 | 3/3 | 3/3 |
| 3 | 4/4 | 4/4 |
| 4 | 5/5 | 5/5 |
| 5 | 4/4 | 4/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.967 | 21/22 | 14550.4 | 16.333 |
| baseline | 1.0 | 22/22 | 25108.8 | 22.494 |
| **delta** | **-0.033** | | -10558.4 | -6.161 |

Failed assertions:

- case 1 new: Covers page 0 / beyond the end / page_size cap edge cases — Page 0 and past-end are covered ("page=0 → 422", "page=4&page_size=10 → 200, []"), but there is no cap: "No upper limit on `page_size`: a client can request any size."
