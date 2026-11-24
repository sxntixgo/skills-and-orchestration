I'd write the postmortem below to `postmortems/2026-11-12-checkout-502s.md`. It sticks to what the notes say and marks what they don't cover as open.

One mismatch to check: you said "yesterday", but the notes are dated **2026-11-12** and today is 2026-11-24. I used 2026-11-12. I also left out who pushed the change and the "without review again" comment. The postmortem treats the cause as the missing review and test steps in the fast-path pipeline, not as one person's mistake.

```markdown
# Postmortem: Checkout 502s after payment-timeout config change — 2026-11-12

**Status:** Draft · **Severity:** TBD (proposed SEV-2) · **Times:** US/Mountain

## Summary
At 13:58 deploy 4812 cut the payment-gateway timeout in `config/payments.yaml`
from 30s to 3s. Gateway calls that took longer than 3s timed out, and checkout-api
returned 502s. About 12% of checkout requests failed for 21 minutes (about 1,900
orders). Rolling back 4812 fixed it at 14:19. Customers whose payments timed out
were not charged.

## Impact
- **Duration:** 21 min (13:58–14:19)
- **Failed checkouts:** ~12% of requests, ~1,900 orders
- **Money:** no charges on failed payments (no double-charges or orphaned charges reported)
- **Support:** 37 tickets
- **Revenue lost / customers who didn't come back:** unknown, needs data

## Timeline
| Time  | Event |
|-------|-------|
| 13:58 | Deploy 4812 (payment timeout 30s → 3s) goes out through the fast-path pipeline |
| 14:02 | PagerDuty alert: checkout-api error rate > 5% |
| 14:04 | On-call sees 502s and links them to the 13:58 deploy |
| 14:06 | Timeout change in `config/payments.yaml` found to be the cause |
| 14:11 | Rollback of 4812 starts |
| 14:19 | Rollback finishes; error rate under 0.5% |
| 14:25 | Impact estimated (~12%, ~1,900 orders, no charges) |
| 14:31 | Found that the fast path skips integration tests |
| 14:40 | Support reports 37 tickets |

Time to detect: 4 min · Time to diagnose: 8 min · Time to mitigate: 21 min (rollback alone took 8)

## Root cause
The 3s timeout was below the gateway's normal response time for some requests, so
those calls failed. *(Assumption: gateway latency regularly goes above 3s. Confirm
with p95/p99 data.)*

## Contributing factors
1. **Config changes go through a fast-path pipeline that skips integration tests.**
   Integration tests would probably have caught this.
2. **The change wasn't reviewed before deploy.** The notes say this has happened
   before, so the pipeline doesn't enforce review on payment config.
3. **Nothing validates critical timeout values** (no minimum allowed value, no canary).
4. **The rollback took 8 minutes.**

## What went well
- The alert fired within 4 minutes, and the deploy was linked to it within 2 more.
- Rollback was the obvious fix and it worked.
- A short timeout fails safely: customers weren't charged.

## Action items
| # | Action | Owner | Priority |
|---|--------|-------|----------|
| 1 | Require review for changes to `config/payments.yaml` (CODEOWNERS + branch protection) | TBD | P0 |
| 2 | Send payment/checkout config through the full pipeline with integration tests, or add those tests to the fast path | TBD | P0 |
| 3 | Validate payment timeouts in CI against measured gateway latency | TBD | P1 |
| 4 | Canary config deploys, with automatic rollback when the error rate rises | TBD | P1 |
| 5 | Find out why rollback took 8 min and set a target | TBD | P2 |
| 6 | Contact the ~1,900 affected customers / recover abandoned carts | TBD | P2 |

## Open questions
- Why was the timeout changed to 3s, and what was it meant to fix?
- Gateway latency distribution (is 30s still the right value?)
- Revenue impact and how many failed orders were retried and completed
- What is the history of earlier unreviewed config pushes?
```

To finish it, it still needs owners for the action items, the severity level, the gateway latency data, and the revenue impact.