**Stage A is done. Verdict: ITERATE.** The skill has no `evals/evals.json`, so I can't run the benchmark you asked for until it has test cases.

**What I'd do, in order:**

1. **TodoWrite:** add three items: Stage A rubric, Stage B evals (needs your approval), Stage C verdict.
2. **Parallel Reads** of `skills/online-research/`: `SKILL.md` (56 lines), any `references/*.md`, `evals/evals.json`, and a listing of `scripts/`. I'm assuming the folder holds only `SKILL.md`, which is all that `case-files/4/` contains, so there are no references, no scripts and no `evals.json`.
3. **Write** `./.claude-skills-work/online-research/review/rubric.md`:

```markdown
# online-research — rubric review (2026-11-24)

🔴 R8 Eval-backed — no evals/evals.json. Stage B cannot run.
   Need ≥3 cases (id, prompt, expected_output, files, objective assertions).

🟡 R6 Checkpointed — SKILL.md:18 names one notes.md but no step says what
   it writes there or how to resume. Specify: step 2 → query plan,
   step 3 → source table (URL/publisher/date/claims), step 4 → claim ×
   sources matrix, step 5 → answer.md; "resume from the last filled section".
🟡 R1 Trigger clash — check the description against the sibling
   opencode-research skill ("research, investigate"); add a line that tells
   the two apart.
🟢 R7 Guardrails — SKILL.md:19 has a clarify gate, but nothing stops scope
   creep mid-research. Add a search budget or stop rule ("N sub-questions
   answered or STOP and report gaps").
🟢 R6 — `<topic>` slug format unspecified (SKILL.md:18).

Pass: R2 (no external deps), R3 (lean, 56 lines), R4 (single context),
R5 (steps/table/template), R7 scope + Does NOT (SKILL.md:13-16) and Red flags.
```

4. **My reply:**

---

**Findings for `skills/online-research/`** (full list in `.claude-skills-work/online-research/review/rubric.md`):

- 🔴 **Rule 8: no `evals/evals.json`.** The baseline comparison can't run without cases.
- 🟡 **Rule 6, `SKILL.md:18`:** one notes file is named, but no step says what to write to it or how to resume. Each step should add a named section (query plan, source table, claim-by-source matrix, final answer).
- 🟡 **Rule 1:** check the trigger against the sibling `opencode-research` skill so the two don't fire on the same requests.
- 🟢 **Rule 7:** add a stop rule or search budget so the research can't keep growing.
- 🟢 **Rule 6, `SKILL.md:18`:** the `<topic>` slug format isn't specified.

Rules 2–5 pass, and so do the Scope section and Red flags table under Rule 7.

**Stage B ⛔:** with 0 cases there are 0 runs. A new skill is compared against no skill (`--baseline none`). At 4 cases it would be 4×2 runs plus 4×2 judge calls, so 16 calls ≈ $1.60 and about 5–10 minutes.

This repo has found that a skill only helps when it adds a process the model wouldn't follow anyway. So the cases should test that process with checkable assertions, for example:
- each key claim cites ≥ 2 independent sources;
- two reprints of one wire story are flagged as a single source;
- each time-sensitive fact carries a date;
- a "Gaps" section and a confidence level are present;
- with no web tool available, every claim is labelled unverified.

**Do you want to write ≥ 3 cases (or have `skill-creator` draft them)? Once they're in, I'll give you the exact run count and cost and ask: approve the eval run?**

Until then the verdict rests only on the rubric, and it's ITERATE because of the 🔴 above.