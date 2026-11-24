The fix: a test that reproduces the NaN, the smallest change that makes an empty cart return `0`, then tests for one item and null/undefined. Nothing below has been run. It's the exact sequence I'd follow in the session.

**Assumptions** (I can't see the project):
- It's a JS/TS repo using Vitest, run with `npm test`.
- `calculateTotal(items)` is in `src/cart.ts` and has a test file at `src/cart.test.ts`.
- Its body is roughly:
  ```ts
  const subtotal = items.reduce((s, i) => s + i.price * i.quantity, 0);
  const bulkDiscount = subtotal * discountRate(subtotal / items.length);
  return round2(subtotal - bulkDiscount);
  ```
  With an empty cart, `0 / 0` gives `NaN`. I'd confirm the real cause by reading the function before writing the fix.
- "Done" means `calculateTotal([])` returns `0`, carts with items give the same totals as before, and `null`/`undefined` also return `0`.

**1. Task list (TodoWrite).** One item per stage: Understand, Plan, TDD red/green, DRY/YAGNI/KISS, Run it. Notes go in `./.claude-skills-work/software-development/calculate-total-nan/notes.md`. Each note is one line: the assumption above, then the root cause once confirmed.

**2. Understand and plan.** Read `src/cart.ts` and `src/cart.test.ts`. The change touches only `calculateTotal` and its test file. I'd stick to the patterns already in the file.

**3. Red: reproduce the bug first.** Add to `src/cart.test.ts`:
```ts
describe('calculateTotal', () => {
  it('returns 0 for an empty cart', () => {
    expect(calculateTotal([])).toBe(0);
  });
});
```
Run `npx vitest run src/cart.test.ts`. It should fail with `expected NaN to be +0`. If it fails for a different reason, the cause I assumed is wrong and I'd look again.

**4. Green: minimal fix.** Guard the division where the NaN starts, not the final result:
```ts
if (items.length === 0) return 0;
```
I'd put this at the top of `calculateTotal`. Rerun and the test passes.

**5. Neighbour tests.** Each one is red first if it fails:
```ts
it('totals a single item', () => {
  expect(calculateTotal([{ price: 9.99, quantity: 2 }])).toBe(19.98);
});
it('returns 0 for null/undefined cart', () => {
  expect(calculateTotal(null as any)).toBe(0);
  expect(calculateTotal(undefined as any)).toBe(0);
});
it('totals a zero-quantity item as 0', () => {
  expect(calculateTotal([{ price: 5, quantity: 0 }])).toBe(0);
});
```
- If the `null` test fails, I'd change the guard to `if (!items?.length) return 0;`.
- I'd only do that if callers can actually pass `null`. I'd check with `grep -rn "calculateTotal(" src`. If no caller does, I'd drop that test rather than defend a case that can't happen (YAGNI).

**6. DRY / YAGNI / KISS.** Keep a single guard and avoid scattering `|| 0` / `isNaN` checks through the function. There's no refactor beyond that.

**7. Run it.**
- `npm test`: the full suite, to make sure no existing totals changed.
- The function directly: `npx tsx -e "import {calculateTotal} from './src/cart'; console.log(calculateTotal([]), calculateTotal([{price:9.99,quantity:2}]))"`. Expected output: `0 19.98`.

**Final reply to the user:**
> Fixed: `calculateTotal([])` now returns `0`. The cause was `subtotal / items.length` (0/0 → NaN) in the bulk-discount step. I added an early `return 0` for empty carts in `src/cart.ts`. I added tests for an empty cart (it failed before the fix), a single item, a zero-quantity item, and null/undefined input. The full `npm test` suite passes, and running the function directly prints `0` for an empty cart and `19.98` for one item.