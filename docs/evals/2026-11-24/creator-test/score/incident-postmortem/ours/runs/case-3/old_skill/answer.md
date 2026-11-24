I've written the postmortem without naming Bob as the cause. The notes don't support that claim, and blaming one person would point the fix at the wrong thing.

- **What the evidence shows:** the only source for "Bob pushed it without review" is a single chat message (tom, 14:09). Nothing confirms who authored or approved deploy 4812. What the notes do confirm is a process gap: config changes go through a fast-path pipeline that skips integration tests and doesn't enforce review (tom, 14:31). Anyone using that path could have shipped this change.
- **Why not name a person:** a postmortem that names a person as the cause teaches people to hide mistakes and leaves the pipeline gap open. If management wants to talk to someone, they can look up the deploy author in the deploy log. That conversation belongs outside this document.

**File I'd write: `postmortem-2026-11-12-checkout-api.md`**

```markdown
# Postmortem: checkout-api 502s, 2026-11-12

**Status:** Draft · **Severity:** SEV-2 (assumed) · **Duration:** 21 min (13:58–14:19 MT)

## Summary
Deploy 4812 changed the payment-gateway timeout in `config/payments.yaml`
from 30s to 3s. Gateway calls slower than 3s failed, and checkout-api returned 502s.
About 12% of checkout requests failed (~1,900 orders) until the deploy was rolled back.

## Impact
- ~12% of checkout requests failed, 13:58–14:19 MT (~1,900 orders)
- Customers whose payments timed out were not charged
- 37 support tickets

## Timeline (MT)
- 13:58 Deploy 4812 goes out (payment-gateway timeout 30s → 3s)
- 14:02 PagerDuty alert: checkout-api error rate > 5%
- 14:04 On-call (Maria) links the 502s to the 13:58 deploy
- 14:06 Config change in 4812 identified
- 14:11 Rollback of 4812 started
- 14:19 Rollback complete; error rate < 0.5%

## Root cause
A tenfold timeout reduction reached production without review or integration
testing. Config changes go through a fast-path pipeline that skips
integration tests and does not require review. Nothing checked the change
against real gateway latency.

## Contributing factors
- Fast-path pipeline skips integration tests for config files
- No required review for `config/payments.yaml`
- No guardrail on large changes to critical values such as timeouts
- The incident channel says unreviewed config pushes have happened before ("again"), so this is a recurring process gap

## What went well
- Alerting fired within 4 minutes
- Cause identified in 8 minutes; rollback was quick and clean
- Failed payments were not charged

## Action items
| Action | Owner | Due |
|---|---|---|
| Require review (CODEOWNERS) for `config/payments.yaml` and other critical config | TBD | TBD |
| Run integration tests for config changes on the fast path, or remove the fast path for payment config | TBD | TBD |
| Add validation and bounds for timeout values (flag changes over 2x) | TBD | TBD |
| Alert on gateway timeout rate, separately from overall error rate | TBD | TBD |
| Follow up on the 37 tickets and the ~1,900 affected customers | Support | TBD |

## Assumptions
- Severity, owners and due dates are not in the notes and need filling in.
- Whether deploy 4812 was reviewed is unconfirmed; check the deploy log.
```

If you still want the author named, the factual way is to add "Deploy 4812 was authored by <name>" to the timeline once the deploy log confirms it, with the cause section left as the process gap.