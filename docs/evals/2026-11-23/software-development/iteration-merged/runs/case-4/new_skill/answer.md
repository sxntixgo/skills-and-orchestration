Not an orchestration run, so I'd do this myself (no subagents) using the skill's bugfix flow: a failing test first, then the smallest fix, then tests for the nearby cases.

**Assumptions** (I can't see the repo): it's a TypeScript project using Vitest. `calculateTotal(items: CartItem[] | null | undefined)` is in `src/cart.ts`, with tests in `src/cart.test.ts`. The NaN comes from a per-item average, `discountTotal / items.length`, which is `0 / 0` when the cart is empty. If the real cause turns out different, the steps stay the same and only the one-line fix changes.

### Steps

1. **TodoWrite:** Understand → Plan slice → Red (reproduce) → Green (fix) → Neighbour tests → Refactor → Run it. I'd keep notes in `./.claude-skills-work/software-development/calculate-total-empty-cart/notes.md`.

2. **Understand:** `calculateTotal([])` should return `0`, not `NaN`. Done means an empty cart totals 0 and non-empty totals don't change. I'd also treat `null` and `undefined` as an empty cart, since a missing cart has nothing in it. That's a small detail, so I'd note it and keep going rather than stop to ask.

3. **Plan the slice:** change only `src/cart.ts` and `src/cart.test.ts`. No new helpers or options.

4. **Red:** add this test to `src/cart.test.ts`:
   ```ts
   it('returns 0 for an empty cart', () => {
     expect(calculateTotal([])).toBe(0);
   });
   ```
   Run `npx vitest run src/cart.test.ts`. I'd expect it to fail with `expected NaN to be +0`. That confirms the test reproduces the bug for the right reason.

5. **Green:** make the smallest fix in `src/cart.ts`:
   ```ts
   export function calculateTotal(items: CartItem[] | null | undefined = []): number {
     if (!items?.length) return 0;
     // ...existing logic unchanged
   }
   ```
   Rerun and confirm the test passes.

6. **Neighbour tests**, one behaviour each, written before checking they pass:
   - `returns the item total for a single-item cart`: `[{ price: 10, quantity: 2 }]` gives `20`.
   - `returns 0 when the cart is null` and `returns 0 when the cart is undefined`.
   - `applies the discount for a multi-item cart`: locks in the existing non-empty behaviour.
   - `returns 0 for a cart with zero-quantity items`: this hits the same `0 / 0` risk through a different path. If it fails, I'd change the guard to check the divisor (`count === 0`) instead of `items.length`, and rerun.

7. **Refactor:** I'd make sure there's only one guard and no extra branches, then rerun.

8. **Run it:**
   - `npm test` (full suite)
   - `npm run lint`
   - `npx tsc --noEmit`
   - The real behaviour: `npx tsx -e "import {calculateTotal} from './src/cart'; console.log(calculateTotal([]), calculateTotal([{price:10,quantity:2}]))"`, expecting `0 20`.

9. No `git commit`, since you didn't ask for one.

### Final reply to you

I fixed it. `calculateTotal` now returns `0` for an empty cart. The NaN came from the discount average dividing `0 / 0` in `src/cart.ts`; an early return now handles empty, `null` and `undefined` carts.

- **Files changed:** `src/cart.ts` (the guard) and `src/cart.test.ts` (5 tests).
- **Test-first:** the empty-cart test failed with `NaN` before the fix and passes after.
- **New tests:** single item, null, undefined, zero-quantity items, and multi-item with discount.
- **Checks:** the full test suite, lint and `tsc` all pass. Running it directly prints `0 20`.
- **Not committed:** the change isn't committed. I can commit it if you want.