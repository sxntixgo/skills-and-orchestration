Don't merge yet: callers that still use `total(items)` will now get `NaN`. There are a few smaller issues too.

**Blocking**
1. **Existing callers break.** If `discount` isn't passed it's `undefined`, so `sum * undefined` is `NaN` and the whole total becomes `NaN`. Fix with a default: `function total(items, discount = 0)`.
2. **Bad discount values aren't rejected.** A negative discount raises the price. A discount above 1 gives a negative total. Passing `"10"` or `10` when 10% was meant drives the total far below zero. Check the value and throw if it's outside 0–1:
   ```js
   if (typeof discount !== 'number' || !Number.isFinite(discount) || discount < 0 || discount > 1) {
     throw new RangeError(`discount must be a fraction in [0, 1], got ${discount}`);
   }
   ```

**Should fix**
3. **It's not clear what `discount` means.** It works as a fraction (0.1 means 10% off). Callers could reasonably pass a percentage (10) or a fixed amount (5 off). Rename it to `discountRate` or add a JSDoc comment.
4. **Floating-point rounding.** `sum - sum * discount` can return values like `89.99999999999999`. Round to cents, e.g. `Math.round(sum * (1 - discount) * 100) / 100`, or work in integer cents throughout.

**Worth checking (not introduced by this PR)**
- The sum ignores quantity (`i.price` instead of `i.price * i.qty`). That's only correct if each line item is a single unit.

**Tests to add:** no discount argument (should equal the old behavior), 0, 1, a normal value like 0.15 with the rounding checked, an empty cart, and the invalid inputs (−0.1, 1.5, `"10"`, `NaN`).

Suggested version:
```js
/** @param {number} discountRate fraction in [0, 1], e.g. 0.1 = 10% off */
function total(items, discountRate = 0) {
  if (typeof discountRate !== 'number' || !Number.isFinite(discountRate) || discountRate < 0 || discountRate > 1) {
    throw new RangeError(`discountRate must be in [0, 1], got ${discountRate}`);
  }
  const sum = items.reduce((s, i) => s + i.price, 0);
  return Math.round(sum * (1 - discountRate) * 100) / 100;
}
```