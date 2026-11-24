I'd take this on, but I'd aim the tests at the behavior in utils rather than at the 100% number. If lines are still uncovered after that, I'd report them instead of writing tests that exist only to touch them.

**What I'm assuming** (none of this is visible to me):
- "The utils file" is `src/utils.ts`. It's the only utils file in a TypeScript project that uses Vitest with `@vitest/coverage-v8`.
- It already has some tests in `src/utils.test.ts`.
- It exports `slugify`, `chunk`, `formatCurrency` and `parseISODate`.
- If several utils files exist, I'd stop and ask which one you mean.

## Steps

1. **Create todo items** for the skill's four steps: contract, cases, write tests, run and confirm.

2. **Get a baseline:**
   ```
   npx vitest run src/utils.test.ts --coverage --coverage.include=src/utils.ts
   ```
   I'd note the current coverage and the uncovered lines or branches. I'd use those as a pointer to behavior that isn't tested yet, not as the goal.

3. **Read `src/utils.ts` and the existing tests**, and write down what each exported function promises. I'd test only the exported functions, not private helpers.

4. **Write the case list** to `./.claude-skills-work/writing-tests/utils/cases.md` before writing any tests:
   ```markdown
   # utils — cases
   ## slugify(s)
   - happy: "Hello World" → "hello-world"
   - boundary: "" → ""; single char
   - edge: unicode "Café Ñandú" → "cafe-nandu"; repeated/leading/trailing separators collapse
   - edge: already-slug input unchanged
   ## chunk(arr, size)
   - happy: [1..5], 2 → [[1,2],[3,4],[5]]
   - boundary: [] → []; size == length; size > length; size 1
   - error: size 0 / negative / non-integer → throws RangeError
   ## formatCurrency(n, currency)
   - happy: 1234.5, "USD" → "$1,234.50"
   - boundary: 0; negative; rounding at .005
   - error: NaN/Infinity → throws
   ## parseISODate(s)
   - happy: "2026-11-23" → Date (UTC)
   - boundary: leap day 2024-02-29 valid; 2025-02-29 invalid
   - error: malformed / empty → returns null (per current contract)
   ## Uncovered lines not tied to a behavior
   - (filled after step 7)
   ```

5. **Write the tests** in `src/utils.test.ts`, matching the file's existing style:
   - one behavior per test, each named for what it expects (for example, `it("throws RangeError when size is 0")`)
   - Arrange–Act–Assert
   - no real clock or locale: `formatCurrency` gets a fixed locale, and dates are pinned with `vi.useFakeTimers()` or explicit UTC inputs

6. **Run the tests** with `npx vitest run src/utils.test.ts`. Any test I add for a known bug has to fail for the right reason. If a new test passes straight away against existing code, I'd break the code briefly to check that the test can fail.

7. **Run coverage again** with the same command as step 2. For each line still uncovered, I'd decide which of these it is:
   - **Untested behavior:** add a case to `cases.md` and a test.
   - **Unreachable or dead code** (for example, a branch already ruled out by an earlier check): don't test it. Flag it in `cases.md` for you to delete.
   - **Defensive code that's only reachable by mocking internals:** leave it uncovered or mark it `/* v8 ignore next */`, but only if you agree.

## Final reply (example)

> `src/utils.ts` coverage went from 72% to 97% lines (94% branches) with 18 new tests in `src/utils.test.ts`, all passing. They cover the normal cases, edge cases, limits and error handling for `slugify`, `chunk`, `formatCurrency` and `parseISODate`. The case list is in `.claude-skills-work/writing-tests/utils/cases.md`.
>
> The 3% that's left is a fallback in `parseISODate` (L41–43) that can never run, because the regex check earlier already rejects those inputs. I didn't write a fake test for it. To get to 100%, either:
> - delete the dead branch (my recommendation), or
> - add `/* v8 ignore next */`.
>
> Which do you want?
>
> One finding: `chunk([...], 0)` loops forever instead of throwing. I added a test for it that currently fails, so the suite is red until `chunk` throws on a size of 0. Should I fix it?