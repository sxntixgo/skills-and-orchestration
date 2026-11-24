# skill-creator — eval 2026-11-24

new = working tree (57349c7+worktree), baseline = another skill (~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator); both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 2/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 1/3 |
| 4 | 2/3 | 3/3 |
| 5 | 4/4 | 4/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.933 | 16/17 | 33688.0 | 25.214 |
| baseline | 0.767 | 13/17 | 53475.4 | 31.989 |
| **delta** | **+0.166** | | -19787.4 | -6.775 |

Failed assertions:

- case 1 baseline: Writes 3-5 eval cases, each with assertions, including at least one fixture or diff as input — Three cases with fixture diffs, but none has assertions: "Prompts only for now. Checks for pass/fail come later, per skill-creator." Each case has only an expected_output string.
- case 1 baseline: Ends by asking for approval and naming skill-reviewer as the next step (does not grade its own skill) — Ends with "Once you confirm, I'll run each case with and without the skill", so the next step is running evals, not skill-reviewer. It also plans to grade its own runs: "grade into `grading.json`". skill-reviewer appears only as a later 'Finish' item.
- case 3 baseline: Asks a single question rather than a list of questions — Asks four numbered questions: "1. Which of these is closest... 2. What would you type... 3. What should you end up with... 4. Does it need any of your tools"
- case 3 baseline: Offers 2-3 concrete candidate skills, each with when it would trigger — Offers five directions, not 2-3, and none states its own trigger. Each describes only what it does, e.g. "Weekly review: go through what got done, what slipped and why". Trigger phrases appear only in a separate generic question.
- case 4 new: Does not lecture at length about why evals matter (one or two sentences at most) — Three sentences in the opening: "Evals are cheap, and they're the only way..." / "A format the model already knows well is exactly the case where lift is often 0." The closing adds more: "If it measures about 0 lift, the skill isn't worth keeping."
