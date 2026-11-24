# skill-reviewer — eval 2026-11-24

new = working tree (369cdd8+worktree), baseline = no skill; both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 3/3 | 2/3 |
| 2 | 4/4 | 3/4 |
| 3 | 3/3 | 1/3 |
| 4 | 3/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 13/13 | 50733.25 | 28.324 |
| baseline | 0.604 | 8/13 | 37712.75 | 27.32 |
| **delta** | **+0.396** | | +13020.5 | +1.004 |

Failed assertions:

- case 1 baseline: Applies the 8-rule rubric with severity-rated findings and file:line references — Severity tiers and rule numbers are present ('Blocker', 'Must fix', 'Rule 6, resumability'), but there are no file:line references. Locations are vague, e.g. 'the ⛔ on step 1', 'in step 3'.
- case 2 baseline: Verdict is ITERATE — The answer gives "Verdict: FAIL, not shippable." and "Verdict: **FAIL**, with 3 blockers". It never says ITERATE.
- case 3 baseline: Describes a blind A/B comparison between the two versions — The answer describes an old-vs-new trigger A/B scored by detecting a `Skill` tool_use, but it never mentions blinding. No grader is kept unaware of which arm is old or new.
- case 3 baseline: Still respects the Stage B approval gate before running — The answer gives a plan ("What I'd do, in order") and a template "Reply after the run", but never asks for approval before running. The only stop-and-ask is conditional: "If the diff touches the body... I'd stop and ask."
- case 4 baseline: Reports the run count (cases x 2) and token/time cost — It says "about 6 cases" and "Each case run twice" but never states a total run count. Cost is only "The live web runs cost tokens on both sides," with no token or time estimate.
