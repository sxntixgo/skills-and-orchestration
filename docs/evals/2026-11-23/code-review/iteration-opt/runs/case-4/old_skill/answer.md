**Short answer:** No, the indentation doesn't match. `.prettierrc` sets `tabWidth: 2` and the file uses 4 spaces. The `"paid"` string also breaks `singleQuote: true`. Run `npx prettier --write orders.js` to fix both. Prettier doesn't check variable names at all, so I reviewed those as a naming issue. The bigger problem is that `orders.js:4` crashes on every call.

**What I'd do in the session:**
1. Add TodoWrite items: read context, check each dimension, rate, report.
2. Read `orders.js` and `.prettierrc`. I'm assuming there are no callers or tests to check, since none were provided.
3. Write the findings below to `./.claude-skills-work/code-review/orders.js/findings.md` as I go.
4. Reply:

## Code Review: orders.js

### 🔴 Must fix
1. **Loop reads past the end of the array** (orders.js:4): `i <= d.length` makes the last pass read `d[d.length]`, which is `undefined`. Then `.cust` throws a TypeError, so the function never returns a total. → Use `i < d.length`, or `for (const order of orders)`.

### 🟡 Should fix
1. **Names don't say what they hold** (orders.js:2–6): `proc`, `d`, `x`, `tmp`, `cust`, `st` and `amt` all need the comment on line 1 to make sense. → Rename to `totalPaidForCustomer(orders, customerId)` and `total`. If you control the data shape, use `customer`/`status`/`amount` for the fields too. Update the export and any callers.
2. **Loose equality** (orders.js:5): `==` lets `"42"` match `42`, so the wrong customer could be counted. → Use `===`.
3. **Bad input isn't handled** (orders.js:2,6): if `d` is null it throws an unclear error. If `amt` is missing, the total becomes `NaN`, or a string if `amt` is a string. → Check the input at the top, and decide whether a missing amount should be skipped or throw.
4. **No tests**: nothing covers an empty array, no matching orders, or unpaid orders. The test for the 🔴 bug above would have caught it. → Add tests for those three cases plus a normal case.

### 🟢 Consider
1. **Clearer with `filter` and `reduce`** (orders.js:3–9): `orders.filter(o => o.customer === customerId && o.status === 'paid').reduce((sum, o) => sum + o.amount, 0)`
2. **Floating-point money** (orders.js:6): adding decimal amounts can produce rounding errors. Store amounts in integer cents if precision matters.

### ✅ Good
- It's a small function with one job and a comment explaining its purpose.
- It uses `let` and has a clean CommonJS export.

On formatting: run Prettier rather than fixing it by hand. Adding `prettier --check` to CI or a pre-commit hook would keep this from coming up in review again.