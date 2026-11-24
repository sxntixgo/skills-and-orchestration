# online-research — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 3/3 |
| 4 | 3/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 13/13 | 56531.25 | 42.776 |
| baseline | 0.917 | 12/13 | 73559.25 | 60.32 |
| **delta** | **+0.083** | | -17028.0 | -17.544 |

Failed assertions:

- case 4 baseline: Recognizes that many pages echoing one claim are not independent corroboration — Closest is 'I ignored SEO "2026 comparison" posts whose numbers conflict' and labeling vendor numbers as biased. It never says the many pages repeating the claim are echoes rather than independent confirmation.
