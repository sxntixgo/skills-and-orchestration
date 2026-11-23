# skill-creator — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 2/4 | 1/4 |
| 2 | 2/3 | 3/3 |
| 3 | 3/3 | 2/3 |
| 4 | 1/3 | 0/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.625 | 8/13 | 12818.5 | 15.065 |
| baseline | 0.479 | 6/13 | 9652.25 | 20.855 |
| **delta** | **+0.146** | | +3166.25 | -5.79 |

Failed assertions:

- case 1 new: Scaffolds evals/evals.json with realistic cases — No evals.json is scaffolded. The answer stops at the Stage 1 gate, and 'Scaffold + evals' appears only as a pending TodoWrite item.
- case 1 new: Ends by handing off to skill-reviewer (does not self-judge) — 'Hand off to skill-reviewer' appears only as a planned todo item. The answer actually ends by asking the user to approve the plan.
- case 1 baseline: Clarifies trigger/scope/success and STOPS for approval before drafting (Stage 1 gate) — Explicitly skips the gate: "The request is clear enough that I'd skip clarifying questions and put the defaults in the final reply."
- case 1 baseline: Produces a concrete 'Use when' description and a scope block with a 'does NOT' line — The 'Use when' is concrete: "Use when the user asks for a summary of their changes, 'what did I change', 'summarize my diff'..." There is no scope block with a 'does NOT' line. The closest are an inline "Not for writing commit messages..." in the description and "Read-only: never stage, commit, stash, or modify files."
- case 1 baseline: Ends by handing off to skill-reviewer (does not self-judge) — skill-reviewer is never mentioned. It self-grades with its own subagent: "I'd spawn one grader subagent (model: \"opus\")". It then reports "with-skill X/Y... trigger evals were 6/6" and closes with "Tell me if you want any of these changed."
- case 2 new: Rewrites the description into third-person 'what it does. Use when <trigger>' form with a concrete trigger — No new description is written. It only plans one: "rewrite the `description` frontmatter (third person, what + concrete 'Use when…')", then stops: "Please answer these before I draft the new description."
- case 3 baseline: Asks clarifying questions about trigger, scope, and success criteria — Trigger and scope are asked: "When should it trigger?" and "Scope: just for you in this repo... or published as a plugin". Success criteria are not: "what should the result be (a chat reply, a markdown file...)" asks about output format, not what a good result looks like.
- case 4 new: Scaffolds 3-5 realistic evals/evals.json cases anyway — No eval cases are written. The answer defers them: "No frontmatter, body, scaffold or evals until you approve" and "Evals: required (rule 8), 3–5 cases, written in stage 4."
- case 4 new: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — No SKILL.md is produced. Scope appears only in plan.md ("DOES: ... Does NOT: bump versions"), and there is no red-flags section anywhere.
- case 4 baseline: Declines to skip evals, explaining they are required (rule 8) — Answer complies with skipping: "I'd create the skill without evals, as you asked." and "Skip the `evals/` directory."
- case 4 baseline: Scaffolds 3-5 realistic evals/evals.json cases anyway — No evals.json written; only a mental dry run on one sample input, and it suggests "two or three evals ... would be worth adding" later.
- case 4 baseline: Keeps SKILL.md lean and includes the guardrail sections (scope, red flags) — SKILL.md is lean but has only Structure, Entry rules, Editing an existing CHANGELOG.md, and Output sections. There is no scope or red-flags section.
