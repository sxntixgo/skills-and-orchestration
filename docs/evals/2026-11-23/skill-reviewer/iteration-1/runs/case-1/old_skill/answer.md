**Verdict: the skill is solid and nearly ready. Fix the three blocking issues below before shipping.** It's short and well scoped, the description says when to use it, and the red-flags table is useful. The main gaps are around finding and running the project's tests, and around what to do when the tests run against code that already exists.

**What I'd do:** read `skills/writing-tests/SKILL.md`, list `skills/writing-tests/` and read `references/test-design.md` plus `evals/evals.json` if they exist. I wouldn't spawn subagents or log anything; this is a read-only review. For this run only `SKILL.md` was available. I assumed the reference file and evals may not exist yet, and I've flagged where that matters.

### Blocking
1. **No step for finding the framework.** Step 3 says "match the project's framework, file layout, and naming" and Step 4 says "run the tests", but nothing says how to find either. Add a Step 0:
   - Find the existing tests (glob `**/*test*`, `**/*_spec*`).
   - Read 1–2 nearby test files for style and for how they use test doubles.
   - Find the run command (`package.json` scripts, `pytest.ini`/`pyproject.toml`, `Makefile`, CI config).
   - Run the existing suite once to get a baseline. Without that, a failure you see later might have been failing already.
2. **"A test that can't fail tests nothing" only works for TDD.** When you add tests to existing code, they pass straight away and nothing proves they could fail. Add: "for existing code, briefly break the behavior (or invert the assertion), confirm the test goes red, then revert." Also say what the "RIGHT reason" means: an assertion failure on the expected behavior, not an import, syntax or setup error.
3. **No rule for when a test finds a real bug.** The scope says not to change production code, but the skill doesn't say what happens next. Add: "don't change the test to match buggy behavior. Report the bug, and leave the test failing or mark it as an expected failure (skip/xfail) with a reason, as the project does."

### Should fix
4. **The "Done when" rule conflicts with the anti-coverage rule.** "Every behavior has a test across happy/boundary/edge/error" pushes you to fill every category, even where it makes no sense, such as unicode for an integer function or unexpected types in a statically typed language. Change it to "the categories that apply, prioritized by risk", and add "where relevant" to the Edges list.
5. **`<unit>` in the checkpoint path isn't defined.** Say how to name it, for example a kebab-case slug of the function or module. Also add resume behavior: "if `cases.md` already exists, read it and continue instead of starting over."
6. **The reference file is a hard dependency.** Step 2 and the References section both point to `references/test-design.md`. If that file isn't there, either write it or drop the pointers.
7. **Add a red flag for weakening tests:** "Loosening or deleting an existing assertion to make the suite pass → stop. That hides a regression."

### Nice to have
- Description: add trigger words users actually type, like "unit tests", "what should I test", "test cases for X", "add coverage".
- Step 3: one line on where test doubles go: fake only the boundaries you don't own (clock, network, filesystem, random), and use real collaborators inside the unit.
- Evals: if there's no `evals/evals.json`, add about 3 cases:
  - TDD on a new function: tests must fail first, for the right reason.
  - Tests for existing code where one test finds a real bug: it gets reported, and the test isn't bent to fit the bug.
  - A request phrased as "get coverage to 90%": the skill should push back toward behavior and risk.

Want me to apply fixes 1–7?