---
name: skill-reviewer
description: Reviews a Claude Code skill against the repo's 8 authoring rules and proves it works via a baseline eval comparison (with-skill vs. disabled). Use when a skill was just created or edited, or when asked to review, evaluate, or benchmark a skill.
---

# Skill Reviewer

Judge a skill; `skill-creator` builds and fixes it. Always run the rubric (Stage A), then always
end that reply at the Stage B gate. Never edit the target skill.

## Scope
DOES: score a skill against rules 1–8; run a baseline eval (with vs without the skill, or old vs
new version for an edit) after approval; give PASS / ITERATE with the top fixes.
Does NOT: rewrite the skill (→ `skill-creator`); start any eval run before the user approves.

## Stage A — rubric (one TodoWrite item per stage)
In one turn: run `python3 <skill-authoring>/skills/skill-creator/scripts/check_skill.py <skill dir>`
(the mechanical checks: frontmatter, trigger, size, sections, references, eval format) and read
the target's `SKILL.md`, `references/*.md` and `evals/evals.json` in parallel. Each FAIL line is a
🔴, each WARN a 🟡/🟢 by judgment; don't recheck by hand what the script checked. Then judge the
rest; record only problems, rated
🔴 must fix (breaks the skill, scope/safety violation, blocks evals) · 🟡 should fix · 🟢 consider,
each with `file:line`:

| Rule | Check |
|---|---|
| 1 Frontmatter | `name` kebab-case = directory; third-person `description` with a concrete "Use when …" (🔴 if missing/vague); no trigger clash with siblings |
| 2 Self-contained | no hard dependency outside its plugin (🔴); a sibling plugin's skill only as "if installed" with a fallback |
| 3 Progressive disclosure | `SKILL.md` lean (< ~500 lines); detail in `references/`, named where used |
| 4 Token-frugal | one context window; subagents only as a measured default with an inline fallback (🔴 if mandatory); no knowledge the model already has (🟡: measured 0 lift); no small `references/` or "read X first" (each read is a turn) |
| 5 Imperative | steps, checklists, tables — not an essay (🟡) |
| 6 Checkpointed | multi-step skills write each step's output to disk and say where (🔴 if none) |
| 7 Guardrails | Scope with a "does NOT" line; TodoWrite steps; STOP gates where scope could grow; Red flags; asks instead of guessing |
| 8 Eval-backed | ≥ 3 realistic cases with evidence-only assertions (🔴 if missing: Stage B can't run); a fixture whenever the skill works on input (🟡 a case with nothing to work on, unless it tests stopping); scripts have tests |

Write the findings (most severe first) to `./.claude-skills-work/<skill>/review/rubric.md` and
report them.

## Stage B — baseline evals ⛔ STOP GATE (end the Stage A reply with this, every time)
State, with real numbers from `evals.json`: **cases N → runs = N × 2, plus N × 2 judge calls**;
the baseline (`none` for a new skill; the previous git revision for an edit, graded blind); and
the cost (each call is a fresh isolated `claude -p`: about $0.10 and 20–40 s; e.g. 4 cases = 16
calls ≈ $1.60). Then ask: "Approve the eval run?" Start nothing until the user says yes, even when
they asked to "run the benchmark".

On approval, from the repo root (details: `scripts/evals/README.md`):
```
python3 scripts/evals/abeval.py run    --skill <skill dir> --baseline <none|HEAD> --out .claude-skills-work/evals/<skill>/iteration-N
python3 scripts/evals/abeval.py grade  --out <same>
python3 scripts/evals/abeval.py report --out <same>     # benchmark.json + report.md
```
Without the script, follow `references/running-evals.md` (manual subagent method).

## Stage C — verdict
Report pass rate and **tokens + turns per run** for both sides (from `report.md`). **PASS**: no 🔴
and a positive pass-rate delta at acceptable cost. **ITERATE**: a numbered fix list for
`skill-creator`, each `file:line — problem — change` (🔴 first), plus the failing or regressed
cases with the judge's quoted reason; flag runs with > 3 turns (a read the page could avoid).
If the user declined Stage B, say the verdict rests on the rubric only.

## Red flags
| If you notice… | Do this |
|---|---|
| About to run evals without a yes | STOP: the gate is mandatory |
| Ending Stage A without the run count, cost and question | Add them |
| Editing the target skill | Don't; report findings |
| PASS on the rubric alone | A PASS also needs a positive eval delta |
| A PASS on vague evidence | Quote the output |
| No `evals/evals.json` | Rule 8 🔴; ask for cases |

## Done when
Rubric findings written and reported; Stage B either run (benchmark with deltas for pass rate,
tokens, turns) or declined at the gate; PASS or ITERATE given with the fix list.
