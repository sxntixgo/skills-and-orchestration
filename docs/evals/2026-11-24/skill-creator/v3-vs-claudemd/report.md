# skill-creator — eval 2026-11-24

new = working tree (57349c7+worktree), baseline = no skill; both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 2/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 1/3 |
| 4 | 3/3 | 3/3 |
| 5 | 4/4 | 4/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 17/17 | 28578.6 | 23.082 |
| baseline | 0.767 | 13/17 | 18935.2 | 24.505 |
| **delta** | **+0.233** | | +9643.4 | -1.423 |

Failed assertions:

- case 1 baseline: Writes 3-5 eval cases, each with assertions, including at least one fixture or diff as input — The table lists 7 cases (mixed-with-migration, auth-change, deleted-tests, benign, empty, untracked-only, negative-trigger), which exceeds the 3-5 range. Fixtures and per-case assertions are present.
- case 1 baseline: Ends by asking for approval and naming skill-reviewer as the next step (does not grade its own skill) — The reply ends with "Secrets and dependency bumps are also common risks; say if you want those added." It never asks for approval to proceed. skill-reviewer appears only in step 6, as something the answer itself would run and act on: "I'd fix whatever the review finds and re-run."
- case 3 baseline: Asks a single question rather than a list of questions — The final reply asks four numbered questions: "1. Which task do you repeat? ... 2. When should it trigger? ... 3. What should it produce ... 4. Which plugin..."
- case 3 baseline: Offers 2-3 concrete candidate skills, each with when it would trigger — It lists four examples ("daily standup summary... triaging a TODO/issue backlog... weekly review... time-boxed steps"), not 2-3. Triggers ("plan my day", "triage my issues") appear in a separate question and are not paired with each candidate.
