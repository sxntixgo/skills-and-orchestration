---
name: skill-creator
description: Authors a new Claude Code skill or edits an existing one in this repo, enforcing the repo's 8 authoring rules and scaffolding evals. Use when the user asks to create, write, add, or edit a skill.
---

# Skill Creator

Build a skill in 5 gated stages. You BUILD; `skill-reviewer` judges (rubric + baseline evals).
The 8 rules are checklisted in `references/skill-body.md` (also in this repo's `CLAUDE.md`).

## Scope
DOES: create a skill, or edit one in `skills/` (or a plugin's `skills/`); clarify intent;
draft frontmatter + body; scaffold `evals/evals.json`; enforce rules 1–8.
Does NOT: run evals or give a verdict (→ `skill-reviewer`); invent domain requirements (ask);
publish, install or push.

## Workflow
One TodoWrite item per stage. Each stage writes to `./.claude-skills-work/<skill>/` (say where)
so work can resume. **Read references in one batch** (parallel Reads) when you start drafting,
only the ones the stages ahead need — not one per turn.

1. **Clarify intent ⛔ STOP GATE.** Write to `plan.md`: **trigger** (the concrete "use when…"),
   **scope** (DOES / does NOT), **success criteria** (observable). Don't draft anything until the
   user approves; if the brief is vague, ask instead of guessing.
2. **Frontmatter.** `name` (kebab-case, = directory) and a third-person `description`: what it
   does + a concrete "Use when …" trigger — it's all Claude sees when choosing a skill
   (`references/writing-descriptions.md`). Show it.
3. **Body.** Scope block with a "does NOT" line, required steps (TodoWrite), STOP/checkpoint
   gates, Red flags, pointers to `references/*.md`. Lean (< ~500 lines); detail goes to
   references (`references/skill-body.md`). Show it.
4. **Scaffold + evals.** New skill: `scripts/new_skill.sh <name>`, then replace the skeleton with
   the approved drafts. Edit: no scaffold. Write 3–5 realistic cases with objective `assertions`
   in `evals/evals.json` (`references/writing-evals.md`). Evals are never skipped (rule 8). Show them.
5. **Hand off.** Tell the user to run `skill-reviewer`; write "next: review" to `plan.md`.
   Don't self-judge.

## Red flags
| If you notice… | Do this |
|---|---|
| Drafting before Stage 1 is approved | STOP: the gate is mandatory |
| A vague description ("helps with X") | Concrete trigger; check it against the eval prompts |
| Inventing requirements | Ask |
| "Skip the evals, it's simple" | Decline: rule 8; scaffold them |
| Reference detail filling SKILL.md | Move it to `references/` |
| Mandating subagents in the skill | Not allowed except dev-time evals (rules 4 & 8) |

## Done when
Rules 1–8 hold; `evals/evals.json` has 3–5 realistic cases with assertions; handed off to
`skill-reviewer` with the resume pointer written.

## References (batch-read when drafting)
`references/writing-descriptions.md` (stage 2) · `references/skill-body.md` (stage 3, 8-rule
checklist) · `references/writing-evals.md` (stage 4) · `references/examples.md` (calibration).
