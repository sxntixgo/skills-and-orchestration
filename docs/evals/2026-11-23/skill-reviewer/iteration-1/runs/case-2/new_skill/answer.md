**Verdict: ITERATE.** The static rubric finds 3 🔴 issues, and Stage B (baseline evals) can't run because the skill has no eval cases.

**Assumptions:** you didn't name the skill or path, so I call it `<skill>` at `skills/<skill>/`. I assume rules 2–6 (self-contained, lean, single context, imperative, checkpointed) pass, because you only mentioned three problems. In the real session I'd read the whole skill before scoring.

**Steps, in order**

1. Create TodoWrite items: Stage A (rubric), Stage B (evals, blocked), Stage C (verdict).
2. Read `skills/<skill>/SKILL.md`, its `references/` and `scripts/`, and check whether `evals/evals.json` exists. It doesn't.
3. Score the skill against `references/rubric.md`.
4. Write the findings to `./.claude-skills-work/<skill>/review/rubric.md` so the review can resume if interrupted:

```
🔴 Rule 1 — description is vague and has no trigger (SKILL.md:3): "Helps with stuff". It needs to say, in third person, what the skill does, plus a concrete "Use when …" clause.
🔴 Rule 8 — evals/evals.json is missing. Add ≥3 realistic cases ({skill_name, evals[]: id/prompt/expected_output/files}). Stage B can't run without them.
🔴 Rule 7 — no Scope section, so there's no "does NOT" line and nothing stops scope creep. Add a Scope section with DOES/does NOT, and check that it has STOP gates, TodoWrite steps and a Red-flags table.
🟢 Rule 1 — once there's a real trigger, check it doesn't collide with a sibling skill's trigger.
```

5. **Stage B:** no runs. With 0 cases, `cases × 2 = 0` runs. I spawn no subagents and write no `benchmark.json`.
6. **Stage C:** give an ITERATE verdict. It can't be PASS: there are 🔴 findings and no eval delta.
7. I don't edit the skill. Fixes go to `skill-creator`.

**Reply to you**

> **ITERATE** — 3 must-fix issues:
> 1. **Rule 1:** "Helps with stuff" can't trigger the skill reliably. Rewrite it as "<Does X>. Use when <concrete situation/phrases>."
> 2. **Rule 8:** there's no `evals/evals.json`, so I can't run a baseline comparison. Add at least 3 realistic prompts that should trigger this skill, each with an `expected_output`.
> 3. **Rule 7:** there's no Scope section. Add what the skill DOES and does NOT do, plus STOP gates and red flags where scope could grow.
>
> Findings are saved to `.claude-skills-work/<skill>/review/rubric.md`. Fix these with `skill-creator`, then ask me to review again. Once evals exist, I'll report the run count (cases × 2) and wait for your approval before spawning anything.