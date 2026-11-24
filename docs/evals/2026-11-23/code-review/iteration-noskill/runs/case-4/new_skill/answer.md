## What I'd do

1. **TodoWrite:** Context → Check dimensions → Rate/order → Report.
2. **Context:** read `orders.js` (the version in `case-files/4/`). I'd look for callers of `proc` with `grep -rn "proc(" --include=*.js .` and for the Prettier config (`.prettierrc*`, `prettier.config.*`, the `"prettier"` key in `package.json`). **Assumption:** no Prettier config was given and none can be seen, so I treat it as not found.
3. **Write findings** to `./.claude-skills-work/code-review/orders.js/findings.md`. Its content is the report below.

## Reply to the user

There's a crash bug that matters more than formatting: the loop runs one step past the end of the array (`orders.js:4`), so `proc` throws on every call. On your two questions:

- **Prettier doesn't check variable names.** It only handles layout: indentation, quotes, semicolons and line wrapping. Naming is a code-review question (or an ESLint rule such as `id-length`), so I've reviewed the names below.
- **I couldn't check indentation against your config because I didn't find one.** The file uses 4 spaces and double quotes, while Prettier's defaults are 2 spaces and double quotes. Don't eyeball it: run `npx prettier --check orders.js`, or `--write` to fix it, and Prettier will apply your real config. Send me the `.prettierrc` if you want me to confirm the settings.

## Code Review: orders.js

### 🔴 Must fix
1. **Off-by-one crashes on every call** (orders.js:4): `i <= d.length` reads `d[d.length]`, which is `undefined`, so `d[i].cust` throws a `TypeError`. → Use `i < d.length`, or `for (const order of orders)`.

### 🟡 Should fix
2. **Loose equality can match the wrong customer** (orders.js:5): `d[i].cust == x` counts `"42"` as equal to `42`. → Use `===` for both comparisons, and pass in the same id type the data uses.
3. **Non-numeric `amt` gives a silently wrong total** (orders.js:6): if `amt` is a string, `+` concatenates (`0 + "10"` becomes `"010"`). → Check the amount with `Number.isFinite(order.amt)`, or use `Number(order.amt)`. If amounts are money, store them as integer cents to avoid float drift.
4. **Names don't say what they mean** (orders.js:2–6): `proc`, `d`, `x`, `tmp`, `st` and `amt` hide the intent. → Rename to `totalPaidForCustomer(orders, customerId)` with `total` inside. If you can, rename the data fields to `customer`, `status` and `amount`. Changing `proc` also means updating the export at line 12 and its callers.

### 🟢 Consider
5. **Simpler as a filter and reduce** (orders.js:3–9): `orders.filter(o => o.customerId === customerId && o.status === "paid").reduce((sum, o) => sum + o.amount, 0)`.
6. **Empty or missing input** (orders.js:2): an empty array correctly returns 0, but `undefined` throws. → Default the parameter (`orders = []`), or document that it's required.
7. **Tests:** I found none. → Add tests for the normal case, an empty array, a customer with no paid orders, and a string id against a numeric id.

### ✅ Good
- The header comment (orders.js:1) states the function's purpose clearly.
- It's a small pure function with no side effects, so it's easy to test once fixed.