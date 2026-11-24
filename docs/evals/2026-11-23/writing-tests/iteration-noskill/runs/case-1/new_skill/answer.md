I'd write a case list, then a Jest test file, then run it. Nothing is on disk, so I'm assuming:

- It's a JS/TS project using Jest.
- The function is `export function isValidPassword(pw)` in `src/password.js`.
- Tests go in `src/__tests__/`.
- It returns `false` for non-string input rather than throwing.
- "Letter" means ASCII a–z or A–Z.

The last two assumptions need confirming. The spec doesn't settle them, so those tests are marked below.

**1. TodoWrite items**
1. Contract
2. Enumerate cases into `cases.md`
3. Write the tests
4. Run them (they should fail first if the function isn't implemented yet)

**2. Contract:** a pure function, `pw` → boolean, with no side effects. It returns `true` only when length ≥ 8, there's at least one digit and there's at least one letter.

**3. Write `./.claude-skills-work/writing-tests/isValidPassword/cases.md`**
```markdown
# isValidPassword cases
## Happy
- letters+digits, length 10 → true
- mixed case + symbols + digit, length 12 → true
## Boundaries (length)
- 7 chars (letter+digit) → false
- 8 chars (letter+digit) → true
- 9 chars (letter+digit) → true
- empty string → false
## Partitions (missing class)
- 8+ letters only → false
- 8+ digits only → false
- 8+ symbols only → false
- exactly one digit, rest letters → true
- exactly one letter, rest digits → true
## Edges
- spaces count toward length ("abc 1234") → true  [ASSUMPTION]
- very long (1000 chars) → true
- non-ASCII letter as the only letter ("éééééé12"/"1234567é") → false  [ASSUMPTION: ASCII letters]
## Errors
- null / undefined / number / object / array → false, no throw  [ASSUMPTION]
```

**4. Write `src/__tests__/password.test.js`**
```js
import { isValidPassword } from '../password';

describe('isValidPassword', () => {
  test('accepts letters and digits of sufficient length', () => {
    expect(isValidPassword('abcde12345')).toBe(true);
  });
  test('accepts mixed case, symbols and a digit', () => {
    expect(isValidPassword('Pa$$w0rd!!xy')).toBe(true);
  });

  describe('length boundary', () => {
    test('rejects 7 characters', () => expect(isValidPassword('abcd123')).toBe(false));
    test('accepts exactly 8 characters', () => expect(isValidPassword('abcd1234')).toBe(true));
    test('accepts 9 characters', () => expect(isValidPassword('abcd12345')).toBe(true));
    test('rejects empty string', () => expect(isValidPassword('')).toBe(false));
  });

  describe('character classes', () => {
    test('rejects letters only', () => expect(isValidPassword('abcdefgh')).toBe(false));
    test('rejects digits only', () => expect(isValidPassword('12345678')).toBe(false));
    test('rejects symbols only', () => expect(isValidPassword('!@#$%^&*')).toBe(false));
    test('accepts a single digit among letters', () => expect(isValidPassword('abcdefg1')).toBe(true));
    test('accepts a single letter among digits', () => expect(isValidPassword('1234567a')).toBe(true));
  });

  describe('edges', () => {
    test('counts spaces toward length', () => expect(isValidPassword('abc 1234')).toBe(true));
    test('accepts very long passwords', () => expect(isValidPassword('a1'.repeat(500))).toBe(true));
    // ASSUMPTION: only ASCII letters count — confirm
    test('does not count a non-ASCII letter as the required letter', () =>
      expect(isValidPassword('1234567é')).toBe(false));
  });

  // ASSUMPTION: invalid input returns false rather than throwing — confirm
  describe.each([null, undefined, 12345678, {}, ['abcd1234']])('non-string input %p', (input) => {
    test('returns false without throwing', () => expect(isValidPassword(input)).toBe(false));
  });
});
```

**5. Run**
```
npx jest src/__tests__/password.test.js
```
If `isValidPassword` isn't implemented yet, the tests should fail on the missing behaviour and not on an import or syntax error. Then I'd confirm they pass once the function exists.

**Final reply to user:**
> I wrote 14 named tests in `src/__tests__/password.test.js`, plus one parameterised test that runs 5 non-string inputs. They cover:
> - **Valid passwords:** letters and digits; mixed case with symbols.
> - **Length:** 7 is rejected, 8 and 9 are accepted, and an empty string is rejected.
> - **Missing character types:** letters only, digits only and symbols only are all rejected; a single digit or a single letter is enough.
> - **Edge cases:** spaces count toward length, very long passwords pass, and non-ASCII letters were tested.
> - **Non-string input.**
>
> The case list is in `.claude-skills-work/writing-tests/isValidPassword/cases.md`.
>
> I've assumed two behaviours that you need to confirm:
> - Should `é` count as a letter?
> - Should non-string input return `false` or throw an error?
>
> I aimed to cover every behaviour, not to hit 100% line coverage.