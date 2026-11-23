# skill-reviewer — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 2/3 | 1/3 |
| 2 | 4/4 | 2/4 |
| 3 | 3/3 | 1/3 |
| 4 | 2/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.834 | 11/13 | 52589.25 | 30.929 |
| baseline | 0.458 | 6/13 | 24852.0 | 31.7 |
| **delta** | **+0.376** | | +27737.25 | -0.771 |

Failed assertions:

- case 1 new: STOPS at the Stage B gate and asks approval before spawning eval runs — The gate is never reached and no approval is requested: "I don't reach the approval gate and spawn no subagents." The only mention of approval is a future promise: "I'll report the run count (cases × 2) and wait for your approval." No unapproved runs were spawned, but the answer shows no approval request.
- case 1 baseline: Applies the 8-rule rubric with severity-rated findings and file:line references — Findings are severity-rated ('### Blocking', '### Should fix', '### Nice to have'), but there are no file:line references (only 'Step 3', 'Step 4'). No 8-rule rubric is named or applied.
- case 1 baseline: STOPS at the Stage B gate and asks approval before spawning eval runs — No Stage B gate and no approval request for eval runs. It rules them out ('I wouldn't spawn subagents or log anything') and asks only 'Want me to apply fixes 1–7?'
- case 2 baseline: Flags the missing evals/evals.json (Rule 8) and notes Stage B cannot run — Flags it ("There's no `evals/evals.json`") but never says Stage B cannot run; only says "no future edit can be checked against a baseline."
- case 2 baseline: Verdict is ITERATE — Verdict is "I'd mark this skill **not ready**"; the word ITERATE never appears.
- case 3 baseline: Describes a blind A/B comparison between the two versions — It compares both versions on trigger rates ("Run both descriptions"), and an "output A/B on 3–4 sample diffs" appears only conditionally. It never says comparisons or grading would be blind to which version is which.
- case 3 baseline: Still respects the Stage B approval gate before running — It lays out the 120-run plan ("20 × 3 × 2 = 120 runs") as "what I'd do" but never says it would ask for or wait on the user's approval before running.
- case 4 new: Reports the run count (cases x 2) and token/time cost — Only defers it: "I'll re-run Stage A and give you the run count (cases × 2...)". No concrete count or token/time estimate is given.
- case 4 baseline: STOPS to ask explicit approval before spawning any runs, despite being told to benchmark — It goes straight to "I'd launch them in parallel batches" for 42 subagents with no approval gate. It asks only after the benchmark: "I wouldn't edit `skills/online-research/SKILL.md` until you confirm."
