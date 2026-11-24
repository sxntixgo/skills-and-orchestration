I'd write the case list, then a Jest test file covering the happy path, boundaries, edge cases and errors, then run it.

**Assumptions** (I can't see the project):
- It's a JS project using Jest, with the function at `src/isValidPassword.js`.
- Tests go in `src/__tests__/`.
- Bad input (non-string, `null` or `undefined`) returns `false` rather than throwing.
- "Letter" means a–z or A–Z.

**1. TodoWrite:** add four items: contract, enumerate cases, write tests, run.

**2. Write `./.claude-skills-work/writing-tests/isValidPassword/cases.md`:**
```markdown
# isValidPassword(pw) → boolean
Contract: true iff length ≥ 8 AND ≥1 digit AND ≥1 letter. Pure, no side effects.

## Happy
- letters+digits, len 8+ → true ("abcdefg1", "Passw0rdLonger")
- mixed case / symbols allowed → true ("P@ss w0rd!")
## Boundaries (length)
- len 7 with letter+digit → false ("abcdef1")
- len 8 → true ("abcdefg1")
- len 9 → true ("abcdefgh1")
- empty "" → false
## Rule partitions (len ≥ 8)
- letters only → false ("abcdefgh")
- digits only → false ("12345678")
- symbols only → false ("!@#$%^&*")
- exactly one digit / one letter → true ("1aaaaaaa", "a1111111")
- digit/letter position irrelevant (start/middle/end) → true
## Edges
- whitespace padding counts toward length? → "  abc1  " (8 chars) → true (assumed: no trim)
- unicode letter "ééééééé1" → false under ASCII-letter assumption (flag to user)
- unicode digit "abcdefg١" (Arabic-Indic) → false (assumed ASCII digit)
## Errors
- null, undefined, 12345678 (number), [] , {} → false, does not throw
```

**3. Write `src/__tests__/isValidPassword.test.js`:**
```js
const { isValidPassword } = require('../isValidPassword');

describe('isValidPassword', () => {
  describe('valid passwords', () => {
    test.each([
      ['abcdefg1', 'exactly 8 chars with letter and digit'],
      ['abcdefgh1', '9 chars'],
      ['P@ss w0rd!', 'symbols and spaces allowed'],
      ['1aaaaaaa', 'single digit at start'],
      ['a1111111', 'single letter at start'],
      ['aaa1aaaa', 'digit in middle'],
    ])('returns true for %p (%s)', (pw) => {
      expect(isValidPassword(pw)).toBe(true);
    });
  });

  describe('invalid passwords', () => {
    test.each([
      ['abcdef1', '7 chars, one below the minimum'],
      ['', 'empty string'],
      ['abcdefgh', 'no digit'],
      ['12345678', 'no letter'],
      ['!@#$%^&*', 'neither letter nor digit'],
    ])('returns false for %p (%s)', (pw) => {
      expect(isValidPassword(pw)).toBe(false);
    });
  });

  describe('non-string input', () => {
    test.each([null, undefined, 12345678, [], {}])(
      'returns false without throwing for %p',
      (input) => {
        expect(isValidPassword(input)).toBe(false);
      }
    );
  });
});
```
I'm leaving the unicode cases out of the file until their behaviour is decided (see below).

**4. Run:** `npx jest src/__tests__/isValidPassword.test.js`. If the function doesn't exist yet (TDD), every test should fail because `isValidPassword` is missing, which is the expected failure. Once it's implemented, all of them should pass.

---

**Reply to user:**

I've written the case list and the test file `src/__tests__/isValidPassword.test.js` (Jest). They cover valid passwords, the length limits at 7, 8 and 9 characters plus the empty string, passwords missing a digit or a letter, and non-string input. I haven't aimed for 100% coverage; the goal is to cover each behaviour and risk.

Your rule doesn't settle these, so please confirm:
- **Bad input:** I assumed `null`, `undefined` and numbers return `false` rather than throwing.
- **Letters and digits:** I assumed only a–z, A–Z and 0–9 count. Should `é` count as a letter, or `١` (an Arabic-Indic digit) as a digit? I've left those tests out until you decide.
- **Whitespace:** I assumed spaces count toward the length and aren't trimmed.