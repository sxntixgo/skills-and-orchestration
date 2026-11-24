I read `case-files/4/orders.js` and `case-files/4/.prettierrc` and ran nothing. Neither file matches the config, and there's also a bug that will crash the function.

**Prettier issues** (`{ "tabWidth": 2, "semi": true, "singleQuote": true }`)
- **Indentation:** the file uses 4 spaces but the config says 2.
- **Quotes:** `"paid"` on `orders.js:5` should be `'paid'`.
- **Semicolons:** these are fine.

Running `npx prettier --write orders.js` fixes both issues.

**Variable names:** Prettier doesn't check names at all; that would be ESLint's job (for example, its `id-length` rule). The current names are still hard to read. I suggest:
- `proc` → `getPaidTotalForCustomer`
- `d` → `orders`, `x` → `customerId`
- `tmp` → `total`
- `cust` / `st` / `amt` are data fields, so leave them unless you control the data shape.

**Bug (`orders.js:4`):** `i <= d.length` runs one step past the end of the array. On that last step `d[i]` is `undefined`, so `d[i].cust` throws a `TypeError` on every call. Use `i < d.length`.

**Smaller point:** `==` should be `===` so values aren't converted before comparing (for example, `'1' == 1` is true).

With all of these applied:

```js
// Returns the total of paid orders for a customer.
function getPaidTotalForCustomer(orders, customerId) {
  let total = 0;
  for (const order of orders) {
    if (order.cust === customerId && order.st === 'paid') {
      total += order.amt;
    }
  }
  return total;
}

module.exports = { getPaidTotalForCustomer };
```

If you rename the export, every file that imports `proc` needs updating too.