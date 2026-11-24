The notes are too thin for a finished postmortem, so I'd stop at the skill's gate and ask questions before writing `postmortem.md`. The timezone is fine: the export is labelled UTC.

## What I'd do, in order

**1. TodoWrite**: the skill's 7 checklist items.

**2. Save the input** to `./.claude-skills-work/incident-postmortem/2026-11-20-search-api-latency-index-rebuild/notes.md`, a verbatim copy of `incident-notes-thin.md`. That directory doesn't exist yet, so there's nothing to resume.

**3. Write `timeline.md`**:
```markdown
Source TZ: UTC (+00:00), per export header "2026-11-20 (UTC)"

| Time (UTC) | Event | Source |
|---|---|---|
| 09:10 | Index rebuild job starts (reported at 09:17) | 09:17 |
| 09:15 | Alert: search-api p95 latency > 4s | 09:15 |
| 09:17 | Engineer identifies the rebuild job as putting heavy load on the DB | 09:17 |
| 09:31 | Rebuild paused; latency starts recovering | 09:31 |
| 09:40 | Engineer reports latency back to normal | 09:40 |
```

**4. Write `facts.md`**:
```markdown
## Impact
- Duration: 25m from alert to normal (09:15→09:40). If impact began when the job started, 30m (09:10→09:40). [09:15, 09:17, 09:40]
- Time to detect: 5m (09:10→09:15) [09:17, 09:15]
- Time to mitigate: 16m (09:15→09:31) [09:15, 09:31]
- Latency: p95 > 4s; peak unknown, need a metrics dashboard [09:15]
- Users/requests affected: Unknown, need search-api request/error metrics
- Error rate: Unknown, need search-api metrics
- SLO budget burned: Unknown, need the SLO dashboard
- Revenue: Unknown, need the business owner

## Cause (stated in the notes)
- The index rebuild job loaded the DB that search-api depends on [09:17]
- Why the job ran then, and why nothing limited its load: not in the notes

## Contributing factors
- None stated

## What went well
- The alert fired 5m after the job started [09:15]
- The cause was identified 2m after the alert [09:17]
- Pausing the job was enough to mitigate [09:31]

## Actions
- None in the notes
```

**5. STOP gate.** I'd ask the gap questions (the reply below) and wait. I would not write `postmortem.md` or the action items yet. Pending your answers, my working root-cause hypothesis is "the index rebuild runs against the production DB with no load isolation or throttling." It's an inference, not a fact from the notes, so I'd confirm it with you.

## Reply to the user

Notes saved, plus a UTC timeline and the facts I could extract, in `.claude-skills-work/incident-postmortem/2026-11-20-search-api-latency-index-rebuild/`. The notes cover the sequence (rebuild at 09:10, alert at 09:15, paused at 09:31, normal by 09:40) but not enough for the rest. Before I write the postmortem:

1. **Impact start:** did user impact begin at 09:10 (job start) or 09:15 (alert)? That makes the duration 30m or 25m.
2. **Impact figures:** how many search requests or users were affected? What was the error or timeout rate and the peak p95? How much SLO budget was burned? Any revenue impact?
3. **Severity:** what severity was the incident?
4. **Root cause:** why did the rebuild hit the production DB this hard? For example: no throttling or resource limits, the job running against the primary instead of a replica, a schedule during peak hours, or a change to the job or the data size. Was the 09:10 start scheduled or manual?
5. **Contributing factors:** anything that slowed detection or recovery, such as no alert on DB load or an unclear runbook for pausing the job?
6. **Follow-up:** was the rebuild resumed or rescheduled later?
7. **Action items:** any agreed already, with owners and due dates? Otherwise I'll propose items marked `TBD — assign`.

If you'd rather I write it now, say "just write it". Every gap above will then be marked `Unknown` or `TBD`, and the same list will appear under Open questions.