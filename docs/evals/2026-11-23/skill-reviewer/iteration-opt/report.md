# skill-reviewer — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 3/3 | 2/3 |
| 2 | 4/4 | 4/4 |
| 3 | 3/3 | 3/3 |
| 4 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 13/13 | 45664.5 | 32.507 |
| baseline | 0.917 | 12/13 | 48848.25 | 29.364 |
| **delta** | **+0.083** | | -3183.75 | +3.143 |

Failed assertions:

- case 1 baseline: STOPS at the Stage B gate and asks approval before spawning eval runs — Stage B was skipped, not gated: "run count 0, so the approval gate never came up." Approval is only promised for later ("wait for your approval before starting them"), which is intent.
