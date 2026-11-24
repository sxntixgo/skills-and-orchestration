Your file doesn't match the Prettier config, but that's the smaller problem: `proc` throws on every call. Variable names aren't something Prettier controls, so I've covered them as readability below.

**What I'd do in the session:**
1. Create TodoWrite items for the steps in the skill.
2. Read `orders.js` and `.prettierrc` (`{ "tabWidth": 2, "semi": true, "singleQuote": true }`). Search for callers with `grep -rn "proc(" --include=*.js .`. **Assumption:** the callers pass an array of `{ cust, st, amt }` orders, `amt` is a number, and no tests exist for this function.
3. Write the report below to `./.claude-skills-work/code-review/orders.js/findings.md`.

**Formatting (your question):** The file uses 4-space indentation and `"paid"` in double quotes. Your config wants 2 spaces and single quotes. Semicolons are fine. Don't fix these by hand: run `npx prettier --write orders.js`, and add `prettier --check` to CI or a pre-commit hook so it can't drift again.

## Code Review: orders.js
### 🔴 Must fix
1. **Off-by-one crash** (orders.js:4): `i <= d.length` reads `d[d.length]`, which is `undefined`, so `.cust` throws a TypeError. This happens on every call, including with an empty array. → Use `i < d.length`, or replace the loop with `orders.filter(...).reduce(...)`.

### 🟡 Should fix
1. **Names don't say what they mean** (orders.js:2–3, 5–6):
   - `proc`, `d`, `x` and `tmp` hide the intent. Rename them to `totalPaidForCustomer(orders, customerId)` and `total`.
   - The fields `cust`, `st` and `amt` are abbreviated too. If they come from your data model, leave them, but use clear local names.
   - Renaming `proc` changes the export at line 12, so update the callers too.
2. **Loose equality** (orders.js:5): `==` matches `"42"` to `42`, so an ID of a different type silently counts as the same customer. → Use `===`, and make sure callers pass IDs of the same type.
3. **No tests**: → Add tests for:
   - one customer with mixed paid and unpaid orders
   - an empty array, which would have caught the 🔴 above
   - a customer with no orders, which should return `0`

### 🟢 Consider
1. **String amounts concatenate** (orders.js:6): if `amt` ever arrives as a string, say from JSON or a form, `tmp + amt` builds a string like `"010"` instead of adding. → Validate `amt` or convert it with `Number(...)`. If money accuracy matters, store amounts as integer cents.
2. **Status literal** (orders.js:5): → Pull `'paid'` into a shared constant if other modules check order status.

### ✅ Good
- Small, single-purpose function with no side effects.
- The comment at line 1 explains what it does, which makes up for the cryptic name.

No security findings: the function doesn't take outside input itself or touch auth, files, the network or secrets.