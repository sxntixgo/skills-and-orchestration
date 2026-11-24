The skill reads well, but I can't run the eval comparison yet: `skills/online-research/evals/evals.json` doesn't exist. Only `SKILL.md` was provided, so I'm treating `evals/`, `references/` and `scripts/` as not found. That's a 🔴 under Rule 8, which means Stage B is blocked until you supply test cases.

**What I'd do, in order**

1. TodoWrite with 3 items: Stage A rubric · Stage B evals (gated) · Stage C verdict.
2. Read in one parallel batch: `skills/online-research/SKILL.md`, `skills/online-research/references/*.md`, `skills/online-research/evals/evals.json`, and `ls skills/online-research/scripts/`. Only `SKILL.md` (56 lines) exists.
3. Score rules 1–8. No edits to the target skill.
4. Write `./.claude-skills-work/online-research/review/rubric.md`:

```markdown
# online-research — rubric review
🔴 R8 Eval-backed: no evals/evals.json → Stage B cannot run. Need ≥3 cases
   (id, prompt, expected_output, files, objective assertions).
🟡 R4/R7 SKILL.md:21-30: no stopping rule or search budget (max query rounds or
   pages opened). Context can blow up on broad topics, and the scope can grow
   with no STOP gate.
🟡 R6 SKILL.md:31: the final answer isn't written to disk. Save it to
   <topic>/answer.md, or append it to notes.md.
🟢 R7 SKILL.md:19-20: "Clarify ⛔" conflicts with "Ask only if ambiguous".
   Make the gate conditional.
🟢 R6 SKILL.md:18: <topic> slug is undefined (e.g. kebab-case of the question).
🟢 R1: check the trigger overlap with sibling research skills
   (claude-orchestrate-research, opencode-research). Add a "not for …" clause
   if they overlap.
Rules 2, 3, 5: OK.
```

5. Stop at the Stage B gate. No subagents and no `abeval.py` runs.

**Reply to the user**

> **online-research review: 1 🔴, 2 🟡, 3 🟢** (written to `.claude-skills-work/online-research/review/rubric.md`)
>
> - 🔴 **R8:** there is no `evals/evals.json`, so the benchmark you asked for can't run.
> - 🟡 `SKILL.md:21-30`: there's no stopping rule or budget for searches and page fetches.
> - 🟡 `SKILL.md:31`: the final answer isn't saved to disk.
> - 🟢 `SKILL.md:19` says "Clarify ⛔" but also "ask only if ambiguous", which conflicts. `SKILL.md:18` uses a `<topic>` slug it never defines. There may be trigger overlap with sibling research skills.
>
> Rules 2, 3 and 5 pass: it has no outside dependencies, it's lean, and it's written as steps.
>
> **Stage B ⛔:** I can't give a real run count because there are 0 cases. Each run needs ≥ 3 cases: runs = N × 2, plus N × 2 judge calls, at about $0.10 and 20–40 s per call. For example, 3 cases = 12 calls ≈ $1.20, and 4 cases = 16 calls ≈ $1.60. The baseline would be `HEAD`, graded blind, if this is an uncommitted edit, or `none` if the skill is new.
>
> Can you add ≥ 3 realistic cases? Good candidates: a time-sensitive fact, a contested claim where one wire story is reprinted, and a "no web tool available" case. Each needs objective assertions, such as "every claim has ≥2 cited URLs" or "states confidence and gaps". Or should I draft them for you to approve?
>
> Once the cases exist: **approve the eval run?** Until then the verdict rests on the rubric only, which means **ITERATE**. The 🔴 blocks a PASS.