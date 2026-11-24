**Steps I'd take**

1. TodoWrite: get diff/context · review each dimension · rate and locate · report.
2. Context: no file path was given, so I'd assume `src/cart.js` with `total` at lines 1–4 (line 2 = `sum`, line 3 = `return`). I'd also assume the existing callers use `total(items)` with one argument, since that was the old signature. I would grep for callers and tests before commenting. In this dry run I'm assuming those calls exist and that no tests cover `total`.
3. I'd write the checkpoint to `./.claude-skills-work/code-review/cart-discount/findings.md` as I review. It would contain the findings below, one line each: severity · `src/cart.js:<line>` · problem → fix.
4. Report:

---

## Code Review: cart discount (`src/cart.js`)

### 🔴 Must fix
1. **Existing callers now return `NaN`** (src/cart.js:1, :3): `discount` is a new required parameter. Any current `total(items)` call computes `sum - sum * undefined`, which is `NaN`. → Give it a default: `function total(items, discount = 0)`.
2. **`discount` is never checked** (src/cart.js:3):
   - A value above 1 gives a negative total.
   - A negative value raises the price.
   - If the value means "percent" (`10`) rather than a rate (`0.1`), the total becomes `-9 × sum`.

   → Decide the unit and document it, e.g. `discountRate` in [0, 1]. Then reject anything outside it: `if (!(discount >= 0 && discount <= 1)) throw new RangeError(\`discount must be in [0,1], got ${discount}\`)`. Clamping also works if business rules allow it.

### 🟡 Should fix
1. **Rounding on money** (src/cart.js:3): `sum * discount` can give fractions of a cent, e.g. `19.99 * 0.15`, and floating-point drift on top of that. → Round to cents (`Math.round(x * 100) / 100`) or work in integer cents. Follow whatever the project already does for money.
2. **No tests for the new behavior** (src/cart.js:1–4): the diff adds no tests. → Add cases for no discount (`total(items)` still returns the plain sum), a normal rate (0.1), 0, 1, an out-of-range value (rejected), an empty cart (0), and rounding.

### 🟢 Consider
1. **Clearer name** (src/cart.js:1): rename `discount` to `discountRate`, or `discountPercent` if that's the chosen unit, so the unit is in the name.
2. **Simpler expression** (src/cart.js:3): `return sum * (1 - discountRate);` says the same thing more directly.
3. **Quantity ignored (already true before this PR)** (src/cart.js:2): the sum uses `i.price` only. If items carry a `quantity`, the total is wrong. Check this is intended.

### ✅ Good
- The discount is applied once to the subtotal, not per item, which avoids per-line rounding drift.
- The change is small and focused, and naming the intermediate `sum` makes the calculation easy to read.