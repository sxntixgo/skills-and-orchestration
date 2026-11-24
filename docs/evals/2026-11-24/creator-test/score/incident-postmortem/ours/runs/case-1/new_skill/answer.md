**Plan, in order**

1. **TodoWrite:** check input · fix clock / timeline.md · milestones and durations · impact · cause · action items · postmortem.md · reply.
2. **Check input:** I'd read `incident-notes.md`. It has timestamps, so I can go ahead.
3. **Fix the clock:** the header says "times are US/Mountain". DST ended on 2026-11-01, so on 2026-11-12 Mountain is MST (UTC−7). I'd add 7 hours to every time; no times cross midnight. The header gives 2026-11-12 as the date, but you said "yesterday" (2026-11-23). I'd use the header date and flag the mismatch.
4. **Write `./.claude-skills-work/incident-postmortem/timeline.md`:** this is the timeline table below.
5. **Write `./.claude-skills-work/incident-postmortem/postmortem.md`:**

```markdown
# Postmortem: Checkout API 502s after payment-gateway timeout change (2026-11-12 UTC) — Status: Draft
Timezone source: export header "times are US/Mountain"; 2026-11-12 is after DST ended, so MST = UTC−7 (+7h applied). Date taken from header (user said "yesterday"; see Open questions).

## Summary
At 20:58 UTC, deploy 4812 changed the payment-gateway timeout in `config/payments.yaml` from 30s to 3s. Payment calls began timing out and checkout-api returned 502s. An error-rate alert fired at 21:02 UTC. The on-call engineer traced the errors to deploy 4812 and rolled it back. The error rate was back under 0.5% by 21:19 UTC. The change went out through the fast-path pipeline, which skips integration tests.

## Impact
- checkout-api error rate > 5% (21:02 UTC, PagerDuty alert)
- ~12% of checkout requests failed between 20:58 and 21:19 UTC, about 1,900 orders (21:25 UTC)
- Payments that timed out were not charged (21:25 UTC)
- 37 support tickets (21:40 UTC)
- Lost revenue: UNKNOWN (ask: finance / orders dashboard)
- Orders later retried or completed by customers: UNKNOWN (ask: checkout analytics)

## Timeline (UTC)
| Time UTC | Event | Milestone |
|---|---|---|
| 2026-11-12 20:58 | Deploy 4812 ships; payment-gateway timeout 30s → 3s | Start |
| 2026-11-12 21:02 | PagerDuty: checkout-api error rate > 5% | Detected |
| 2026-11-12 21:04 | On-call sees 502s from checkout-api, linked to the 20:58 deploy | |
| 2026-11-12 21:06 | Timeout change in `config/payments.yaml` identified | |
| 2026-11-12 21:09 | Responder notes the config was pushed without review | |
| 2026-11-12 21:11 | Rollback of 4812 started | |
| 2026-11-12 21:19 | Rollback done; error rate < 0.5% | Mitigated / Resolved |
| 2026-11-12 21:25 | Impact estimate: ~12% of requests, ~1,900 orders; timed-out payments not charged | |
| 2026-11-12 21:31 | Change found to have used the fast-path pipeline (no integration tests) | |
| 2026-11-12 21:40 | Support reports 37 tickets | |

## Durations
- TTD: 21:02 − 20:58 = 4 min
- TTM: 21:19 − 20:58 = 21 min
- Total: 21:19 − 20:58 = 21 min (the notes record no separate resolution step; mitigation = resolution)

## Root cause
- **Trigger:** a config change cut the payment-gateway timeout from 30s to 3s, which is shorter than the gateway's normal response time. Payment calls timed out and checkout returned 502s.
- **Root cause:** the fast-path pipeline let a payment-critical config change reach production with no peer review and no integration tests. Nothing blocked an unsafe timeout value before it hit customers.

## Contributing factors
- **Process:** the responder's remark ("without review again") suggests unreviewed config pushes have happened before, and nothing prevents them.
- **Validation:** there is no schema or bounds check on timeout values in `config/payments.yaml`.
- **Deployment:** the config went straight to full production with no canary and no automatic rollback on error-rate regression.
- **Detection:** the alert threshold is 5% error rate. Detection took 4 min, during which failures were already affecting customers.

## Action items
| # | Action | Addresses | Owner | Due |
|---|---|---|---|---|
| 1 | Make the fast-path pipeline reject changes to `config/payments.yaml` unless they have an approved review and pass integration tests | Root cause | TBD | TBD |
| 2 | Enforce code-owner review for payment config in branch protection, and verify that a direct push is rejected | Process | TBD | TBD |
| 3 | Add CI validation that fails when the payment-gateway timeout is outside an agreed range | Validation | TBD | TBD |
| 4 | Canary config deploys with automatic rollback when the checkout-api error rate goes above baseline | Deployment | TBD | TBD |
| 5 | Review the checkout-api alert threshold and window (e.g. alert at 2% for 1 min) and record the decision | Detection | TBD | TBD |

## Open questions
- Incident date: the header says 2026-11-12, but the user said "yesterday" (2026-11-23). Which is correct?
- Owners and due dates for action items 1–5.
- Lost revenue, and how many of the ~1,900 failed orders were later completed.
- What was the intended reason for the 3s timeout? (Needed to set the bounds in item 3.)
- How many earlier config pushes skipped review through the fast path?
- Were the 37 support tickets answered, and do the affected customers need follow-up?
```

**Blameless rewrite:** the note at 14:09 MST names the engineer who made the change. I left that name out of the postmortem and described the event as "config was pushed without review". The notes state no owners, so every action-item owner is TBD.

---

**Final reply**

I wrote the postmortem to `./.claude-skills-work/incident-postmortem/postmortem.md`, with the timeline also in `timeline.md`.

**Time zone:** the notes are in US/Mountain. On 2026-11-12 that's MST (UTC−7), so I converted all times to UTC.

**Durations:**
- **Time to detect:** 4 min (20:58 → 21:02 UTC)
- **Time to mitigate:** 21 min (20:58 → 21:19 UTC)
- **Total:** 21 min

**Open questions:**
- The notes are dated 2026-11-12, but you said "yesterday" (2026-11-23). Which date is right?
- Who owns action items 1–5, and when are they due? All are TBD for now.
- How much revenue was lost, and how many of the ~1,900 failed orders were later completed?
- Why was the timeout set to 3s? The answer sets the allowed range for the new config check.
- How often have earlier config changes gone through the fast path without review?
- Do the 37 customers who opened tickets need follow-up?