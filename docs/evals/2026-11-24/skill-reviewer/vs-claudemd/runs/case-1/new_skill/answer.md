## What I'd do, in order

1. **TodoWrite** with three items: `Stage A — rubric`, `Stage B — baseline evals (gated)`, `Stage C — verdict`. Mark Stage A as in_progress.
2. **Read the whole skill in one parallel batch:** `skills/debugging/SKILL.md`, `skills/debugging/references/*.md`, `skills/debugging/evals/evals.json`, and a listing of `skills/debugging/scripts/`.
   - What I'm assuming: only `SKILL.md` exists (its contents are `case-files/1/SKILL.md`, 53 lines). There's no `references/`, no `scripts/` and no `evals/evals.json`, so I treat the eval file as not found.
3. **Write `./.claude-skills-work/debugging/review/rubric.md`:**

```markdown
# Rubric review: debugging (2026-11-24)

## 🔴 Must fix
- R8 skills/debugging/evals/evals.json: missing. Stage B can't run. Need ≥3 realistic cases
  (id, prompt, expected_output, files, objective assertions) that target the *process*
  (runs the repro before editing, verifies the cause, adds a regression test). A frontier model
  already knows debugging, so cases that only check the fix will show ~0 lift (cf. security-review).

## 🟡 Should fix
- R7 SKILL.md:17: the ⛔ on Reproduce doesn't say what it gates. State it: "no code edits until
  the repro runs and fails; if still not reproducible after gathering logs/versions, STOP and ask."
- R7 SKILL.md:32: no STOP when scope grows. If the root cause needs a non-minimal or cross-module
  change (design flaw, API change), STOP and propose it before editing.
- R6 SKILL.md:16: notes.md is named, but steps don't say what each one records or how to resume.
  Add: each step appends a `## <step>` section (repro cmd+output, hypotheses tried, verification);
  "Resume: read notes.md, continue at the first step without a section."

## 🟢 Consider
- R1 SKILL.md:3: possible trigger overlap with `software-development` (bug fixes) and `code-review`.
  Confirm their descriptions don't also claim "test failure / unexpected behavior".
- R4 SKILL.md:36,50-52: "Report" and "Done when" partly restate step 6. Could merge.

## Clean
R2 self-contained · R3 lean (53 lines) · R5 imperative (steps + red-flags table) ·
R7 has Scope/does-NOT, TodoWrite, Red flags.
```

4. Mark Stage A as completed and stop at the Stage B gate without starting anything.

## Reply to user

**Stage A: 1 🔴, 3 🟡, 2 🟢.** The body is solid, but Stage B can't run because `skills/debugging/evals/evals.json` doesn't exist. Full findings are in `.claude-skills-work/debugging/review/rubric.md`.

🔴 **Must fix**
- **R8: no `evals/evals.json`.** Add at least 3 cases. Write them to test the process, not just whether the bug got fixed. Debugging is knowledge the model already has, so the lift has to come from discipline. Suggested cases:
  1. Off-by-one pagination bug with a failing test fixture. Assert that the test runs before any edit, the cause is named, and the fix is minimal.
  2. Flaky test that depends on `Date.now()`. Assert that the clock or seed is injected and no sleep or retry is added.
  3. A "just add a null check" request where the real cause is a missing `await`. Assert that the cause gets fixed rather than the symptom guarded.
  4. Bug that can't be reproduced and has only a vague report. Assert that logs and versions are gathered, then it stops and asks instead of guessing at a fix.

🟡 **Should fix**
- **`SKILL.md:17`:** the ⛔ on Reproduce doesn't say what it gates. Say "no edits until the repro fails; still can't reproduce → STOP and ask."
- **`SKILL.md:32`:** there's no STOP if the real fix turns out to be a design or cross-module change. Add one so the skill proposes that change before making it.
- **`SKILL.md:16`:** `notes.md` is named, but there's no per-step format or resume instruction. Have each step append a section, and resume from the first step that's missing one.

🟢 **Consider**
- **`SKILL.md:3`:** check that the description doesn't overlap the triggers of `software-development` and `code-review`.
- **`SKILL.md:36,50`:** "Report" and "Done when" partly repeat step 6.

**⛔ Stage B, baseline evals:** this can't start until `evals.json` exists. With the 4 cases above, it would be 4 × 2 runs plus 4 × 2 judge calls, so 16 isolated `claude -p` calls (about $1.60 and 20–40 s each). The baseline is `none` because this is a new skill. Want to add the cases with `skill-creator` and then approve the eval run? Until then there's no verdict: a PASS needs a positive eval delta, not just the rubric.