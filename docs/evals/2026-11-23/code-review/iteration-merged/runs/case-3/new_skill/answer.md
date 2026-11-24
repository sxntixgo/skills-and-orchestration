**What I'd do (dry run):**

1. TodoWrite: Context → Check dimensions → Rate/order → Report.
2. Context: there's no file, only a pasted snippet, so I can't read callers. I assume `charge(card)` is a payment-gateway call inside a checkout flow, and that the code continues to fulfil the order after this block.
3. Write the report below to `./.claude-skills-work/code-review/snippet-charge/findings.md`.

**Reply:**

No. This breaks payments: any failed charge is silently treated as a success.

## Code Review: pasted snippet (`try: charge(card) except: pass`)
### 🔴 Must fix
1. **Payment fails open: the bare `except: pass` swallows every error** (snippet:1). Exploit: someone checks out with a declined, expired or invalid card. `charge()` raises, the error is discarded, and the order goes through as if it were paid. Impact: free goods or services, revenue loss and corrupted order/payment records. No log or alert is written, so nobody notices. A bare `except` also catches `KeyboardInterrupt` and `SystemExit`. → Catch only the gateway's specific exceptions (e.g. `CardDeclinedError`, `PaymentGatewayError`). On failure, log the order ID and error code (never the card data), then re-raise or return a failure status so the caller stops fulfilment.

### 🟡 Should fix
1. **A timeout looks the same as a decline** (snippet:1). If the gateway times out, the charge may have gone through. Retrying blindly can charge the customer twice, and giving up can lose a payment you actually took. → Handle timeouts separately, pass an idempotency key to `charge()`, and reconcile the charge's status before you retry.
2. **Failure paths have no tests** (snippet:1). → Add tests where `charge` raises a decline error and a timeout, and assert that the order is not fulfilled and that the error reaches the caller.

### 🟢 Consider
1. **Let the caller see the result** (snippet:1). If `charge()` returns a result object, check its success field too. Some SDKs report a decline in the return value instead of raising.

### ✅ Good
- The `try` wraps only the one risky call, so the fix stays local.