I drafted the postmortem from the notes and marked every gap as an open question instead of filling it in. The notes are only four lines, so most of the analysis is still unanswered.

**What I'd do:** write the file below to `postmortems/2026-11-20-search-api-latency.md`. I'm assuming the repo has a `postmortems/` directory and no house template; if there is a template, I'd use its sections instead. I wouldn't spawn any subagents or run any commands.

```markdown
# Postmortem: search-api latency during index rebuild — 2026-11-20

**Status:** DRAFT — needs input from responders (see Open questions)
**Severity:** TBD
**Duration:** ~25 min of alerting impact (09:15–09:40 UTC); rebuild began 09:10
**Source:** #incidents channel export only

## Summary
search-api p95 latency went above 4s after an index rebuild job, started at
09:10 UTC, put heavy load on the database. Sam paused the rebuild at 09:31 and
latency was back to normal by 09:40.

## Timeline (UTC)
| Time  | Event |
|-------|-------|
| 09:10 | Index rebuild job starts (per sam, 09:17) |
| 09:15 | Alert: search-api p95 latency > 4s |
| 09:17 | sam: rebuild job identified as "hammering the db" |
| 09:31 | sam pauses rebuild; latency starts recovering |
| 09:40 | sam: back to normal |

## Root cause (provisional)
DB contention from the index rebuild job, as sam stated at 09:17. Recovery after
the pause supports this, but no DB metrics are in the notes to confirm it.

## Impact
Unknown beyond p95 > 4s. Error rates, timeouts, affected users/requests: not recorded.

## What went well / poorly
- Well: cause identified 2 min after the alert.
- Poorly: 14 min between identifying the cause and pausing the rebuild. Reason not recorded.
- Poorly: the rebuild ran without protecting live search traffic. Throttling, scheduling or a read replica would have prevented this.

## Open questions
1. Who or what started the rebuild at 09:10? Scheduled or manual? Why then?
2. Is the rebuild still paused? Was it resumed or finished, and did that cause more impact?
3. What was the user-facing impact (errors, timeouts, request volume)?
4. Was the DB load confirmed (CPU, locks, connections)?
5. Why 14 min from diagnosis to pause?
6. What severity applies?

## Action items (proposed — owners TBD)
- [ ] Throttle or rate-limit the index rebuild job's DB load
- [ ] Run rebuilds off-peak or against a replica
- [ ] Document how to pause or kill the rebuild in the search-api runbook
- [ ] Alert on DB load caused by the rebuild before search latency suffers
```

**Reply to you:**

I've saved the draft at `postmortems/2026-11-20-search-api-latency.md`. The timeline and the likely cause, the index rebuild overloading the database, come from the channel export. Everything else is unknown: impact, severity, who started the rebuild and why, whether it's still paused, and why pausing took 14 minutes after the cause was found. I listed these as open questions and didn't guess. The action items are suggestions with no owners yet. If Sam or the on-call engineer can answer the open questions, or send dashboards for 09:00–09:45 UTC, I'll finish the impact and root-cause sections.