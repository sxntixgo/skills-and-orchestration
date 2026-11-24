**Actions taken**
1. TodoWrite items: context, check dimensions, rate/order, report.
2. Context: the diff has no file path, so I'm calling it `cart.js` with `total` at lines 1–4. I couldn't see any callers, so I'm assuming existing call sites still call `total(items)` with no second argument. I'm also assuming money is stored as float prices, not integer cents.
3. Wrote findings to `./.claude-skills-work/code-review/cart-total/findings.md`, with the same content as the report below.

## Code Review: cart.js `total(items, discount)`

### 🔴 Must fix
1. **`discount` is never validated, so totals can be silently wrong** (cart.js:3): if `discount > 1` (e.g. `1.5`, or `10` meaning "10%"), the total goes negative. If it's negative, the total goes up. → Reject values outside `[0, 1]` (throw a `RangeError` that includes the value), or clamp them, whichever matches the cart's policy.
2. **Calls without a discount now return `NaN`** (cart.js:1, 3): `sum * undefined` is `NaN`, so every existing `total(items)` call now gets `NaN` instead of the sum. → Add a default, `function total(items, discount = 0)`, or update every caller.

### 🟡 Should fix
1. **The unit isn't clear: fraction or percent?** (cart.js:1): `discount` could mean `0.1` or `10`. Getting this wrong is what triggers 🔴1. → Rename it to `discountRate` (a fraction from 0 to 1), or add a JSDoc line that states the unit.
2. **Results can have fractional cents** (cart.js:3): `sum * discount` on float prices gives values like `17.991`. → Round to cents (`Math.round(x * 100) / 100`), or store prices in integer cents, whichever the codebase already does.
3. **No tests for the new behaviour** (cart.js:3): → Add tests for no discount (`total(items)` returns the plain sum), a normal case (`0.1`), the edges (`0` and `1`), an empty cart, and an invalid discount (`1.5` and `-0.1` rejected).

### 🟢 Consider
1. **Simpler expression** (cart.js:3): `return sum * (1 - discount);` reads as "pay the remaining share".

### ✅ Good
- The change is small and focused, and the existing `reduce` is left as it was.
- Naming the subtotal `sum` makes the discount step easy to read.