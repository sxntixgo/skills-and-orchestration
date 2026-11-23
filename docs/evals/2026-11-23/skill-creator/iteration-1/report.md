# skill-creator — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 2/4 | 0/4 |
| 2 | 2/3 | 2/3 |
| 3 | 3/3 | 2/3 |
| 4 | 1/3 | 0/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.625 | 8/13 | 15666.0 | 16.538 |
| baseline | 0.334 | 4/13 | 6116.0 | 13.456 |
| **delta** | **+0.291** | | +9550.0 | +3.082 |

Failed assertions:

- case 1 new: Scaffolds evals/evals.json with realistic cases — Stops at Stage 1. Stage 4 'Scaffold + evals' is only listed as a todo item, and no evals.json is written.
- case 1 new: Ends by handing off to skill-reviewer (does not self-judge) — Ends with "I'll draft the frontmatter (Stage 2)". No handoff to skill-reviewer is made, and Stage 5 is only listed as a todo item.
- case 1 baseline: Clarifies trigger/scope/success and STOPS for approval before drafting (Stage 1 gate) — No clarification or approval stop; it assumes and proceeds: "I'm assuming you want a project-level skill and that no skill with that name exists yet."
- case 1 baseline: Produces a concrete 'Use when' description and a scope block with a 'does NOT' line — Has a concrete 'Use when' description ("Use when the user asks for a summary of their changes, e.g. 'summarize my changes'..."), but no scope block with a 'does NOT' line; only "Read-only. Never stage, commit, stash, or edit files."
- case 1 baseline: Scaffolds evals/evals.json with realistic cases — Only SKILL.md is written: "I'd write one file, `.claude/skills/summarize-diff/SKILL.md`". No evals/evals.json.
- case 1 baseline: Ends by handing off to skill-reviewer (does not self-judge) — Ends with a self-check and a final reply ("Restart the session or run `/skills` to load it."). No handoff to skill-reviewer.
- case 2 new: Rewrites the description into third-person 'what it does. Use when <trigger>' form with a concrete trigger — No rewritten description is produced; it stops at the gate: "No description draft until the user approves." Only a success criterion mentions the form.
- case 2 baseline: Rewrites the description into third-person 'what it does. Use when <trigger>' form with a concrete trigger — It has a concrete trigger: "Use whenever the user has just finished implementing a change... or is about to commit, push, open a PR, or merge". But the opening is imperative, not third-person: "Review a code change for bugs..." rather than "Reviews a code change...".
- case 3 baseline: Asks clarifying questions about trigger, scope, and success criteria — Asks about trigger ("What should trigger it: a phrase like 'plan my day', or a slash command?") and scope ("personal (~/.claude/skills/) or inside a project/plugin repo?"), but never asks about success criteria or what a good result looks like.
- case 4 new: Scaffolds 3-5 realistic evals/evals.json cases anyway — No evals were written; it only promises "3–5 cases will be scaffolded in Stage 4" after stopping at the Stage 1 gate.
- case 4 new: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — No SKILL.md was drafted: "I wouldn't read the reference files, draft frontmatter or body... until you approve the plan." Draft scope exists only in plan.md, and there are no red flags.
- case 4 baseline: Declines to skip evals, explaining they are required (rule 8) — The answer complies instead of declining: "I'll skip the evals as you asked and won't argue the point."
- case 4 baseline: Scaffolds 3-5 realistic evals/evals.json cases anyway — There is no evals/evals.json and there are no cases. It offers only "Sanity check (not an eval): I'll re-read the description".
- case 4 baseline: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — SKILL.md is lean, but it has only a "## Don't" list ("Invent changes, versions, or dates..."). It has no scope section and no red flags section.
