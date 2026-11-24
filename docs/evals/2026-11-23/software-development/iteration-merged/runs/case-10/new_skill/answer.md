I'd add 14 behaviour tests in `src/isValidPassword.test.js`. Since this is a dry run, nothing was actually run and no results are shown.

**What I'm assuming:**
- `isValidPassword` already exists in `src/isValidPassword.js` and returns a boolean.
- The project is JavaScript and uses Vitest, which is what I'd expect to find in `package.json`.
- A "letter" means a–z or A–Z, and a "digit" means 0–9.
- Input that isn't a string, such as `null` or `undefined`, should return `false` and not throw.

I'd confirm the last two only if the tests show the function behaves differently.

**Steps, in order:**

1. **TodoWrite:** add three items: list the cases, write the tests, run them.
2. **Read** `package.json` and `src/isValidPassword.js` to confirm the framework, the export and how the file is laid out.
3. **List the cases** in `./.claude-skills-work/software-development/isValidPassword-tests/cases.md`:
   - **Happy path:** letters and digits, 8 or more characters.
   - **Length limits:** 7 characters (fails), exactly 8 (passes), 9 (passes).
   - **Missing a character type:** only letters, only digits, symbols but no letter, symbols but no digit.
   - **Other kinds of input:** the empty string, uppercase-only letters, and spaces or symbols mixed in.
   - **Invalid input:** `null` and `undefined`.
   - **Unicode:** `"pässwörd1"` passes because it has ASCII letters, but `"ääääääää1"` has no ASCII letter, so it fails under my assumption.
4. **Write `src/isValidPassword.test.js`:**
   ```js
   import { describe, it, expect } from 'vitest';
   import { isValidPassword } from './isValidPassword';

   describe('isValidPassword', () => {
     it('accepts 8+ chars with a letter and a digit', () => {
       expect(isValidPassword('abc12345')).toBe(true);
     });
     it('rejects 7 chars even with letter and digit', () => {
       expect(isValidPassword('abc1234')).toBe(false);
     });
     it('accepts exactly 8 chars', () => {
       expect(isValidPassword('abcdefg1')).toBe(true);
     });
     it('accepts 9 chars', () => {
       expect(isValidPassword('abcdefgh1')).toBe(true);
     });
     it('rejects letters only', () => {
       expect(isValidPassword('abcdefgh')).toBe(false);
     });
     it('rejects digits only', () => {
       expect(isValidPassword('12345678')).toBe(false);
     });
     it('rejects digit + symbols with no letter', () => {
       expect(isValidPassword('1!@#$%^&')).toBe(false);
     });
     it('rejects letter + symbols with no digit', () => {
       expect(isValidPassword('a!@#$%^&')).toBe(false);
     });
     it('accepts uppercase letters', () => {
       expect(isValidPassword('ABCDEFG1')).toBe(true);
     });
     it('accepts symbols and spaces alongside letter and digit', () => {
       expect(isValidPassword('a 1!b c#')).toBe(true);
     });
     it('rejects the empty string', () => {
       expect(isValidPassword('')).toBe(false);
     });
     it.each([null, undefined])('returns false for %s', (v) => {
       expect(isValidPassword(v)).toBe(false);
     });
     it('rejects non-ASCII letters as the only letters', () => {
       expect(isValidPassword('ääääääää1')).toBe(false);
     });
   });
   ```
   Each test checks one rule. The failing cases are exactly one character or one rule away from passing, so each one would catch a broken check.
5. **Check that the tests can fail:** temporarily change `>= 8` to `>= 7` in the function, run `npx vitest run src/isValidPassword.test.js`, and confirm the 7-character test fails. Then undo the change.
6. **Run it all:** run `npx vitest run`, then `npm run lint` and `npm run typecheck` if those scripts exist. Finally, call the real function once with `node -e "import('./src/isValidPassword.js').then(m=>console.log(m.isValidPassword('abc12345')))"`.
7. **Log** the case list and the run output to the notes folder.

**Final reply to the user:**

> I added `src/isValidPassword.test.js` with 14 tests (`it.each` counts as two). They cover:
> - the happy path
> - lengths of 7, 8 and 9 characters
> - a missing letter or a missing digit, including passwords that only add symbols
> - the empty string
> - `null` and `undefined`
> - uppercase letters
> - symbols and spaces mixed in
> - non-ASCII letters
>
> I checked that the length test fails when the limit is changed to 7, then ran the full suite, lint and typecheck and called the function directly. If any of these tests fail, it's because the function disagrees with one of my assumptions. I assumed "letter" means ASCII a–z or A–Z, and that `null` or `undefined` returns `false` and doesn't throw. Let me know if either should work differently.