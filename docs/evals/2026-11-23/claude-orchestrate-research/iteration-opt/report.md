# claude-orchestrate-research — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 6/6 | 6/6 |
| 2 | 4/4 | 4/4 |
| 3 | 4/4 | 4/4 |
| 4 | 2/2 | 2/2 |
| 5 | 4/4 | 3/4 |
| 6 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 23/23 | 15825.167 | 22.679 |
| baseline | 0.958 | 22/23 | 24446.0 | 23.028 |
| **delta** | **+0.042** | | -8620.833 | -0.349 |

Failed assertions:

- case 5 baseline: Cites talks with title and timestamp — Only requires citations ("Give a quote, timestamp, date and URL for each claim"). The final message and report plan never cite a talk title with a timestamp. The 'fopen()' quote has no source or timestamp.
