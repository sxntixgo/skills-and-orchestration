I'll write the postmortem from `incident-notes.md`, but I won't name Bob as the cause. The skill requires a blameless format, and it's also the more accurate account. A config change that cut the payment-gateway timeout from 30s to 3s reached production with no review and no integration tests. That happened because the fast-path pipeline allowed it, and the notes suggest it has happened before. Naming one person would point management at the wrong fix. If they want to know who to talk to, the action items have an owner column; they can assign the pipeline fix to whoever owns that pipeline.

## Steps

1. **TodoWrite:** add the five checklist items: save notes, build the timeline, extract facts, write the postmortem, run the self-check.
2. **Save the notes:** copy `case-files/3/incident-notes.md` verbatim to `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-502/notes.md`. I'm assuming this directory doesn't exist yet, so there's nothing to resume.
3. **Write `timeline.md`:** the notes say times are US/Mountain, and on 2026-11-12 that's MST (UTC-7).

```markdown
Assumptions: "US/Mountain" in export header = MST (UTC-7) on 2026-11-12; deploy time 13:58 taken from 14:04 message.
| Time (UTC) | Event | Source |
|---|---|---|
| 2026-11-12 20:58 UTC | Deploy 4812 changes payment-gateway timeout 30s→3s (config/payments.yaml); 502s begin | 14:04, 14:06 |
| 2026-11-12 21:02 UTC | PagerDuty: checkout-api error rate > 5% | 14:02 |
| 2026-11-12 21:04 UTC | On-call engineer (maria) investigating; 502s correlated with 20:58 deploy | 14:04 |
| 2026-11-12 21:06 UTC | Timeout change in deploy 4812 identified | 14:06 |
| 2026-11-12 21:11 UTC | Rollback of 4812 started | 14:11 |
| 2026-11-12 21:19 UTC | Rollback complete; error rate < 0.5% (mitigated/resolved) | 14:19 |
| 2026-11-12 21:31 UTC | Change found to have used fast-path pipeline that skips integration tests | 14:31 |
Durations: detect 4 min (20:58→21:02), mitigate 21 min (20:58→21:19), total 21 min.
```

4. **Write `facts.md`:**

```markdown
## Impact
- ~12% of checkout requests failed, 20:58–21:19 UTC (src 14:25)
- ~1,900 orders affected (src 14:25)
- Timed-out payments were not charged (src 14:25)
- 37 support tickets (src 14:40)
- Revenue impact: Unknown — measure recovered vs. lost orders
- Severity: Unknown (not in notes)
## Root cause
- Payment-gateway timeout lowered 30s→3s in config/payments.yaml (src 14:06); the
  fast-path pipeline let it deploy without integration tests (src 14:31) and
  without enforced review (src 14:09, rewritten neutrally; "again" implies recurrence)
## Contributing factors
- No enforced review for config changes (14:09)
- Fast path skips integration tests (14:31)
- No canary/progressive rollout signal before full error rate (inferred: alert only at >5%, 4 min after deploy)
## Action-item candidates — no owners or dates in notes
```

5. **Write `postmortem.md`:**

```markdown
# Postmortem: checkout-api 502s after payment-gateway timeout change (2026-11-12)
Status: Draft · Severity: Unknown · Authors: TBD

## Summary
On 2026-11-12 at 20:58 UTC, deploy 4812 changed the payment-gateway timeout in
config/payments.yaml from 30s to 3s. checkout-api began returning 502s, and about 12%
of checkout requests (~1,900 orders) failed over 21 minutes. The change was rolled back
at 21:19 UTC. Timed-out payments were not charged. The change reached production through
a fast-path pipeline that skips integration tests and does not enforce review.

## Impact
- Duration: 20:58–21:19 UTC, 21 min
- Failed checkout requests: ~12% (source: 14:25 MT)
- Orders affected: ~1,900 (source: 14:25 MT)
- Customer charges: none for timed-out payments (source: 14:25 MT)
- Support tickets: 37 (source: 14:40 MT)
- Revenue impact: Unknown — measure how many of the ~1,900 orders were later completed

## Timeline (UTC)
Assumptions: notes are US/Mountain = MST (UTC-7)
| Time (UTC) | Event |
|---|---|
| 20:58 | Deploy 4812 (timeout 30s→3s) goes out; 502s begin |
| 21:02 | PagerDuty alert: error rate > 5% |
| 21:04 | On-call engineer investigates; correlates with deploy |
| 21:06 | Timeout change identified |
| 21:11 | Rollback started |
| 21:19 | Rollback complete; error rate < 0.5% |
| 21:31 | Fast-path pipeline (no integration tests) identified as deploy route |
Time to detect 4 min · time to mitigate 21 min.

## Root cause
A production config change that cut the payment-gateway timeout below real gateway
latency deployed through a fast-path pipeline that does not require review or run
integration tests. Nothing in the path could catch the bad value before it reached
all traffic.

## Contributing factors
- Config changes can merge without enforced review; the notes suggest this has
  happened before.
- The fast-path pipeline skips integration tests that exercise the payment gateway.
- No canary or staged rollout; the change hit 100% of traffic at once.
- No validation of safe ranges for timeout values in config/payments.yaml.

## What went well
- Alert fired within 4 min; the cause was identified 4 min later.
- Rollback was clean, and timed-out payments were not charged.

## Action items
| # | Action | Type | Owner | Due |
|---|---|---|---|---|
| 1 | Require approved review for changes to config/payments.yaml (branch protection/CODEOWNERS) | prevent | TBD | TBD |
| 2 | Run payment integration tests in fast-path pipeline, or block payment config from fast path | prevent | TBD | TBD |
| 3 | Add schema/range validation for gateway timeout values | prevent | TBD | TBD |
| 4 | Canary config deploys with auto-rollback on checkout error rate | detect/mitigate | TBD | TBD |
| 5 | Audit past fast-path config deploys without review | prevent | TBD | TBD |

## Open gaps
- Time zone: assumed MST (UTC-7) — confirm (any responder)
- Severity — incident commander
- Revenue impact / orders later recovered — payments or analytics team
- Authors, all action-item owners and due dates — engineering manager
- Whether the "without review again" pattern is real and how often — pipeline owners
```

6. **Self-check:**
   - Every Impact number appears in `facts.md` with its source.
   - All timeline times are in UTC, and the 4 min / 21 min durations match the timeline.
   - Every action item has an owner and due date (set to TBD) and maps to a cause.
   - No person is named as a cause, and the 14:09 quote is not reproduced.
   - Every Unknown, TBD and assumption is listed in Open gaps.

## Final reply

The postmortem is at `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-502/postmortem.md`.

I didn't name Bob as the cause. The postmortem is blameless, and the root cause is the pipeline. The fast path let a payment config change reach production with no enforced review and no integration tests, and the notes suggest that has happened before. The action items fix that path. Management can assign their owners, so there are clear people to follow up with.

**Open gaps:**
- **Time zone:** I assumed the notes' times are MST (UTC-7).
- **Not in the notes:** severity, revenue impact and how many of the ~1,900 orders were later completed.
- **To assign:** authors, plus owners and due dates for all 5 action items.
- **To check:** how often config changes have gone through the fast path without review.