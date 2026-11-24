I'd write 6 behaviour tests for `checkout`, enumerated in a case list first. Writing them turns up one real risk: if the receipt email fails after the card is charged, `checkout` rejects even though the customer has already paid.

**Assumptions:** Jest, `checkout` exported from `src/checkout.js`, and `payments` / `email` imported from `./payments` and `./email`. These are the outside dependencies, so the tests replace them with `jest.mock`. Tests go next to the code as `src/checkout.test.js`.

## Steps

1. **TodoWrite:** contract → enumerate cases → write tests → run.
2. **Contract:**
   - Input: `cart` (`total`, `userEmail`) and `card`.
   - Output: resolves to `charge.id`.
   - Side effects: charges `cart.total` to `card`, then sends a receipt to `cart.userEmail` with the charge id. The receipt is only sent after a successful charge.
3. **Write `./.claude-skills-work/writing-tests/checkout/cases.md`:**

```markdown
# checkout cases
## Happy
- resolves to the charge id
- charges cart.total to the given card
- sends receipt to cart.userEmail with the charge id
## Boundary
- total 0 → passes through to payments unchanged (no validation in checkout; flag)
## Edge
- missing userEmail → not tested; checkout doesn't validate (flag to user)
## Errors
- payment declined → rejects with the payment error, NO receipt sent
- receipt send fails after charge → currently rejects; customer charged (flag: risk)
```

4. **Write `src/checkout.test.js`:**

```js
jest.mock('./payments');
jest.mock('./email');
const payments = require('./payments');
const email = require('./email');
const { checkout } = require('./checkout');

const cart = { total: 4999, userEmail: 'a@example.com' };
const card = { token: 'tok_visa' };

beforeEach(() => {
  jest.resetAllMocks();
  payments.charge.mockResolvedValue({ id: 'ch_123' });
  email.sendReceipt.mockResolvedValue();
});

test('resolves to the charge id', async () => {
  await expect(checkout(cart, card)).resolves.toBe('ch_123');
});

test('charges the cart total to the given card', async () => {
  await checkout(cart, card);
  expect(payments.charge).toHaveBeenCalledWith(card, 4999);
});

test('emails the receipt for the charge to the cart owner', async () => {
  await checkout(cart, card);
  expect(email.sendReceipt).toHaveBeenCalledWith('a@example.com', 'ch_123');
});

test('rejects with the payment error and sends no receipt when the charge is declined', async () => {
  payments.charge.mockRejectedValue(new Error('card_declined'));
  await expect(checkout(cart, card)).rejects.toThrow('card_declined');
  expect(email.sendReceipt).not.toHaveBeenCalled();
});

test('rejects when the receipt fails even though the card was charged (current behaviour)', async () => {
  email.sendReceipt.mockRejectedValue(new Error('smtp down'));
  await expect(checkout(cart, card)).rejects.toThrow('smtp down');
  expect(payments.charge).toHaveBeenCalled();
});

test('passes a zero total through to payments unchanged', async () => {
  await checkout({ ...cart, total: 0 }, card);
  expect(payments.charge).toHaveBeenCalledWith(card, 0);
});
```

5. **Run:** `npx jest src/checkout.test.js`. All tests should pass against the current code. To check that each test can fail, I'd briefly swap the order of the charge and the email, then return a wrong id, and confirm the matching tests go red.

## Final reply

> Added `src/checkout.test.js` with 6 tests: it returns the charge id, charges the right amount, sends the receipt, a declined card sends no receipt, a failed receipt email, and a zero total. The tests check the charge and email calls directly because those calls are what `checkout` does.
>
> **Decisions for you:**
> - **Receipt failure after charge:** right now `checkout` rejects even though the card was charged, so callers may show an error or retry and charge twice. Should it still resolve with the charge id and log or queue the receipt instead? I've marked that test "current behaviour" so it's easy to change.
> - **No input validation:** `checkout` doesn't check for a zero or negative total or a missing `userEmail`. I didn't add tests that assume rules it doesn't have. Tell me what those inputs should do and I'll add tests for them first.