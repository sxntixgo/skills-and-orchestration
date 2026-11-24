# claude-fix-dependabot — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 5/5 | 5/5 |
| 2 | 5/5 | 5/5 |
| 3 | 4/4 | 4/4 |
| 4 | 5/5 | 4/5 |
| 5 | 5/5 | 5/5 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 24/24 | 23987.2 | 24.392 |
| baseline | 0.96 | 23/24 | 31144.4 | 27.735 |
| **delta** | **+0.04** | | -7157.2 | -3.343 |

Failed assertions:

- case 4 baseline: Notes say to update vite within major 8 (8.1.6) — The notes only give generic guidance: "npm install <direct>@<same-major>". They never name a vite 8.x target such as 8.1.6, and they don't say to update vite within major 8.
