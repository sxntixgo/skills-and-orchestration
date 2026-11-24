Nothing is written to `postmortem.md` yet. The notes leave gaps, and the skill says to stop and ask before drafting. I'd save the notes, timeline and facts files, then send the questions below.

**Steps in order**

1. **TodoWrite:** add the 7 checklist items from the skill.
2. **Save the input:** copy `incident-notes.md` word for word to `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-payment-timeout/notes.md`. The slug uses 2026-11-12 because that date is in the notes' header and 13:58 MST is 20:58 UTC on the same day.
3. **Write `timeline.md`:**
   ```markdown
   Source TZ: US/Mountain (stated in notes header). On 2026-11-12 that is MST, UTC−07:00
   (DST ended 2026-11-01). All times below are 2026-11-12; no midnight-UTC crossing.

   | Time (UTC) | Event | Note ref |
   |---|---|---|
   | 20:58 | Deploy 4812 changes the payment-gateway timeout in config/payments.yaml from 30s to 3s | 14:04, 14:06 |
   | 21:02 | PagerDuty alert: checkout-api error rate > 5% | 14:02 |
   | 21:04 | On-call engineer starts investigating; checkout-api is returning 502s, starting at the deploy | 14:04 |
   | 21:06 | Cause found: the timeout change in deploy 4812 | 14:06 |
   | 21:11 | Rollback of 4812 starts | 14:11 |
   | 21:19 | Rollback finishes; error rate back under 0.5% (resolved) | 14:19 |
   | 21:25 | Impact estimate: ~12% of checkout requests failed, ~1,900 orders | 14:25 |
   | 21:31 | Config change confirmed to have used the fast-path pipeline, which skips integration tests | 14:31 |
   | 21:40 | Support reports 37 tickets | 14:40 |
   ```
4. **Write `facts.md`:**
   ```markdown
   ## Impact
   - Duration: 21m (20:58→21:19 UTC). Time to detect 4m (20:58→21:02); time to mitigate 17m (21:02→21:19) [14:02, 14:19]
   - Failed checkout requests: ~12% [14:25]
   - Orders affected: ~1,900 [14:25]
   - Customers charged for failed orders: none. Payments that timed out were not charged [14:25]
   - Support tickets: 37 [14:40]
   - Total requests, unique users, revenue, SLO budget burned, severity: Unknown

   ## Root cause
   - A config change could reach production through the fast-path pipeline, which skips integration
     tests. Nothing caught a 3s payment-gateway timeout that is shorter than normal gateway latency. [14:06, 14:31]

   ## Contributing factors
   - The change was merged without review, and the notes suggest this has happened before ("again").
     Review isn't enforced for this config path. [14:09]
   - There is no validation or bounds check on timeout values in config/payments.yaml. [14:06]

   ## Went well
   - The alert fired 4m after the deploy; the cause was found 4m later; the rollback took 8m. [14:02–14:19]
   - Timed-out payments were not charged. [14:25]

   ## Actions (owners/dates: none in notes)
   - Prevent: route changes to config/payments.yaml through the full pipeline, including integration tests
   - Prevent: require an approving review for config/ changes, enforced by branch protection
   - Prevent: add a schema/bounds check that rejects payment-gateway timeouts below an agreed minimum
   - Detect: alert on the checkout-api 502 rate per deploy, with automatic rollback (Open question)
   ```
   The notes say "Bob pushed that config without review again". The facts files describe this as the change being merged without review, with review not enforced. No names appear in the narrative or root cause.
5. **STOP gate:** send the questions below and wait for answers.

**Reply to the user:**

> I've built the timeline and facts in `.claude-skills-work/incident-postmortem/2026-11-12-checkout-payment-timeout/`. Times are converted from MST (UTC−7), and the outage ran 20:58–21:19 UTC. I need a few answers before I write the postmortem:
>
> 1. **Date:** the notes are dated 2026-11-12, but you said "yesterday" (today is 2026-11-24). Is 2026-11-12 the right date?
> 2. **Impact figures:** total checkout requests in the window, unique customers affected, revenue from the ~1,900 failed orders, and SLO budget burned. Also, did any of those orders succeed on retry?
> 3. **Severity:** what level was this?
> 4. **Action owners and due dates:** who owns each item and by when? The notes don't name anyone, so otherwise I'll write `TBD — assign`.
> 5. **Review policy:** is review supposed to be required for `config/payments.yaml`, or is it optional on the fast path? The notes say the review was skipped "again", and this decides whether the root cause is a policy that isn't enforced or a policy that doesn't exist.
>
> If you'd rather I write it now, say "just write it". I'll mark these items `Unknown`/`TBD` and list them under Open questions.