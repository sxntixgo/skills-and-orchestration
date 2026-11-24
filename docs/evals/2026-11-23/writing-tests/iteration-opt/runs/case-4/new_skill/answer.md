I'll test every behaviour and failure mode in the utils file instead of aiming for 100% line coverage. I'll then list any lines left uncovered and say why.

**Assumptions** (nothing is on disk): the file is `src/utils.ts` and the only one of that name. It exports `clamp(n, min, max)`, `chunk(arr, size)`, `slugify(s)`, `parseIsoDate(s)` (throws on invalid input) and `debounce(fn, ms)`. The project uses Vitest, with tests in `src/__tests__/*.test.ts`. If there's more than one utils file, I'd stop and ask which one.

**Steps, in order**

1. TodoWrite items: contract, enumerate cases, write tests, run with coverage, report.
2. Read the context:
   - `ls src; cat src/utils.ts`
   - `cat package.json vitest.config.ts`
   - `ls src/__tests__` to match the existing naming and style.
3. Note each function's contract: inputs, return value or throw, side effects. Private helpers are only tested through the exported functions.
4. Write `./.claude-skills-work/writing-tests/utils/cases.md`:
   ```markdown
   # utils — cases
   ## clamp
   - happy: value inside range returns unchanged
   - boundary: n = min-1, min, min+1; max-1, max, max+1
   - error: min > max throws RangeError
   - edge: NaN input → NaN (current behaviour; confirm intended)
   ## chunk
   - happy: [1..5], size 2 → [[1,2],[3,4],[5]]
   - boundary: empty array → []; size = length → one chunk; size 1
   - error: size 0 / negative / non-integer throws
   ## slugify
   - happy: "Hello World" → "hello-world"
   - edge: unicode/accents ("Crème Brûlée" → "creme-brulee"), repeated/leading/trailing separators, empty string → ""
   ## parseIsoDate
   - happy: valid ISO date → Date with matching UTC fields
   - boundary: 2024-02-29 valid, 2023-02-29 invalid
   - error: "", "not-a-date", null → throws with specific message
   ## debounce
   - happy: multiple calls within ms → fn called once with last args (fake timers)
   - boundary: call at ms-1 vs ms
   - edge: separate bursts → called once per burst
   ```
5. Write `src/__tests__/utils.test.ts`:
   - One behaviour per test, named after the expectation ("throws RangeError when min > max").
   - Arrange–Act–Assert, asserting on returned values or thrown errors.
   - `vi.useFakeTimers()` for `debounce` so the tests are deterministic. A `vi.fn()` is fine there because the call itself is the behaviour.
   - No mocking of internals.
6. Run `npx vitest run src/__tests__/utils.test.ts --coverage --coverage.include=src/utils.ts`.
   - Confirm each new test can fail for the right reason by briefly breaking one boundary, e.g. changing `<` to `<=` in `clamp`, then reverting.
   - Fix test mistakes only. If a test exposes a real bug, such as `chunk` looping forever on size 0, I'd report it and not change production code.
7. Check the coverage report. For any line still uncovered:
   - If it's a failure mode or real branch, add a test for it.
   - If it's trivial or unreachable (a defensive `default:` or a type-only guard), leave it and list it.

**Final message (template)**

> Added `src/__tests__/utils.test.ts` with N tests across `clamp`, `chunk`, `slugify`, `parseIsoDate` and `debounce`. They cover the normal cases, the limits, the edge cases and the error paths. All N pass. The case list is in `.claude-skills-work/writing-tests/utils/cases.md`.
>
> Line coverage on `src/utils.ts` is X%. I didn't push it to 100% on purpose: the goal is to test behaviour and risk, and a 100% number can be hit with tests that assert nothing useful. Uncovered:
> - `utils.ts:LL`: an unreachable `default:` branch in `slugify`'s switch.
>
> Issues found:
> - `chunk(arr, 0)` currently [loops forever / throws]. Is that intended? I haven't changed production code.
> - `clamp(NaN, …)` returns NaN, and the tests pin that behaviour. Tell me if it should throw instead.