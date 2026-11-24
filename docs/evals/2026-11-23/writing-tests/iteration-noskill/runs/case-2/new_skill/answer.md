Here's the plan for the checkout tests. It covers 7 behaviours, mocks only `payments` and `email`, and changes no production code. I'm assuming Jest, `src/checkout.js` importing `./payments` and `./email`, and colocated `*.test.js` files. I'd check `package.json` and the existing tests first and adapt to what's actually there.

**1. TodoWrite:** contract → enumerate cases → write tests → run.

**2. Write `./.claude-skills-work/writing-tests/checkout/cases.md`:**
```md
# checkout(cart, card) — cases
Contract: charges card for cart.total; emails receipt (cart.userEmail, charge.id); resolves charge.id.
Side effects that ARE the behaviour: the charge, the receipt email.

Happy
- resolves to the charge id
- charges the given card for exactly cart.total
- sends receipt to cart.userEmail with that charge id
Boundary
- total 0: passes 0 through as-is (no validation in checkout; payments owns it)
Edge
- missing cart.userEmail: charge still happens, email called with undefined (pins current behaviour; flag)
Error
- payments.charge rejects → checkout rejects with same error, NO receipt sent
- email.sendReceipt rejects → checkout rejects, but card WAS charged (risk: customer charged, caller sees failure)
```

**3. Write `src/checkout.test.js`:**
```js
jest.mock('./payments');
jest.mock('./email');
const payments = require('./payments');
const email = require('./email');
const { checkout } = require('./checkout');

const cart = { total: 4999, userEmail: 'ana@example.com' };
const card = { token: 'tok_visa' };

beforeEach(() => {
  jest.resetAllMocks();
  payments.charge.mockResolvedValue({ id: 'ch_123' });
  email.sendReceipt.mockResolvedValue();
});

test('resolves to the charge id', async () => {
  await expect(checkout(cart, card)).resolves.toBe('ch_123');
});

test('charges the card for the cart total', async () => {
  await checkout(cart, card);
  expect(payments.charge).toHaveBeenCalledWith(card, 4999);
});

test('sends the receipt to the user with the charge id', async () => {
  await checkout(cart, card);
  expect(email.sendReceipt).toHaveBeenCalledWith('ana@example.com', 'ch_123');
});

test('passes a zero total through to payments unchanged', async () => {
  await checkout({ ...cart, total: 0 }, card);
  expect(payments.charge).toHaveBeenCalledWith(card, 0);
});

test('rejects with the payment error and sends no receipt when the charge fails', async () => {
  payments.charge.mockRejectedValue(new Error('card_declined'));
  await expect(checkout(cart, card)).rejects.toThrow('card_declined');
  expect(email.sendReceipt).not.toHaveBeenCalled();
});

test('rejects when the receipt email fails even though the card was charged', async () => {
  email.sendReceipt.mockRejectedValue(new Error('smtp_down'));
  await expect(checkout(cart, card)).rejects.toThrow('smtp_down');
  expect(payments.charge).toHaveBeenCalledTimes(1);
});

test('still charges when the cart has no user email', async () => {
  await expect(checkout({ total: 10 }, card)).resolves.toBe('ch_123');
  expect(email.sendReceipt).toHaveBeenCalledWith(undefined, 'ch_123');
});
```
These tests assert on the mocks for a reason: here the interaction is the behaviour. The money moves, the email goes out, and the receipt is skipped when the charge fails.

**4. Run:** `npx jest src/checkout.test.js`. These tests describe what the code does today, so all 7 should pass. To check each test can fail, I'd briefly break the code (swap the order of the charge and the email, or return `cart.total`) and confirm the matching test goes red, then undo the change.

**Final message:**

> I added 7 tests for `checkout` in `src/checkout.test.js`, covering the success path, a zero total, a missing email, and the charge and email each failing. They pass against the current code; the case list is in `.claude-skills-work/writing-tests/checkout/cases.md`.
>
> **Two things you need to decide:**
> - **Charged but checkout fails:** if `sendReceipt` fails, the card has already been charged but `checkout` still fails, so callers may retry and charge twice. The test records this behaviour; it doesn't endorse it. Should a failed email be logged or queued instead of failing checkout?
> - **No input checks:** `checkout` doesn't validate anything. A missing `userEmail` still charges the card, and a total of 0 or less goes straight to payments. If you add validation, those tests should change to expect a rejection with no charge made.
>
> I didn't change `checkout` itself; fixing either issue is a code change, not a test change.