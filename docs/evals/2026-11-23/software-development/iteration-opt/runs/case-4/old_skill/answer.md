**Assumptions** (I can't see the project): it's TypeScript with Vitest. `calculateTotal(items: CartItem[])` is in `src/cart/calculateTotal.ts` and has tests in `src/cart/calculateTotal.test.ts`. It returns `subtotal * (1 + avgTaxRate)`, where `avgTaxRate = sum(taxRate) / items.length`. For an empty cart that's `0 / 0`, which is NaN. The function adds no fixed fees such as shipping, so an empty cart should total **0**. This isn't an orchestration run, so I'd spawn no subagents.

### What I'd do, in order

1. **TodoWrite:** one item per stage: Understand, Plan, TDD, Refactor, Verify.

2. **Stage 1, Understand.** `calculateTotal([])` must return `0`, not `NaN`. Totals for non-empty carts must not change. Nothing is ambiguous enough to stop and ask the user. The one open question is whether an empty cart includes fees, and per the assumptions above it doesn't.

3. **Read** `src/cart/calculateTotal.ts` and its existing tests to confirm where the NaN comes from. Assume it's the `/ items.length` line.

4. **Stage 2, Plan.** I'd write `./.claude-skills-work/software-development/fix-calculateTotal-empty-cart/plan.md`:
   ```
   # Fix: calculateTotal returns NaN for empty cart
   Root cause: avgTaxRate = sumTaxRates / items.length → 0/0 = NaN when items = [].
   Done: calculateTotal([]) === 0; existing non-empty totals unchanged.
   Slice: one file (src/cart/calculateTotal.ts) + its test file.
   Fix: guard empty cart at the top (return 0). Don't change how non-empty tax is computed (no behavior change).
   Tests (writing-tests): empty → 0 (boundary); one item (boundary, regression); multiple items (happy, already covered).
   ```
   I'd read `references/backend.md`. It's pure domain logic, so only its "boundary values (empty, zero)" point applies.

5. **writing-tests** case list goes to `./.claude-skills-work/writing-tests/calculateTotal/cases.md`:
   - Boundary: an empty cart returns 0. This is the new test.
   - Boundary: one item returns price × qty × (1 + rate). Add it if it's missing.
   - Happy path: a multi-item total is unchanged. The existing test covers this.

6. **Stage 3, Red.** Add to `calculateTotal.test.ts`:
   ```ts
   it('returns 0 for an empty cart', () => {
     expect(calculateTotal([])).toBe(0);
   });
   ```
   Run `npx vitest run src/cart/calculateTotal.test.ts`. It should fail with `expected NaN to be +0`, which is the right reason.

7. **Green.** Add the smallest fix at the top of `calculateTotal`:
   ```ts
   if (items.length === 0) return 0;
   ```
   Rerun the same test file and confirm every test passes.

8. **Stage 4, Refactor.** The guard is one line, with no new helpers or options, so there's nothing to change. I'd log that in `progress.md`.

9. **Stage 5, Verify.**
   - Run the whole suite with `npx vitest run`.
   - Call the real function with `npx tsx -e "import {calculateTotal} from './src/cart/calculateTotal'; console.log(calculateTotal([]), calculateTotal([{price:10,quantity:2,taxRate:0.1}]))"`. Expected output: `0 22`.
   - Record the commands and output in `progress.md`.

### Final reply to the user

> Fixed: `calculateTotal([])` now returns `0` instead of `NaN`.
>
> **Cause:** it divides the summed tax rates by `items.length` to get an average rate. With an empty cart that's `0 / 0`, which gives `NaN`.
>
> **Fix:** `src/cart/calculateTotal.ts` now returns `0` straight away when the cart is empty. Totals for carts with items are calculated the same way as before.
>
> **Tests:** I wrote the empty-cart test first and it failed with `expected NaN to be +0`. After the fix it passes, I added a single-item test, and the full suite passes. Calling the function directly gives `0` for an empty cart and `22` for one item at 10 × 2 with 10% tax.
>
> If an empty cart should include fees such as shipping, the total should be those fees rather than 0, so tell me if that applies.