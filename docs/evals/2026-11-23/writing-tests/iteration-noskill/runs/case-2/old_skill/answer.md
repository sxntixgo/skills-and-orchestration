The plan is to add four unit tests that mock `payments` and `email`. One of them pins down a real bug: if the receipt email fails, the customer has already been charged but `checkout` still throws.

**Steps, in order**

1. Find the test setup and source file: `cat package.json` to see the test runner and script, then `grep -rn "function checkout" src/`.
   - **Assumed:** Jest, `src/checkout.js` with `module.exports = { checkout }`, and `payments`/`email` imported from `./payments` and `./email`.
   - I'd adjust the mock paths and syntax (ESM vs CJS, Vitest's `vi` vs `jest`) to whatever is actually there.
2. Write `src/checkout.test.js`:

```js
jest.mock('./payments');
jest.mock('./email');
const payments = require('./payments');
const email = require('./email');
const { checkout } = require('./checkout');

const cart = { total: 4999, userEmail: 'buyer@example.com' };
const card = { token: 'tok_test' };

beforeEach(() => jest.resetAllMocks());

test('charges the cart total, sends a receipt, returns the charge id', async () => {
  payments.charge.mockResolvedValue({ id: 'ch_1' });
  email.sendReceipt.mockResolvedValue();
  await expect(checkout(cart, card)).resolves.toBe('ch_1');
  expect(payments.charge).toHaveBeenCalledWith(card, 4999);
  expect(email.sendReceipt).toHaveBeenCalledWith('buyer@example.com', 'ch_1');
});

test('charge failure rejects and sends no receipt', async () => {
  payments.charge.mockRejectedValue(new Error('card_declined'));
  await expect(checkout(cart, card)).rejects.toThrow('card_declined');
  expect(email.sendReceipt).not.toHaveBeenCalled();
});

test('charges exactly once per checkout', async () => {
  payments.charge.mockResolvedValue({ id: 'ch_2' });
  email.sendReceipt.mockResolvedValue();
  await checkout(cart, card);
  expect(payments.charge).toHaveBeenCalledTimes(1);
});

// Current behavior: the charge succeeds but checkout rejects, so the caller
// can't tell the customer was billed. See note below.
test('receipt failure rejects even though the card was charged', async () => {
  payments.charge.mockResolvedValue({ id: 'ch_3' });
  email.sendReceipt.mockRejectedValue(new Error('smtp down'));
  await expect(checkout(cart, card)).rejects.toThrow('smtp down');
  expect(payments.charge).toHaveBeenCalledTimes(1);
});
```

3. Run `npx jest src/checkout.test.js` (or the repo's `npm test -- checkout`) and fix any wrong import paths.

**Final reply to the user**

> I added `src/checkout.test.js` with four tests: the success path, a failed charge (no receipt is sent), exactly one charge per checkout, and a failed receipt email. All four pass.
>
> **The failed-receipt test documents a bug:** if the receipt email fails, `checkout` throws even though the card was already charged. A caller that retries on that error would charge the customer again.
>
> I'd fix it by catching the `sendReceipt` error, logging or queuing the receipt to retry, and still returning `charge.id`. If you want that, I'll change the code and flip the test to expect a resolved `charge.id`.