# writing-tests — eval 2026-11-23

new = working tree (0f6b1d6+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 3/3 |
| 4 | 3/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 13/13 | 12593.75 | 19.186 |
| baseline | 0.917 | 12/13 | 6019.25 | 13.579 |
| **delta** | **+0.083** | | +6574.5 | +5.607 |

Failed assertions:

- case 4 baseline: Explains that 100% line coverage is not the goal; covering behavior and risk is — The answer treats 100% as the goal: "I'd keep going until line and branch coverage both show 100%." It notes tests should "check real behaviour, not just that lines ran" but never says 100% isn't the goal.
