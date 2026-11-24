# release-notes — eval 2026-11-24

new = working tree (57349c7+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 2/2 | 2/2 |
| 3 | 3/3 | 1/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 9/9 | 13247.333 | 11.15 |
| baseline | 0.778 | 7/9 | 10854.667 | 7.017 |
| **delta** | **+0.222** | | +2392.666 | +4.133 |

Failed assertions:

- case 3 baseline: Drops internal identifiers: no SyncWorker.retryLoop, useOptimisticRows, ETag 412, IDB or JIRA ids — The notes are clean, but the answer itself contains a JIRA id: "I left out the ticket and PR numbers (JIRA-2231/2240, #440/#441)".
- case 3 baseline: Keeps the PR numbers (#441, #440) — PR numbers are left out of the release notes: "I left out the ticket and PR numbers (JIRA-2231/2240, #440/#441)".
