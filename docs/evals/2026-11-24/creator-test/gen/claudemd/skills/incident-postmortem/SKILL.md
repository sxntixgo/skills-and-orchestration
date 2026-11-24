---
name: incident-postmortem
description: Turns pasted incident notes (chat exports with timestamps) into a blameless postmortem with summary, quantified impact, UTC timeline, root cause and contributing factors, and owned, dated action items. Use when the user pastes incident notes, chat logs or a Slack/Teams export and asks for a postmortem, post-incident review, incident review or RCA write-up.
---

# Incident postmortem

Turn raw incident notes into a blameless postmortem. Every fact traces back to the notes.

**Does:** extract facts from the notes, normalize times to UTC, write the postmortem below.
**Does NOT:** investigate systems, run commands, invent numbers/owners/dates, assign blame,
or fix the incident. If the user wants any of those, stop and ask.

## Checklist (create as TodoWrite items)

1. Save input → `./.claude-skills-work/incident-postmortem/<slug>/notes.md`
2. Resolve timezone → write the source TZ + offset at the top of `timeline.md`
3. Build UTC timeline → `timeline.md`
4. Extract impact, cause, factors, actions → `facts.md` (each line cites a note timestamp)
5. **STOP gate** — list gaps (see below); ask once, or proceed with `TBD` if told to
6. Write `postmortem.md` from the template
7. Blameless + traceability pass; reply with the path and the open gaps

`<slug>` = `YYYY-MM-DD-<short-kebab-title>` (incident start date, UTC).
**Resume:** if the dir exists, read its files and continue at the first missing one.

## Rules

**Timezone.** Use the offset in the timestamps, else one stated in the notes or by the user.
If neither exists, do not guess: ask. If told to proceed anyway, keep the original times,
label the column `Time (TZ unconfirmed)`, and list it as a gap. Show date on every row
when the incident crosses midnight UTC. Sort chronologically.

**Numbers.** Impact needs figures: duration (start→resolved, computed from the timeline),
users/requests/orders affected, error rate, revenue, SLO budget burned. Use only figures in
the notes; derived figures show their arithmetic. Missing figure → `Unknown — need <source>`.
Never write "some", "many", "significant" in place of a number.

**Blameless.** Describe actions and system conditions, not people's failings. Refer to
roles ("the on-call engineer", "the deployer"), not names, in the narrative and cause.
Rewrite blame from the notes: "Dave broke prod with a bad config" → "A config change
with an invalid value was deployed; no validation rejected it." Root cause is a system
or process gap, never "human error".

**Root cause vs contributing factors.** One root cause (answer "why was this possible?" until
you reach a fixable system/process gap). Contributing factors = things that widened impact
or slowed detection/recovery (missing alert, slow rollback, unclear runbook).

**Action items.** Each: action (specific, verifiable), type (prevent/detect/mitigate),
owner, due date (ISO `YYYY-MM-DD`), linked cause/factor. Owners and dates only from the
notes or user; otherwise `TBD — assign`. Resolve relative dates ("end of next week")
against the message date and show the original phrase, e.g. `2026-11-13 ("end of next week")`. Every root cause and factor gets ≥1 item.
Owners here are names/teams — accountability for follow-up is not blame.

## Gaps (STOP gate)

Collect: unknown timezone, missing impact numbers, missing owners/due dates, unclear
resolution time, conflicting statements. Ask in one numbered list. If the user already
said "don't ask" / "just write it", proceed with `TBD`/`Unknown` markers and list the gaps
at the end instead.

## Template (`postmortem.md`)

```markdown
# Postmortem: <title>
Status: Draft · Date: <YYYY-MM-DD> · Severity: <from notes or TBD>

## Summary
<2–4 sentences: what broke, for whom, how long, how it was fixed.>

## Impact
| Metric | Value | Source |
|---|---|---|
| Duration | 1h 12m (14:03–15:15 UTC) | timeline |

## Timeline (UTC)
| Time (UTC) | Event |
|---|---|

## Root cause
## Contributing factors
## What went well
## Action items
| # | Action | Type | Owner | Due | Addresses |
|---|---|---|---|---|---|

## Open questions
```

## Red flags → correction

| Red flag | Correction |
|---|---|
| Inventing an owner, date or figure to fill the table | `TBD — assign` / `Unknown — need X` |
| Converting times with a guessed offset | Ask, or keep original + mark unconfirmed |
| A name or "human error" in root cause | Rewrite as the system/process gap |
| Vague action ("be more careful", "improve monitoring") | Make it specific and checkable |
| Adding fixes/investigation not in scope | Put ideas under Open questions; stop |
| Holding everything in context, no files | Write each step's file before the next |
