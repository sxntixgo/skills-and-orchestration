I'd add five behaviour tests and leave `checkout` unchanged. One gap needs your decision: if the receipt email fails after the card is charged, `checkout` rejects even though the customer has already paid.

**Assumptions** (nothing in the message says otherwise):
- `checkout` is exported from `src/checkout.js`.
- `payments` and `email` are imported from `./payments` and `./email`.
- The project uses Vitest with a `npm test` script. With Jest, `vi.*` becomes `jest.*`.

## What I'd do, in order

1. **TodoWrite:** Understand → List cases → Write tests → Prove they can fail → Run all checks. Notes go in `./.claude-skills-work/software-development/checkout-tests/notes.md`.

2. **Understand.** Given a cart and card, `checkout` charges `cart.total` to the card, emails a receipt with the charge id to `cart.userEmail`, and returns the charge id. `payments` and `email` are network calls, so they get faked at the module seam. Asserting calls on these mocks is fine here because the charge and the email are the behaviour being tested.

3. **List the cases first:**
   1. Returns the charge id when payment and email succeed.
   2. Charges the given card for exactly `cart.total`.
   3. Sends the receipt to `cart.userEmail` with the new charge id.
   4. Payment declined: rejects with the payment error and sends no receipt.
   5. Email fails after a successful charge: rejects with the email error. This records the current behaviour, which is risky because the customer is charged but the caller sees a failure.

   I'm not adding tests for a zero total, a missing `userEmail` or a missing card. `checkout` has no rules for those inputs, so any test would have to make up behaviour. That's a requirements question, not a testing one.

4. **Write `src/checkout.test.js`:**
   ```js
   import { describe, it, expect, vi, beforeEach } from 'vitest';
   import { checkout } from './checkout';
   import { payments } from './payments';
   import { email } from './email';

   vi.mock('./payments', () => ({ payments: { charge: vi.fn() } }));
   vi.mock('./email', () => ({ email: { sendReceipt: vi.fn() } }));

   const cart = { total: 4999, userEmail: 'ana@example.com' };
   const card = { token: 'tok_visa' };

   beforeEach(() => {
     vi.resetAllMocks();
     payments.charge.mockResolvedValue({ id: 'ch_123' });
     email.sendReceipt.mockResolvedValue(undefined);
   });

   describe('checkout', () => {
     it('returns the charge id when payment and receipt succeed', async () => {
       await expect(checkout(cart, card)).resolves.toBe('ch_123');
     });

     it('charges the given card for the cart total', async () => {
       await checkout(cart, card);
       expect(payments.charge).toHaveBeenCalledWith(card, 4999);
     });

     it('emails the receipt for the new charge to the cart owner', async () => {
       await checkout(cart, card);
       expect(email.sendReceipt).toHaveBeenCalledWith('ana@example.com', 'ch_123');
     });

     it('rejects with the payment error and sends no receipt when the charge fails', async () => {
       payments.charge.mockRejectedValue(new Error('card_declined'));
       await expect(checkout(cart, card)).rejects.toThrow('card_declined');
       expect(email.sendReceipt).not.toHaveBeenCalled();
     });

     it('rejects with the email error even though the card was already charged', async () => {
       email.sendReceipt.mockRejectedValue(new Error('smtp_down'));
       await expect(checkout(cart, card)).rejects.toThrow('smtp_down');
       expect(payments.charge).toHaveBeenCalledTimes(1);
     });
   });
   ```

5. **Run** `npx vitest run src/checkout.test.js`. I expect all 5 to pass.

6. **Prove the tests can fail** by breaking `checkout` locally three times, rerunning each time and then undoing the change:
   - Return `'x'`: tests 1 and 3 should go red.
   - Pass `0` instead of `cart.total`: test 2 should go red.
   - Send the email before charging: test 4 should go red.

   Afterwards, `git diff src/checkout.js` should be empty.

7. **Run everything:** `npm test`, plus the repo's `npm run lint` and `npm run typecheck` if those scripts exist.

8. **Log** in `notes.md`: the case list, the assumptions above, the mutation results and the open question in the reply below. No `git commit`.

## Final reply

> I added `src/checkout.test.js` with 5 tests: it returns the charge id, charges `cart.total`, sends the receipt to `cart.userEmail` with the charge id, a declined payment rejects and sends no email, and an email failure rejects. All 5 pass. I broke `checkout` three ways to check they catch real bugs, and each break turned the expected tests red. The full suite and lint pass.
>
> **You need to decide one thing:** if `sendReceipt` throws after `payments.charge` succeeds, `checkout` rejects even though the customer has been charged. A caller that retries would charge them twice. Test 5 records this current behaviour. Should a failed email be logged and the charge id still returned? If so, I'll write that as a failing test first and then fix it.
>
> I didn't test a zero or negative total, a missing email or a missing card. `checkout` doesn't handle those, and I'd rather not guess the rules. Tell me what they should be and I'll add tests.