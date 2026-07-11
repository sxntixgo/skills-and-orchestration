---
name: skill-creator
description: Authors a new Claude Code skill or edits an existing one in this repo, enforcing the repo's 8 authoring rules and scaffolding evals. Use when the user asks to create, write, add, or edit a skill.
---

# Skill Creator

Build a skill through 5 gated stages. You BUILD the skill; you do NOT judge it —
`skill-reviewer` runs the rubric and baseline evals. End by handing off.

Read `CLAUDE.md` at the repo root first — it holds the 8 authoring rules every
skill must satisfy. This skill enforces them.

## Scope
This skill DOES:
- Create a new skill, or edit an existing skill in `skills/`.
- Clarify intent, draft frontmatter + body, scaffold `evals/evals.json`.
- Enforce authoring rules 1–8.

This skill does NOT:
- Run evals, grade, or render a verdict → that is `skill-reviewer`.
- Invent the skill's domain requirements → ask the user.
- Publish, install, or push anything.

## Workflow

Create a TodoWrite item for each of the 5 stages. Each stage writes its output
to `./.claude-skills-work/<skill>/` so work resumes if interrupted; say where
you wrote it.

### Stage 1 — Clarify intent  ⛔ STOP GATE
Nail three things and write them to `./.claude-skills-work/<skill>/plan.md`:
- **Trigger**: the concrete situation where this skill should fire ("use when…").
- **Scope**: what it DOES and, explicitly, what it does NOT do.
- **Success criteria**: observable signs the skill worked.

**Do not draft anything until the user approves this.** If the brief is vague or
you're inventing requirements, ask — do not guess.

### Stage 2 — Frontmatter
Draft `name` (kebab-case, == directory) and `description`. The description is
the ONLY thing Claude sees when deciding to load the skill, so the trigger must
be concrete. Read `references/writing-descriptions.md`. Show it; adjust.

### Stage 3 — Body
Draft the `SKILL.md` body: Scope block, a required-steps checklist (to be
surfaced via TodoWrite), STOP/checkpoint gates, a Red-flags list, and pointers
to any `references/*.md`. Keep it lean (< ~500 lines); push detail into
references. Read `references/skill-body.md` for the structure and the 8-rule
checklist. Show it.

### Stage 4 — Scaffold + evals
For a NEW skill, run `scripts/new_skill.sh <skill-name>` to create the directory
and stubs, then move your Stage 2–3 drafts into the generated `SKILL.md`. For an
EDIT, skip scaffolding. Then write 3–5 realistic cases in `evals/evals.json`.
Read `references/writing-evals.md` for the format and how to pick cases. Show them.

### Stage 5 — Hand off
Tell the user to run `skill-reviewer` on the new skill (rubric + baseline eval
comparison). Write a one-line resume pointer ("next: review") to
`./.claude-skills-work/<skill>/plan.md`. Do not self-judge.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Drafting the body before Stage 1 is approved | STOP — the Stage 1 gate is mandatory |
| A vague description ("helps with X") | Rewrite with a concrete trigger; sanity-check it against the eval prompts |
| Inventing requirements the user didn't state | Stop and ask |
| Skipping evals because "it obviously works" | Evals are required (rule 8); scaffold them |
| SKILL.md filling up with reference detail | Move detail to `references/`; keep the body lean |
| Mandating subagents in the new skill | Not allowed except dev-time evals (rules 4 & 8) |

## Done when
- The new/edited skill satisfies rules 1–8.
- `evals/evals.json` has 3–5 realistic cases.
- You have handed off to `skill-reviewer` and written the resume pointer.

## References (load only at the stage that needs it)
- `references/writing-descriptions.md` — Stage 2: the trigger/description.
- `references/skill-body.md` — Stage 3: body structure + 8-rule checklist.
- `references/writing-evals.md` — Stage 4: `evals.json` format + good cases.
- `references/examples.md` — calibration: one strong, one weak skill, annotated.
