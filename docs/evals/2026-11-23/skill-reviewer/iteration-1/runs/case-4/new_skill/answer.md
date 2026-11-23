**Verdict: ITERATE.** `online-research` is well built, but it has no `evals/evals.json`, so the eval comparison you asked for can't run. I spawned nothing.

**Assumption:** `case-files/4/` only had `SKILL.md`. I couldn't find `evals/evals.json` or `references/source-evaluation.md` there. I'm treating the evals file as missing and the reference file as present, since `SKILL.md:47` points to it.

### What I'd do, in order
1. Create TodoWrite items: Stage A (rubric), Stage B (baseline evals, gated), Stage C (verdict).
2. Read `skills/online-research/SKILL.md`, `references/source-evaluation.md`, any scripts, and `evals/evals.json`. The last one is missing.
3. Check for sibling skills whose triggers might overlap. Recent commits mention `opencode-research`, so it probably exists.
4. Write the findings below to `./.claude-skills-work/online-research/review/rubric.md`.
5. Stage B: stop here, because there are no cases to run. I wouldn't write the cases myself, since fixing the skill is `skill-creator`'s job.
6. Stage C: give the verdict below.

### Rubric findings (`review/rubric.md`)
```
🔴 Rule 8 — no evals/evals.json. Stage B (with_skill vs without_skill) cannot run.
🟡 Rule 1 — the trigger "research, investigate, fact-check, or find current/authoritative
   information online" (SKILL.md:3) probably overlaps with the sibling opencode-research
   skill. Say what separates them (e.g. "in-session web research with WebSearch/WebFetch,
   not delegated to opencode").
🟡 Rule 7 — step 3 Gather (SKILL.md:41-44) has no budget and no stop point. Add a cap
   (e.g. sources or searches per sub-question) and a STOP-and-ask if the scope grows
   past it.
🟢 Rule 6 — the <topic> slug in the notes path (SKILL.md:28) isn't defined. Also, the
   final synthesis isn't checkpointed; consider writing it to answer.md.
🟢 Rule 1 — the description is long. Consider cutting the method list so the
   "Use when" trigger stands out.
```
Rules 2–5 pass. The skill is self-contained, lean at about 78 lines, mentions its reference where it's used, needs no subagents, and is written as imperative steps. It also has clear guardrails: a does-NOT scope, TodoWrite steps, a STOP gate at step 1, and a red-flags table.

### Your next step
Add `skills/online-research/evals/evals.json` with at least 3 realistic cases. Use the format `skill_name`, `evals[]`, and give each case `id`/`prompt`/`expected_output`/`files`, plus `assertions` if you can. Good cases to cover:
- a time-sensitive question that needs recent sources;
- a fact-check where one widely copied wire story could look like several sources;
- an ambiguous question that should trigger the step 1 STOP.

Once that's in, I'll re-run Stage A and give you the run count (cases × 2, with and without the skill). Each run is a fresh isolated context with its own token and time cost, so I'll wait for your go-ahead before spawning any. Even with the 🔴 fixed, a PASS still needs a positive pass-rate delta from those runs.