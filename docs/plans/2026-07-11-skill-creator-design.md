# skill-creator — Design

Date: 2026-07-11
Status: Approved (brainstormed with user), ready to build

## Purpose

`skill-creator` authors new skills (and edits existing ones) in this repo,
enforcing the 8 authoring rules in `CLAUDE.md`. It builds; it does not judge —
`skill-reviewer` runs the rubric and baseline evals.

## Boundary with skill-reviewer

| skill-creator | skill-reviewer |
|---------------|----------------|
| Clarify intent, draft frontmatter + body, scaffold evals | Rubric check, run baseline eval comparison, blind A/B between versions |
| Ends by handing off to skill-reviewer | Independent quality/eval pass |

Clean separation, no overlap. skill-creator does NOT self-judge.

## Workflow — 5 gated, checkpointed stages

Each stage writes output to `./.claude-skills-work/<skill>/` so work resumes
mid-creation. The 5 stages are surfaced as TodoWrite items.

| Stage | Action | Gate |
|-------|--------|------|
| 1. Clarify intent | Nail trigger ("use when…"), scope (does / does NOT), success criteria. Write to `.plan.md` | **STOP — user approves before any drafting** |
| 2. Frontmatter | Draft `name` + `description` (trigger is the highest-value part) | show, adjust |
| 3. Body | Draft `SKILL.md`: scope, required-steps checklist, STOP gates, red flags, references pointers | show |
| 4. Scaffold evals | Run `scripts/new_skill.sh`; draft 3–5 realistic cases in `evals/evals.json` | show |
| 5. Hand off | Point user to `skill-reviewer`; write resume pointer | — |

Editing an existing skill uses the same flow, skipping scaffolding in stage 4.

## File structure

```
skills/skill-creator/
  SKILL.md                       # 5-stage workflow, scope, guardrails, red flags
  scripts/new_skill.sh           # deterministic scaffold (dir tree + stub files)
  references/
    writing-descriptions.md      # how to write the trigger/description
    skill-body.md                # SKILL.md body structure + the 8-rule checklist
    writing-evals.md             # evals.json format + writing good cases
    examples.md                  # 1 strong + 1 weak skill, annotated
  evals/evals.json               # skill-creator's OWN eval cases
```

Loading discipline: `SKILL.md` names each reference at the stage that needs it,
keeping default context small and stages resumable.

## Scaffold script

`scripts/new_skill.sh <skill-name>` — deterministic, idempotent, refuses to
overwrite an existing skill. Creates:

```
skills/<name>/
  SKILL.md                 # skeleton: frontmatter + section headers + TODO markers
  evals/evals.json         # stub with one example case
  references/.gitkeep
```

The skeleton bakes rules 6–7 (checkpoint convention + scope/red-flags sections)
into every skill by construction. Checkpoint working dir convention:
`./.claude-skills-work/<name>/`.

`evals/evals.json` field names to be confirmed against
https://agentskills.io/skill-creation/evaluating-skills before finalizing.

## Guardrails (red flags baked into skill-creator's SKILL.md)

| Red flag | Correction |
|----------|------------|
| Drafting body before intent approved | STOP — stage 1 gate is mandatory |
| Vague description ("helps with X") | Rewrite with concrete trigger; test vs eval prompts |
| Inventing domain requirements user didn't state | Stop and ask |
| Skipping evals ("obvious it works") | Evals required (rule 8); scaffold them |
| Bloating SKILL.md with reference detail | Move to `references/`; keep body lean (rule 3) |
| Mandating subagents in the new skill | Only evals may use isolated runs (rule 4/8) |

## Self-application

skill-creator's own `evals/evals.json` includes cases like "create a skill from
this brief" and "edit this skill's trigger". Validate skill-creator by running
it through skill-reviewer (the tandem loop).
