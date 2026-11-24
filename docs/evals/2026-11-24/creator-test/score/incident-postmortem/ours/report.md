# incident-postmortem — eval 2026-11-24

new = working tree (57349c7+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 2/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 10/10 | 15187.333 | 27.48 |
| baseline | 0.833 | 8/10 | 12103.667 | 17.265 |
| **delta** | **+0.167** | | +3083.666 | +10.215 |

Failed assertions:

- case 1 baseline: Timeline times are converted to UTC (13:58 MST -> 20:58 UTC) and labelled UTC — Times kept local: "**Times:** US/Mountain" and timeline shows "13:58 | Deploy 4812", not 20:58 UTC.
- case 1 baseline: Every action item has an owner and a due date (or an explicit placeholder such as 'owner: TBD' flagged for the user) — Owners are "TBD" and flagged, but the table has no due date column, only "Owner | Priority"; no due dates or due-date placeholders.
