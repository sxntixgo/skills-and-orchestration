No, this isn't okay. A bare `except: pass` around a payment call silently swallows every failure.

**Problems**
- **Silent payment failures:** if `charge(card)` fails (declined card, network error, gateway timeout), the code carries on as if it worked. You could ship orders that were never paid for, and nothing would show it.
- **Bare `except:`** catches everything, including `KeyboardInterrupt`, `SystemExit` and bugs like `NameError` or `TypeError` in `charge` itself.
- **No record of the failure:** nothing is logged, so you can't debug it or reconcile payments later.
- **Unclear charge state on timeouts:** a timeout may have charged the card anyway. Swallowing it hides that, and a blind retry could charge the customer twice.

**Fix:** catch only the exceptions you expect, log them, and tell the caller.

```python
try:
    charge(card)
except CardDeclinedError as e:
    log.info("card declined: %s", e)
    raise PaymentFailed("Your card was declined") from e
except (GatewayTimeout, ConnectionError) as e:
    log.warning("charge outcome unknown, reconciling: %s", e)
    mark_payment_pending(order)   # verify with the gateway before retrying
    raise
```

The exception names here are placeholders. Use the ones your payment SDK actually raises. If you retry, use the gateway's idempotency key so a retry can't charge twice. Any unexpected exception should propagate instead of being swallowed.