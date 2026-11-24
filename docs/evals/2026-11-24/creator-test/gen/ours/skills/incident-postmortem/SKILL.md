---
name: incident-postmortem
description: Turns pasted incident notes (chat exports with timestamps) into a blameless postmortem with summary, quantified impact, UTC timeline, root cause and contributing factors, and action items that each have an owner and due date. Use when the user pastes incident notes, a Slack/chat export or an outage log and asks for a postmortem, incident review, RCA or post-incident report.
---
# Incident Postmortem

Notes in, blameless postmortem out. Every fact traces to a line in the notes; gaps are marked, never filled.

## Scope
DOES: build the postmortem from the notes the user pasted or named. Does NOT: invent numbers,
owners, dates or causes; assign blame; contact people or post the doc anywhere.

## Steps (TodoWrite items; output in `./.claude-skills-work/incident-postmortem/`)
1. **Check input.** No notes pasted/named, or no timestamps at all → ⛔ ask for the export; stop.
2. **Fix the clock.** Find the source timezone (header, `PST`, `+02:00`, user's words). Convert
   every time to `YYYY-MM-DD HH:MM UTC`; roll the date when crossing midnight. Mixed or unknown
   zone → state the assumption in the doc's header and in your reply. Write `timeline.md`.
3. **Mark milestones** in the timeline: start, detected, mitigated, resolved. Compute
   time-to-detect, time-to-mitigate, total duration (show the subtraction).
4. **Impact:** only numbers in the notes (users, requests, error %, revenue, SLO minutes), each
   with its timeline time. Missing → `UNKNOWN (ask: <who/what dashboard>)`.
5. **Cause:** trigger ≠ root cause. Ask "why" until you reach a system/process gap, not a person.
   List contributing factors (detection, tooling, docs, alerting) separately.
6. **Action items:** one per root cause/contributing factor, as a table. Owner and due date only
   if the notes state them; otherwise `TBD` and add to Open questions. Each item is verifiable.
7. Write `postmortem.md` (format below); reply with path, the 3 durations, and Open questions.

## Blameless rewrite
Name roles/systems, not people, in narrative and cause ("the on-call engineer ran the migration",
not "Dave broke prod"). Drop blame words (careless, should have, mistake by). Names stay only
as action-item owners. User asks who is at fault → decline that part, explain the system gap.

## Output format (`postmortem.md`)
```
# Postmortem: <title> (<date> UTC) — Status: Draft
Timezone source: <...>
## Summary            (3–5 sentences)
## Impact             (bullets, each number cited with time)
## Timeline (UTC)     | Time UTC | Event | Milestone |
## Durations          TTD, TTM, total
## Root cause
## Contributing factors
## Action items       | # | Action | Addresses | Owner | Due |
## Open questions
```

## Red flags
| If you notice… | Do this |
|---|---|
| A number, owner or date not in the notes | Replace with `UNKNOWN`/`TBD` + Open question |
| Local times left in the timeline | Convert all to UTC |
| A person's name in Summary/Root cause | Rewrite to role or system |
| Root cause = "human error" | Ask why again; find the missing guardrail |
| Action like "be more careful" | Replace with a concrete, checkable change |

## Done when
`postmortem.md` has all sections, every time in UTC, every action has Owner and Due (value or
`TBD`), and the reply lists Open questions.
