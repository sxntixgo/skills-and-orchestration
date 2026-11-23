**Steps, in order:**

1. TodoWrite: `Stage A — static rubric`, `Stage B — baseline evals (gate)`, `Stage C — verdict`.
2. Read `skills/writing-tests/SKILL.md`, then `ls -R skills/writing-tests/` to look for `references/test-design.md`, `scripts/`, and `evals/evals.json`.
   - **My assumptions:** the case files contain only `SKILL.md` (68 lines). I assume `references/test-design.md` exists and matches its description at SKILL.md:66-67. I assume **`evals/evals.json` is missing**.
3. Score the skill against rules 1–8 using `references/rubric.md`.
4. Write `./.claude-skills-work/writing-tests/review/rubric.md` with the findings list below.
5. Stage B: rule 8 fails, so there are no cases and nothing to count or run. I don't reach the approval gate and spawn no subagents.
6. Stage C: give the verdict.

**File written: `./.claude-skills-work/writing-tests/review/rubric.md`**

```
# writing-tests — rubric review (2026-11-23)

🔴 Rule 8 — no evals/evals.json. Stage B (baseline eval) cannot run. Add ≥3 realistic
   cases: skill_name, evals[] with id/prompt/expected_output/files (+ assertions).
🟡 Rule 7 — no STOP gate where scope can expand (SKILL.md:24-48). Add stop-and-ask when:
   (a) the unit's contract/expected behavior is ambiguous (Step 1): ask, don't guess;
   (b) the project has no test framework: ask before choosing/installing one;
   (c) Step 4 exposes a production bug: report it, don't fix it (scope → software-development).
🟡 Rule 6 — only the case list is checkpointed (SKILL.md:21-22, 35). Step 1's contract and
   per-case progress aren't saved, so after an interruption in Step 3 you can't tell which
   tests are written or green. Write the contract into cases.md and mark each case
   written / failing-correctly / passing.
🟢 Rule 1 — "when the TDD loop needs to know which cases to write" (SKILL.md:3) assumes a
   TDD skill. Check that its trigger doesn't overlap a sibling TDD/software-development skill.
🟢 Rule 5 — Step 4 says "Run the tests" without saying how. Add: find the command from the
   project config (package.json scripts, Makefile, pytest.ini…); ask if it's unclear.
🟢 Rule 5 — "Done when" (SKILL.md:61) requires every category for every behavior. Say
   "each applicable category", or authors will pad with meaningless cases.
🟢 Rule 6 — `<unit>` in the checkpoint path (SKILL.md:22) is undefined. Specify a slug
   (e.g. module/function name, kebab-case).

Passing: rule 1 (name = dir, third person, concrete trigger), rule 2 (no external deps;
software-development is a scope pointer, not a hard dependency), rule 3 (68 lines, reference
named at point of use), rule 4 (single context, no subagents), rule 5 (imperative steps
and red-flags table).
```

**Logged:** the Stage A todo is complete. The Stage B todo is blocked because there's no `evals/evals.json`. The Stage C todo is complete with an ITERATE verdict.

---

**Final reply to the user:**

**Verdict: ITERATE.** The skill is well built, but it has no `evals/evals.json`, so I couldn't run the baseline comparison and there's no evidence yet that it helps.

**Findings** (saved to `.claude-skills-work/writing-tests/review/rubric.md`):

- 🔴 **Rule 8:** `evals/evals.json` is missing, so no eval runs are possible. Add at least 3 realistic cases with assertions, for example:
  - "Write tests for this `parseDuration(str)` function" (with a fixture file).
  - "Which cases should I test for this signup endpoint that returns 409 on duplicate email?"
  - "Add tests to this flaky date-based util."
- 🟡 **Rule 7:** there are no STOP gates. The skill should ask instead of guessing when:
  - the expected behavior is unclear;
  - there's no test framework yet;
  - the tests expose a bug in the production code. It should report the bug, not fix it.
- 🟡 **Rule 6:** only the case list is checkpointed. Add the contract to `cases.md` and record each case's status so Step 3 can resume after an interruption.
- 🟢 **Rule 1:** check that the "TDD loop" trigger doesn't overlap a sibling skill's trigger.
- 🟢 **Rule 5:** Step 4 should say how to find the test command, and "Done when" should say "each applicable category."
- 🟢 **Rule 6:** define the `<unit>` slug in the checkpoint path.

Rules 1–5 otherwise pass. The file is lean and imperative, has clear scope and red flags, and needs no subagents.

**Next:** use `skill-creator` to add the evals and the two 🟡 fixes, then ask me to review it again. At that point I'll report the run count (cases × 2) and wait for your approval before running anything.