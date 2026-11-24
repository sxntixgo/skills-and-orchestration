The postmortem draft would be `./.claude-skills-work/incident-postmortem/postmortem.md`. The notes are only 4 lines, so most of it is marked UNKNOWN or TBD. Durations: **time to detect 5 min, time to mitigate 21 min, total 30 min.**

**What I'd do, in order:**

1. Make TodoWrite items for the 7 skill steps.
2. **Check the input.** `incident-notes-thin.md` has timestamps, so I continue.
3. **Fix the clock.** The header says `2026-11-20 (UTC)`, so no conversion is needed and nothing crosses midnight. Write `./.claude-skills-work/incident-postmortem/timeline.md`:
   ```
   | Time UTC | Event | Milestone |
   |---|---|---|
   | 2026-11-20 09:10 | Index rebuild job starts (reported at 09:17) | Start (assumed) |
   | 2026-11-20 09:15 | Alert: search-api p95 latency > 4s | Detected |
   | 2026-11-20 09:17 | Responder links latency to rebuild job load on the DB | |
   | 2026-11-20 09:31 | Rebuild paused; latency recovering | Mitigated |
   | 2026-11-20 09:40 | Responder reports back to normal | Resolved |
   ```
4. Write `./.claude-skills-work/incident-postmortem/postmortem.md`:
   ```
   # Postmortem: search-api latency during index rebuild (2026-11-20 UTC) — Status: Draft
   Timezone source: channel export header "2026-11-20 (UTC)". Assumption: impact began when
   the rebuild job started (09:10); the notes don't say when latency first got worse.

   ## Summary
   On 2026-11-20 an index rebuild job started at 09:10 UTC and put heavy load on the database
   behind search-api. At 09:15 an alert fired because search-api p95 latency was above 4s. The
   responder linked the latency to the rebuild and paused the job at 09:31. Latency was back to
   normal by 09:40.

   ## Impact
   - search-api p95 latency > 4s (alert, 09:15 UTC)
   - Affected users/requests: UNKNOWN (ask: search-api dashboard / owning team)
   - Error rate: UNKNOWN (ask: search-api metrics)
   - SLO minutes consumed: UNKNOWN (ask: SLO dashboard)
   - Revenue impact: UNKNOWN (ask: product/business owner)

   ## Timeline (UTC)
   <table from timeline.md>

   ## Durations
   - TTD: 09:15 − 09:10 = 5 min
   - TTM: 09:31 − 09:10 = 21 min
   - Total: 09:40 − 09:10 = 30 min

   ## Root cause
   Trigger: the index rebuild job started at 09:10. Root cause (hypothesis, not confirmed by
   the notes): the rebuild could run against the production database while it served
   search-api traffic, with no throttling or resource isolation to protect live queries.

   ## Contributing factors
   - Unknown whether the 09:10 start was scheduled or manual (scheduling / change control).
   - No sign in the notes that a load check or pause step was part of the rebuild process
     (runbook / tooling).
   - Detection came from a latency alert 5 min after the start; nothing alerted on the job's
     DB load itself (alerting).
   - Recovery after the rebuild was paused is undocumented: was it resumed, and how? (runbook)

   ## Action items
   | # | Action | Addresses | Owner | Due |
   |---|---|---|---|---|
   | 1 | Add rate limiting or a DB resource cap to the index rebuild job; verify with a load test showing search-api p95 stays below its SLO during a rebuild | Root cause | TBD | TBD |
   | 2 | Run rebuilds only in an approved low-traffic window or through change approval; verify with the job config or scheduler rule | Scheduling | TBD | TBD |
   | 3 | Add an alert on DB load/saturation from batch jobs; verify by test-firing the alert | Alerting | TBD | TBD |
   | 4 | Write a rebuild runbook covering pause, resume and load checks; verify the doc is linked from the job | Runbook | TBD | TBD |

   ## Open questions
   1. When did latency actually start rising? Was it at 09:10?
   2. How many users or requests were affected? What was the error rate, how many SLO minutes were used, and was there any revenue impact?
   3. Why did the rebuild start at 09:10? Was it scheduled or manual, and why at that time?
   4. Does the rebuild job already have any throttling or isolation from production DB traffic?
   5. Was the rebuild resumed or finished later? When, and with what safeguards?
   6. Who owns each action item, and what are the due dates?
   ```
   Blameless check: "sam" appears only as "the responder", and no names appear in the Summary or Root cause.

---

**Reply to user:**

I wrote the draft postmortem to `./.claude-skills-work/incident-postmortem/postmortem.md`, with the timeline in `timeline.md`. Times are already UTC according to the export header.

- **Time to detect:** 09:15 − 09:10 = 5 min
- **Time to mitigate:** 09:31 − 09:10 = 21 min
- **Total:** 09:40 − 09:10 = 30 min

All three assume impact started when the rebuild started (09:10). The notes don't say when latency first rose.

The notes are thin, so the impact figures, owners and due dates are marked UNKNOWN or TBD, and the root cause is labelled a hypothesis.

**Open questions:**
1. When did latency actually start rising? Was it at 09:10?
2. How many users or requests were affected? What was the error rate, how many SLO minutes were used, and was there any revenue impact?
3. Why did the rebuild start at 09:10? Was it scheduled or manual?
4. Does the rebuild job have any throttling or isolation from production DB traffic?
5. Was the rebuild resumed or finished later, and how?
6. Who owns action items 1–4, and what are the due dates?