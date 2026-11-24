# skill-creator — eval 2026-11-24

new = working tree (369cdd8+worktree), baseline = another skill (/Users/santiago/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator); both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 2/4 | 3/4 |
| 2 | 2/3 | 3/3 |
| 3 | 3/3 | 3/3 |
| 4 | 1/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.625 | 8/13 | 19067.5 | 13.69 |
| baseline | 0.854 | 11/13 | 36627.75 | 27.69 |
| **delta** | **-0.229** | | -17560.25 | -14.0 |

Failed assertions:

- case 1 new: Scaffolds evals/evals.json with realistic cases — No evals were written. They are only promised for later: "I'll ... write 3–5 test cases in `evals/evals.json`". No cases are shown.
- case 1 new: Ends by handing off to skill-reviewer (does not self-judge) — The handoff is only a future plan, not an actual handoff: "Then you run `skill-reviewer` to check it." The answer stops at Stage 1, so it never reaches the hand-off stage.
- case 1 baseline: Clarifies trigger/scope/success and STOPS for approval before drafting (Stage 1 gate) — It drafts SKILL.md and evals.json first. The gate comes afterward: 'Stop and send the reply below. Nothing gets spawned until the user confirms.' It stops before running evals, not before drafting.
- case 2 new: Rewrites the description into third-person 'what it does. Use when <trigger>' form with a concrete trigger — No description was written. The answer says "Nothing is drafted yet" and "Once you approve, I'll draft the new description". The required form is only named in the plan.
- case 4 new: Scaffolds 3-5 realistic evals/evals.json cases anyway — No evals/evals.json is written. The answer only describes them in the plan: "3 cases planned for Stage 4: messy notes → correct sections...". It also says "no other files yet".
- case 4 new: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — No SKILL.md is drafted; it stops at the Stage 1 gate. The plan.md has a Scope section but no red flags section.
- case 4 baseline: Declines to skip evals, explaining they are required (rule 8) — It went along with skipping the run: "the with/without-skill comparison was skipped as you asked." It wrote evals.json because CLAUDE.md requires it, but it didn't run the evals and only asked "Should I run it, or leave the skill unvalidated?"
