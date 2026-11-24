The postmortem is drafted at `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-502/postmortem.md`. The incident happened on **2026-11-12**, not yesterday (2026-11-23), so check that I have the right notes. Owners, due dates and severity are all still TBD.

## Steps

**1. TodoWrite**, one item per checklist step:
1. Save notes
2. UTC timeline
3. Facts
4. postmortem.md
5. Self-check and reply

**2. Check for an existing working directory.** `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-502/` doesn't exist, so I start fresh.

**3. Write `notes.md`**: the contents of `case-files/1/incident-notes.md`, copied as-is.

**4. Write `timeline.md`.** The export header gives the zone as US/Mountain. Daylight saving ended on 2026-11-01, so the offset is MST = UTC−7.

```markdown
# Timeline (UTC)
Assumptions: export header says US/Mountain; 2026-11-12 is MST (UTC-7).

| Time (UTC) | Event | Source |
|---|---|---|
| 2026-11-12 20:58 UTC | Deploy 4812 rolls out; checkout-api 502s begin | 14:04, 14:25 |
| 2026-11-12 21:02 UTC | PagerDuty alert: checkout-api error rate > 5% | 14:02 |
| 2026-11-12 21:04 UTC | On-call engineer acknowledges; links 502s to deploy 4812 | 14:04 |
| 2026-11-12 21:06 UTC | Cause found: payment-gateway timeout changed from 30s to 3s in config/payments.yaml | 14:06 |
| 2026-11-12 21:11 UTC | Rollback of 4812 starts | 14:11 |
| 2026-11-12 21:19 UTC | Rollback done; error rate < 0.5% (mitigated) | 14:19 |
| 2026-11-12 21:25 UTC | Impact estimate posted | 14:25 |
| 2026-11-12 21:31 UTC | Change found to have gone through fast-path pipeline (no integration tests) | 14:31 |
| 2026-11-12 21:40 UTC | Support reports 37 tickets | 14:40 |

Durations:
- Time to detect: 20:58 → 21:02 = 4 min
- Time to mitigate: 20:58 → 21:19 = 21 min (17 min after the alert)
- Rollback: 21:11 → 21:19 = 8 min
- Formal declaration and all-clear: not in notes
```

**5. Write `facts.md`.**

```markdown
# Facts (each cites the note timestamp, MST)
## Impact
- ~12% of checkout requests failed, 13:58–14:19 MST (14:25)
- ~1,900 orders affected (14:25)
- Payments that timed out were not charged (14:25)
- 37 support tickets (14:40)
- Duration 21 min, from the timeline (20:58–21:19 UTC)
- Unknown: revenue impact, number of customers who retried and completed checkout, SLO budget burned, severity

## Root cause
- Deploy 4812 cut the payment-gateway timeout from 30s to 3s; gateway calls timed out and checkout-api returned 502s (14:04, 14:06)
- The fast-path pipeline let a change to a payment-critical config ship without integration tests, which would likely have caught it (14:31)

## Contributing factors
- Config changes can ship without mandatory review; "again" suggests this has happened before (14:06–14:09, reworded blamelessly)
- No canary or automatic rollback on the error-rate spike; rollback was manual (14:11–14:19)

## Action-item candidates
- Route payment config changes through the full pipeline (prevent)
- Require review for config/payments.yaml (prevent)
- Add validation or bounds for timeout values (prevent)
- Canary plus auto-rollback on checkout-api error rate (mitigate)
- Owners and due dates: none in notes
```

**6. Write `postmortem.md`.**

```markdown
# Postmortem: Checkout 502s after payment-gateway timeout change (2026-11-12)
Status: Draft · Severity: Unknown · Authors: TBD

## Summary
On 2026-11-12 from 20:58 to 21:19 UTC, about 12% of checkout requests failed with 502s.
A config deploy (4812) had cut the payment-gateway timeout from 30s to 3s.
The change went through a fast-path pipeline that skips integration tests.
An alert fired 4 minutes after the deploy. Rolling back the deploy restored service.
Payments that timed out were not charged.

## Impact
- Duration: 20:58–21:19 UTC, 21 min
- Failed checkout requests: ~12% (source: 14:25 MST)
- Orders affected: ~1,900 (source: 14:25 MST)
- Customers charged for failed orders: none reported, since timed-out payments were not charged (source: 14:25 MST)
- Support tickets: 37 (source: 14:40 MST)
- Revenue impact: Unknown (measure orders not completed after retry)
- SLO budget burned: Unknown

## Timeline (UTC)
Assumptions: notes are in US/Mountain, which is MST (UTC-7) on this date.
| Time (UTC) | Event |
|---|---|
| 20:58 | Deploy 4812 ships; 502s begin |
| 21:02 | PagerDuty alert: error rate > 5% |
| 21:04 | On-call engineer acknowledges; links errors to deploy 4812 |
| 21:06 | Timeout change (30s→3s) in config/payments.yaml found |
| 21:11 | Rollback starts |
| 21:19 | Rollback done; error rate < 0.5% |
| 21:31 | Fast-path pipeline (no integration tests) found to be the delivery path |
| 21:40 | Support reports 37 tickets |
Time to detect 4 min · time to mitigate 21 min

## Root cause
The payment-gateway timeout was cut to 3s, below the gateway's normal response time, so payment calls timed out and checkout-api returned 502s.
The change reached production through the fast-path pipeline. That pipeline skips the integration tests that exercise the payment path, so nothing stopped a change this risky.

## Contributing factors
- Changes to payment-critical config don't require review, and this has happened before.
- Timeout values have no validation or sane bounds.
- No canary or automatic rollback: the change reached all traffic and recovery was manual (8 min).

## What went well
- The alert fired 4 min after the deploy.
- Deploy correlation pinpointed the cause within 8 min.
- The rollback was clean.
- Customers were not charged for failed orders.

## Action items
| # | Action | Type | Owner | Due |
|---|---|---|---|---|
| 1 | Exclude payment config (config/payments.yaml) from the fast-path pipeline; require integration tests | prevent | TBD | TBD |
| 2 | Require code-owner review for config/payments.yaml | prevent | TBD | TBD |
| 3 | Add schema validation with min/max bounds for payment timeouts | prevent | TBD | TBD |
| 4 | Canary deploys for checkout-api with auto-rollback on error-rate breach | mitigate | TBD | TBD |
| 5 | Audit past fast-path config deploys that skipped review ("again") | detect | TBD | TBD |

## Open gaps
- Severity: incident commander
- Formal declaration time and all-clear: incident commander
- Revenue impact and checkout completion after retry: payments/analytics
- SLO budget burned: SRE
- Owners and due dates for action items 1–5: engineering manager at the review meeting
- Assumed zone MST (UTC-7) from the export header: confirm with the on-call engineer
- Notes cover 2026-11-12, but the request said "yesterday": user
- Authors: TBD
```

**7. Self-check.** All five checks pass:
- Every Impact number traces to `facts.md` with a source.
- Every time is in UTC, and the durations match the timeline.
- Every action item has an Owner and Due (TBD) and maps to a cause.
- No names in the cause analysis, and I reworded the "pushed that config without review again" quote blamelessly.
- Open gaps lists every Unknown, TBD and assumption.

## Reply to user

> I've drafted the postmortem at `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-502/postmortem.md`. On 2026-11-12, from 20:58 to 21:19 UTC, about 12% of checkout requests failed (around 1,900 orders, 37 support tickets). A 3s payment-gateway timeout was shipped through the fast-path pipeline, which skips integration tests.
>
> **Open gaps:**
> - **Date:** the notes are from 2026-11-12, not yesterday. Are these the right notes?
> - **Severity and timing:** severity, the declaration time and the all-clear time aren't in the notes.
> - **Unmeasured impact:** revenue impact, how many customers completed checkout on retry, and SLO budget burned.
> - **Action items:** owners and due dates for all 5 are TBD.
> - **Time zone:** I converted times assuming MST (UTC−7), based on the export header.