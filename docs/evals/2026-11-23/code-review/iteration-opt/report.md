# code-review — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 3/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 3/3 |
| 4 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 13/13 | 15672.0 | 14.242 |
| baseline | 0.938 | 12/13 | 25744.75 | 17.316 |
| **delta** | **+0.062** | | -10072.75 | -3.074 |

Failed assertions:

- case 1 baseline: Flags the missing bound check on discount (e.g. >1 or <0 produces a wrong/negative total) as the top correctness issue — The bound check is flagged: "`discount` is never checked... A value above 1 gives a negative total. A negative value raises the price." But it is Must-fix item 2. Item 1 is "Existing callers now return `NaN`", so it is not the top issue.
