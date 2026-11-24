# skill-creator — eval 2026-11-24

new = working tree (369cdd8+worktree), baseline = no skill; both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 2/4 | 3/4 |
| 2 | 2/3 | 3/3 |
| 3 | 3/3 | 2/3 |
| 4 | 1/3 | 1/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.625 | 8/13 | 19164.0 | 14.547 |
| baseline | 0.688 | 9/13 | 9800.0 | 17.569 |
| **delta** | **-0.063** | | +9364.0 | -3.022 |

Failed assertions:

- case 1 new: Scaffolds evals/evals.json with realistic cases — No evals.json is written and no eval cases are given. The answer stops at Stage 1, and 'Scaffold + evals' is only listed as future Stage 4.
- case 1 new: Ends by handing off to skill-reviewer (does not self-judge) — The answer ends with "I'll draft the frontmatter next." skill-reviewer is only mentioned as a future baseline check, and no handoff to it is made.
- case 1 baseline: Clarifies trigger/scope/success and STOPS for approval before drafting (Stage 1 gate) — It writes assumptions instead of asking ('Assumptions: It goes in the frugal-skills plugin...') and drafts the full SKILL.md. The closing question, 'Should I go ahead with that gate?', comes after drafting, not before.
- case 2 new: Rewrites the description into third-person 'what it does. Use when <trigger>' form with a concrete trigger — No new description is written: "I've stopped at the skill's first gate... and drafted nothing yet." The plan only states the intended form, "<what>. Use when <trigger>."
- case 3 baseline: Asks clarifying questions about trigger, scope, and success criteria — Trigger ("What would you say or do just before...") and scope ("What should the skill explicitly not do?") are asked. No question asks how success would be judged; "what should come out, and where" only specifies outputs.
- case 4 new: Scaffolds 3-5 realistic evals/evals.json cases anyway — No eval cases are written. It only promises future work: "I'll do the frontmatter, then the body, then scaffold ... and write 3–5 eval cases."
- case 4 new: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — No SKILL.md was produced: "there are no frontmatter, body or scaffold files yet." Scope appears only in plan.md, and there is no red-flags section.
- case 4 baseline: Scaffolds 3-5 realistic evals/evals.json cases anyway — No eval cases are written. It only proposes "3 short cases (about 15 lines of JSON)" and opens with "I haven't created anything yet."
- case 4 baseline: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — No SKILL.md is produced. Creation is deferred: "Once you answer, I'll run `skill-authoring:skill-creator` to build...". There are no scope or red-flag sections.
