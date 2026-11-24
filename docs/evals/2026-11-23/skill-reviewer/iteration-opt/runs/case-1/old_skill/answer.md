I'm reviewing the static rubric only. `evals/evals.json` wasn't among the case files, so Stage B can't run.

## What I'd do, in order

1. **TodoWrite:** add three items: Stage A (rubric), Stage B (baseline evals), Stage C (verdict).
2. **Read** `skills/writing-tests/SKILL.md`, which is 49 lines, plus `references/`, `scripts/` and `evals/evals.json`. I assume there are no references or scripts. `evals/evals.json` was not provided, so I treat it as **not found**.
3. **Write** `./.claude-skills-work/writing-tests/review/rubric.md`:

```
# writing-tests — Stage A rubric

🔴 Rule 8 — No evals/evals.json. Stage B (baseline with/without skill) cannot run.
   Add ≥3 realistic cases ({skill_name, evals[]: id/prompt/expected_output/files}), e.g.:
   - "Write tests for validateAge(age) that accepts 18–65" → expects 17/18/19, 64/65/66 boundaries + type/null errors
   - "Add tests for POST /users (409 on duplicate email)" → expects error-path asserts incl. no partial write
   - "Get this module to 100% coverage" → expects pushback that coverage isn't the goal + risk-based cases
🟡 Rule 7 — No STOP gate for when a new test exposes a bug in existing (non-TDD) code.
   Scope forbids touching production code, but Step 4/"Done when" require green tests and
   don't say what to do instead. Add: "test fails on existing code → STOP, report the bug, don't fix it" (SKILL.md:33-34, 46-48).
🟡 Rule 7 — No stop-and-ask when the contract is unclear (SKILL.md:18). Guessing the
   contract produces tests that lock in wrong behaviour. Add a step or red flag: "contract ambiguous → ask".
🟢 Rule 5 — Step 3 says "project's framework/layout" but no step finds them
   (read existing tests, test runner command) before writing (SKILL.md:31-32).
🟢 Rule 6 — Checkpoint path uses <unit> without defining it (file? function? feature?) (SKILL.md:17).
🟢 Rule 1 — "when the TDD loop needs to know which cases" may overlap a sibling TDD/
   software-development trigger; check the descriptions don't both fire for "write tests".
```

   Rules 2, 3 and 4 have no findings. The pointer to `software-development` is a scope redirect, not a hard dependency. The skill is lean and runs in a single context.

4. **Stage B:** I didn't run it because there are no cases to run. That makes the run count 0, so the approval gate never came up.
5. **Stage C:** verdict below.

## Final reply to user

**Verdict: ITERATE.** The content is solid: concrete, imperative, well-scoped and lean. But there are no eval cases, so I couldn't run the comparison with and without the skill. Without that comparison I can't give a PASS.

Findings (written to `.claude-skills-work/writing-tests/review/rubric.md`):

- 🔴 **Rule 8:** `evals/evals.json` is missing, which blocks Stage B. Add at least 3 cases. Suggested cases:
  - Boundary tests for an age-range validator.
  - Error paths for an endpoint, including a 409 on duplicate input with no partial write.
  - A "get to 100% coverage" request, where the skill should push back.
- 🟡 **Rule 7:** The skill doesn't say what to do when a new test exposes a bug in existing code. Its scope forbids fixing production code, but "Done when" requires green tests. Add a STOP: report the bug and don't fix it (SKILL.md:33-34, 46-48).
- 🟡 **Rule 7:** There's no stop-and-ask when the contract is ambiguous (SKILL.md:18).
- 🟢 Add a step to find the existing test framework, layout and run command before writing tests (SKILL.md:31-32).
- 🟢 Define `<unit>` in the checkpoint path (SKILL.md:17).
- 🟢 Check that the "TDD loop" trigger doesn't collide with a sibling skill's trigger.

Top fixes: add the eval cases, then the two STOP gates. Once the evals exist, ask me to review again. I'll do 2 isolated runs per case (with and without the skill) and wait for your approval before starting them.