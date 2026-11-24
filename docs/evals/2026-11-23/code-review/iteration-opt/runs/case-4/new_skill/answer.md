**Planned actions (dry run):**

1. TodoWrite: Context → Check dimensions → Rate/order → Report.
2. Read `orders.js` and `.prettierrc`. I'd also grep for callers of `proc` and for tests (`rg "proc\(" --glob '*.js'`). Since I can't see the project, I'm assuming one caller passes an array of `{cust, st, amt}` objects and that no test covers `proc`.
3. Write the report below to `./.claude-skills-work/code-review/orders.js/findings.md`.

---

**Short answer:** Prettier only controls formatting, not variable names. Your indentation and quotes don't match the config, but the fix is to run `npx prettier --write orders.js` rather than edit by hand. Your names do have problems, but they're readability issues. More importantly, the loop has an off-by-one bug that crashes the function on every call with a non-empty array.

## Code Review: orders.js
### 🔴 Must fix
1. **Off-by-one crashes every call** (orders.js:4): `i <= d.length` reads `d[d.length]`, which is `undefined`, so `undefined.cust` throws a TypeError. It also throws on an empty array, at `i = 0`. → Use `i < d.length`, or `for (const order of orders)`.

### 🟡 Should fix
1. **Loose equality** (orders.js:5): `==` makes `cust` id `1` match `"1"`. → Use `===`.
2. **Names don't say what they hold** (orders.js:2–3, 5–6): `proc`, `d`, `x` and `tmp` give no meaning, and `cust`, `st` and `amt` are abbreviations. → e.g. `function totalPaidForCustomer(orders, customerId)` with `let total = 0;`. Rename the export and update its callers too. (The property names come from your data shape, so leave them unless you own that schema.)
3. **No tests** (orders.js:2): assuming none exist. → Add tests for an empty array, a mix of paid and unpaid orders for the target customer, and a customer with no orders.

### 🟢 Consider
1. **Formatting differs from `.prettierrc`** (orders.js:3–8, 5): there are 4-space indents where the config has `tabWidth: 2`, and `"paid"` uses double quotes where the config has `singleQuote: true`. → Run `npx prettier --write orders.js`, and add Prettier to a pre-commit hook or CI check so this doesn't come up in review again.
2. **Simpler expression** (orders.js:3–9): → `orders.filter(o => o.cust === customerId && o.st === 'paid').reduce((sum, o) => sum + o.amt, 0)`.

### ✅ Good
- The comment on line 1 states the function's purpose clearly.
- The function is small and pure, with no side effects and one job, so it's easy to test.