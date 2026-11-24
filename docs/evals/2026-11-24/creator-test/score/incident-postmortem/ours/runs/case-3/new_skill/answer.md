I wrote the postmortem, but I left out the line blaming Bob. The skill requires a blameless document. Names appear only as action-item owners, and the cause has to be a gap in the system or process. "Pushed without review" happened because the fast-path pipeline let a config change ship with no required review and no integration tests. The notes say "again", so this has happened before. Management should look at that gap, and the action items fix it. If someone needs to know who made the change, deploy 4812's history shows it. The postmortem shouldn't be the place to point at a person.

**What I'd do, in order:**

1. Add TodoWrite items for the 7 skill steps.
2. Check the input: `case-files/3/incident-notes.md` has timestamps, so I can continue.
3. Fix the clock. The header says US/Mountain. On 2026-11-12 that's MST (DST ended Nov 1), so UTC−7. Every time gets +7h, and the date stays 2026-11-12.
4. Write `./.claude-skills-work/incident-postmortem/timeline.md` (same contents as the Timeline table below).
5. Write `./.claude-skills-work/incident-postmortem/postmortem.md`:

```markdown
# Postmortem: checkout-api 502s after payment-gateway timeout config change (2026-11-12 UTC) — Status: Draft
Timezone source: export header "times are US/Mountain"; MST (UTC−7) on 2026-11-12, +7h applied.

## Summary
At 20:58 UTC, deploy 4812 lowered the payment-gateway timeout in config/payments.yaml from 30s to 3s.
checkout-api began returning 502s, and about 12% of checkout requests failed. PagerDuty alerted at 21:02,
the on-call engineer linked the errors to deploy 4812, and the rollback finished at 21:19 UTC.
The change went out through the fast-path pipeline, which skips integration tests and did not require review.
Timed-out payments were not charged.

## Impact
- ~12% of checkout requests failed, 20:58–21:19 UTC (reported 21:25)
- ~1,900 orders failed (reported 21:25)
- Customers charged for failed orders: none ("Payments that timed out were not charged", 21:25)
- 37 support tickets (reported 21:40)
- Revenue impact: UNKNOWN (ask: finance / checkout revenue dashboard)
- SLO minutes consumed: UNKNOWN (ask: SRE / SLO dashboard)

## Timeline (UTC)
| Time UTC | Event | Milestone |
|---|---|---|
| 2026-11-12 20:58 | Deploy 4812 changes payment-gateway timeout 30s → 3s | Start |
| 2026-11-12 21:02 | PagerDuty: checkout-api error rate > 5% | Detected |
| 2026-11-12 21:04 | On-call engineer sees 502s, correlates with 20:58 deploy | |
| 2026-11-12 21:06 | Timeout change in config/payments.yaml identified | |
| 2026-11-12 21:09 | Noted that the config change was not reviewed (repeat occurrence) | |
| 2026-11-12 21:11 | Rollback of 4812 started | |
| 2026-11-12 21:19 | Rollback complete, error rate < 0.5% | Mitigated / Resolved |
| 2026-11-12 21:25 | Impact estimate: ~12% requests, ~1,900 orders | |
| 2026-11-12 21:31 | Confirmed the change used fast-path pipeline (no integration tests) | |
| 2026-11-12 21:40 | Support reports 37 tickets | |

## Durations
- TTD: 21:02 − 20:58 = 4 min
- TTM: 21:19 − 20:58 = 21 min
- Total: 21:19 − 20:58 = 21 min (resolution assumed at rollback complete)

## Root cause
Trigger: a config change lowered the payment-gateway timeout to 3s, below the gateway's real response times.
Why did it reach production? Config changes can go through the fast-path pipeline, which skips integration
tests and does not enforce review. Nothing validated the timeout value or exercised the payment path before deploy.
The notes say this has happened before ("again"), so the missing guardrail has been hit more than once.

## Contributing factors
- No schema or range validation on config/payments.yaml values.
- No canary or progressive rollout for config deploys. The full blast radius was reached at once.
- No automatic rollback on error-rate alerts. Mitigation depended on manual diagnosis (13 min from alert to rollback start).

## Action items
| # | Action | Addresses | Owner | Due |
|---|---|---|---|---|
| 1 | Require ≥1 approving review for changes to config/** (branch protection / CODEOWNERS); verify by attempting an unreviewed push | Root cause (no enforced review) | TBD | TBD |
| 2 | Route config/payments.yaml changes through integration tests (remove fast-path eligibility or add payment tests to fast path) | Root cause (fast path skips tests) | TBD | TBD |
| 3 | Add validation for payment-gateway timeout (e.g. min bound) that fails CI on out-of-range values | Contributing: no config validation | TBD | TBD |
| 4 | Add canary stage for config deploys with error-rate gate | Contributing: no canary | TBD | TBD |
| 5 | Auto-rollback when checkout-api error rate > 5% within N min of a deploy | Contributing: manual mitigation | TBD | TBD |

## Open questions
- Owners and due dates for action items 1–5?
- Revenue impact of ~1,900 failed orders (finance / revenue dashboard)?
- SLO minutes consumed (SRE / SLO dashboard)?
- Previous unreviewed fast-path config changes: how many, and were any incidents linked?
- Why was the timeout lowered to 3s? Was a ticket or intent recorded?
- Were failed orders retried by customers? Is ~1,900 net or gross lost orders?
```

**Results:**
- **File:** `./.claude-skills-work/incident-postmortem/postmortem.md`
- **Assumption:** times converted from US/Mountain as MST (UTC−7, +7h).
- **Durations:**
  - Time to detect: 4 min
  - Time to mitigate: 21 min
  - Total: 21 min
- **Open questions:**
  - Owners and due dates for all 5 action items
  - Revenue impact
  - SLO minutes consumed
  - How many earlier unreviewed fast-path config changes there were
  - Why the timeout was lowered to 3s
  - Whether ~1,900 is net or gross lost orders