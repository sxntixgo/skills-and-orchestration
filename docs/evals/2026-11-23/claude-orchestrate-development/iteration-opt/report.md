# claude-orchestrate-development — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 4/4 | 4/4 |
| 3 | 4/4 | 4/4 |
| 4 | 3/3 | 0/3 |
| 5 | 3/3 | 2/3 |
| 6 | 4/4 | 4/4 |
| 7 | 6/6 | 6/6 |
| 8 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 31/31 | 17080.25 | 17.949 |
| baseline | 0.833 | 27/31 | 31604.25 | 21.015 |
| **delta** | **+0.167** | | -14524.0 | -3.066 |

Failed assertions:

- case 4 baseline: Reads .orchestra/<run>/board.md first — Step 1 reads `plugins/orchestration/contract.md` first. It only globs `ls .orchestra/*/board.md` and never reads a board. Reading it is only promised: "Once I have the run, I'll read its board.md".
- case 4 baseline: Checks dispatched tasks for a live run or RESULT.md in their worktree — Stated only as future intent: "For tasks marked `dispatched`, I'll check whether opencode is still running... or has finished (`RESULT.md` in the worktree)." No check was performed.
- case 4 baseline: Continues from the recorded state instead of starting a new run — It correctly declines a new run ("No new run or task graph, because rebuilding one from memory could re-run or overwrite finished work"), but it never continues from any recorded state. It stops to ask which run, and resuming is only promised.
- case 5 baseline: Sends both back to opencode with review notes (--continue) — It says "Both go back to opencode with their review notes" and re-dispatches via claude-dispatch with bumped attempts. It never mentions --continue or continuing the prior session.
