I scored `writing-tests` against the 8 rules. It is not ready to pass yet: it has **1 must-fix**, which is that it has no evals. The writing itself is clear and well scoped. **Verdict so far: ITERATE**, and it can't be benchmarked until it has eval cases.

**Assumption:** the skill folder only has `SKILL.md` (49 lines), the one in `case-files/1/`. I'm treating `references/`, `scripts/` and `evals/` as not there.

**What I'd do, in order**
1. Create TodoWrite items: Stage A rubric, Stage B evals (gated), Stage C verdict.
2. Read in one parallel batch: `skills/writing-tests/SKILL.md`, `skills/writing-tests/references/*.md` (none), `skills/writing-tests/evals/evals.json` (not found), and list `skills/writing-tests/scripts/` (none).
3. Write the findings below to `./.claude-skills-work/writing-tests/review/rubric.md`.
4. Stop at the Stage B gate and start no eval runs. I won't edit the skill; fixes go through `skill-creator`.

## Findings (most severe first)

🔴 **Must fix**
- **Rule 8 — no evals.** `evals/evals.json` is missing, so the baseline comparison can't run. Add at least 3 realistic cases, each with `id`, `prompt`, `expected_output`, `files` and objective `assertions`.

🟡 **Should fix**
- **Rule 7 — guesses instead of asking (`SKILL.md:18-19`).** Nothing says to stop and ask when the unit's contract is unclear, or when the project has no test framework or none can be found.
- **Rule 7/5 — no step to find the framework (`SKILL.md:28-32`).** "Follow the project's layout and naming" assumes you already know the framework and the test command. Add a step 0: find the framework, an existing test file to copy the style from, and the run command.
- **Step 4 only covers TDD (`SKILL.md:33-34`).** When writing tests for code that already exists, it doesn't say how to show a test can fail. For example, break the code or the assertion briefly, check the test goes red, then put it back. It also doesn't say what to do when a new test exposes a real bug: report it, don't fix the production code (that's out of scope).

🟢 **Consider**
- **Rule 5 (`SKILL.md:28-32`):** Step 3 is one long run-on sentence. Split it into a checklist.
- **Rule 6 (`SKILL.md:17`):** `cases.md` is saved, but test results aren't. Add a pass/fail-per-case column so a run can resume and has evidence.
- **Rule 2/1 (`SKILL.md:3`, `:13`):** The `software-development` pointer is fine as a redirect. Check that "TDD loop" in the description doesn't trigger on the same requests as a sibling TDD skill.

**Passes:** Rule 1 (name, third-person "Use when"), Rule 3 (lean), Rule 4 (one context, no subagents), Rule 6 (main output is saved to disk), Rule 7 (Scope with a "does NOT" line, TodoWrite steps, Red flags).

## Stage B — baseline evals ⛔ approval needed

`evals.json` has **0 cases**, so there's nothing to run yet. Three cases I'd suggest adding:
1. **Boundary validator.** "Write tests for `validateAge(n)` (valid 18–65)" with a small JS file. Assertions: tests use 17, 18, 65 and 66; non-number/null cases; a `cases.md` written before the tests.
2. **API error paths.** "Add tests for POST /users" with an Express handler. Assertions: a 409 duplicate-email test; a test for invalid or missing input; asserts no partial write; no mock call count used as the assertion.
3. **Coverage pressure.** "Get this module to 100% coverage" on a small Python module. Assertions: the reply says 100% isn't the goal; tests are named after behaviour; the clock or randomness is stubbed.

With those 3 cases: **3 runs with the skill + 3 without = 6 runs, plus 6 judge calls = 12 calls**. Baseline is **`none`** because the skill is new. Each call is a fresh, isolated `claude -p`, about $0.10 and 20–40 s each, so **≈ $1.20 and about 4–8 minutes** in total.

Should I hand these cases to `skill-creator` to add to `skills/writing-tests/evals/evals.json`? Once they're in: **Approve the eval run?** If you skip the evals, the final verdict will rest on this rubric alone, and it can't be a PASS.