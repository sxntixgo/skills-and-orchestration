**What I'd do, in order:**

1. **TodoWrite** with four items: identify contract, enumerate cases (checkpoint), write tests, run and confirm.

2. **Find the framework and the unit.** I'd read `package.json` and run `grep -rn "isValidPassword" src`. *Assumption:* this is a JS project using Jest with colocated `*.test.js` files, and `src/validation/password.js` exports `isValidPassword(pw) → boolean`.

3. **State the contract (Step 1).** The function takes `pw` and returns `true` only when all three rules hold: length is 8 or more, there is at least one digit `[0-9]`, and there is at least one letter. It has no side effects.
   The spec leaves two things open, so I'd assume these and list them in the final reply:
   - "Letter" means ASCII `[A-Za-z]`.
   - Input that isn't a string returns `false` rather than throwing.

4. **Write the checkpoint** `./.claude-skills-work/writing-tests/isValidPassword/cases.md`:
   ```markdown
   # isValidPassword cases
   ## Happy
   - "abcdefg1" (8, letter+digit) → true
   - long mixed "Password1234567890" → true
   - with symbols "ab!@#$1c" → true
   ## Boundaries (length 7/8/9)
   - "abcdef1" (7) → false
   - "abcdefg1" (8) → true
   - "abcdefgh1" (9) → true
   - "" → false
   ## Partitions (one rule missing)
   - "abcdefgh" (no digit) → false
   - "12345678" (no letter) → false
   - "!@#$%^&*" (neither) → false
   - letter/digit at start vs end: "1abcdefg", "abcdefg1" → true
   - uppercase only letters "ABCDEFG1" → true
   ## Edges
   - whitespace counts as chars: "abc 123 " → true (assumed)
   - non-ASCII letters "éééééé12" → false (assumes ASCII letter)
   ## Error paths (assumed: return false, no throw)
   - null, undefined, 12345678 (number), ["abcdefg1"] → false
   ```

5. **Write `src/validation/password.test.js`:**
   ```js
   const { isValidPassword } = require('./password');

   describe('isValidPassword', () => {
     describe('accepts', () => {
       test.each([
         ['exactly 8 chars with letter and digit', 'abcdefg1'],
         ['9 chars', 'abcdefgh1'],
         ['a long password', 'Password1234567890'],
         ['symbols alongside letter and digit', 'ab!@#$1c'],
         ['digit first', '1abcdefg'],
         ['uppercase letters', 'ABCDEFG1'],
         ['spaces counted toward length', 'abc 123 '],
       ])('%s', (_, pw) => {
         expect(isValidPassword(pw)).toBe(true);
       });
     });

     describe('rejects', () => {
       test.each([
         ['empty string', ''],
         ['7 chars (one below minimum)', 'abcdef1'],
         ['no digit', 'abcdefgh'],
         ['no letter', '12345678'],
         ['neither letter nor digit', '!@#$%^&*'],
         ['non-ASCII letters only (no ASCII letter)', 'éééééé12'],
       ])('%s', (_, pw) => {
         expect(isValidPassword(pw)).toBe(false);
       });
     });

     describe('non-string input returns false', () => {
       test.each([null, undefined, 12345678, ['abcdefg1'], {}])('%p', (input) => {
         expect(isValidPassword(input)).toBe(false);
       });
     });
   });
   ```

6. **Run** `npx jest src/validation/password.test.js`.
   - If `isValidPassword` doesn't exist yet (TDD), every test should fail with "isValidPassword is not a function" or a module-not-found error. That's the right reason, and I'd report it as red.
   - If it exists, all tests should pass. To confirm the tests can fail, I'd temporarily change `>= 8` to `>= 7` and check that the 7-char case goes red, then revert.

**Final reply to user:**

> I added 18 tests for `isValidPassword` in `src/validation/password.test.js` (Jest). They cover the 7/8/9-char boundary, each rule missing on its own, letter or digit position, symbols and spaces, and non-string input. [Run result: all passing / failing as expected because the function isn't implemented yet.]
>
> I had to assume two things the spec doesn't say. Tell me if either is wrong and I'll adjust the tests:
> - Only ASCII `A–Z`/`a–z` count as letters, so `é` doesn't.
> - Non-string input returns `false` instead of throwing.
>
> The case list is in `.claude-skills-work/writing-tests/isValidPassword/cases.md`.