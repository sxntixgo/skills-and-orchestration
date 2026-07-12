---
name: skill-reviewer
description: Reviews a Claude Code skill against the repo's 8 authoring rules and proves it works via a baseline eval comparison (with-skill vs. disabled). Use when a skill was just created or edited, or when asked to review, evaluate, or benchmark a skill.
---

# Skill Reviewer

Judge a skill. `skill-creator` builds; you review. Always run the static rubric,
then always proceed toward the baseline evals — but STOP for approval before
spawning any isolated runs, because they cost tokens and time.

The 8 authoring rules this rubric scores against are detailed in
`references/rubric.md`. (When working inside this repo, the same rules are also
documented in `CLAUDE.md`.)

## Scope
This skill DOES:
- Score a skill against rules 1–8 (static rubric).
- Run a baseline eval comparison (with-skill vs. without-skill), or a blind A/B
  vs. the previous version for an edit.
- Render a PASS / ITERATE verdict with the top fixes.

This skill does NOT:
- Rewrite the skill → that's `skill-creator`. Report findings; the author fixes.
- Spawn any isolated run before the user approves at the Stage B gate.

## Workflow

Create a TodoWrite item per stage. Checkpoint the Stage A rubric findings to
`./.claude-skills-work/<skill>/review/` so a review can resume if interrupted.
(The Stage B eval RUNS use a separate workspace,
`./.claude-skills-work/evals/<skill>/iteration-N/` — see `references/running-evals.md`.
The two paths are intentionally distinct: review findings vs. generated runs.)

### Stage A — Static rubric (always)
Read the skill's `SKILL.md`, references, scripts, and `evals/evals.json`. Score
it against all 8 rules using `references/rubric.md`. Rate each finding:
🔴 Must fix · 🟡 Should fix · 🟢 Consider. Write findings to
`review/rubric.md` and report them. If rule 8 fails (no `evals/evals.json`),
say so — Stage B can't run without cases.

### Stage B — Baseline evals  ⛔ STOP GATE
1. Count the work: `cases × 2 = runs` (with_skill + without_skill). For an EDIT,
   the baseline is a snapshot of the previous version instead of "no skill".
2. **Report the run count and that each run is a fresh isolated context with its
   own token/time cost, then STOP and ask the user to approve before spawning
   anything.**
3. On approval, follow `references/running-evals.md`: spawn one subagent per run
   from a clean context, save outputs + a `timing.json` (tokens, duration) per
   run, grade each case against its `assertions` (or `expected_output` if
   assertions aren't written yet), and aggregate a workspace `benchmark.json`
   with `with_skill`, `without_skill`, and `delta`.

### Stage C — Verdict
Combine the rubric findings and the benchmark `delta` into a verdict:
- **PASS** — no 🔴 findings and the skill measurably helps (positive pass-rate
  delta at acceptable token/time cost).
- **ITERATE** — list the top fixes (🔴 first) and which eval cases regressed or
  failed, so `skill-creator` can address them.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| About to spawn runs without approval | STOP — the Stage B gate is mandatory |
| Editing the skill yourself | Don't — report findings; `skill-creator` fixes |
| Passing a skill on the rubric alone | A PASS also needs a positive eval delta |
| Grading a PASS on a vague assertion | Require concrete evidence; quote the output |
| Skipping Stage A because "evals will catch it" | Rubric is always run first |
| No `evals/evals.json` present | Report rule 8 failure; ask author to add cases |

## Done when
- Rubric findings are written and reported.
- Either the baseline benchmark exists with a `delta`, or the user declined the
  eval run at the gate (note that in the verdict).
- A PASS / ITERATE verdict is given with the top fixes.

## References (load only when needed)
- `references/rubric.md` — Stage A: the 8-rule checks + severity guidance.
- `references/running-evals.md` — Stage B: spawning runs, grading, aggregating.
