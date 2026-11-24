---
name: incident-postmortem
description: Turns pasted incident notes (chat exports, Slack/Teams threads, on-call logs with timestamps) into a blameless postmortem with summary, quantified impact, UTC timeline, root cause and contributing factors, and owned, dated action items. Use when the user pastes incident notes or a chat export and asks for a postmortem, post-incident review, incident review, RCA write-up or incident report, even if they don't say "postmortem".
---

# Incident Postmortem

Turn raw incident notes into a blameless postmortem that a reader who was not in
the channel can trust. The notes are the only source of truth: a postmortem with
invented numbers or guessed times is worse than one with marked gaps, because
people act on it.

## Scope

- **Does:** parse the pasted notes, normalize times to UTC, extract impact
  figures, reconstruct the timeline, identify root cause and contributing
  factors, write action items with owner and due date, write the doc to disk.
- **Does NOT:** query monitoring, logs or tickets; invent metrics, owners or
  dates; assign blame to people; fix the bug; publish or send the doc anywhere.

## Checklist (add each as a TodoWrite item)

1. Save the notes to `./.claude-skills-work/incident-postmortem/<slug>/notes.md`
   (slug = date + short name, e.g. `2026-11-20-checkout-5xx`). If that dir
   already exists, resume from the last file written instead of starting over.
2. Build the UTC timeline → `timeline.md`.
3. Extract facts: impact numbers, root cause, contributing factors, action-item
   candidates → `facts.md`. Each fact cites the note line/timestamp it came from.
4. Write `postmortem.md` from the template below.
5. Run the self-check, then reply with the file path and the open-gaps list.

## Step 2: Timeline in UTC

- Find each timestamp's zone: explicit offset/zone in the line, export header,
  or a statement like "all times PT". Convert to `YYYY-MM-DD HH:MM UTC`.
- Respect DST for named zones (PT in November is UTC-8, in July UTC-7).
- If the zone is unknown, do not guess silently: pick the most plausible zone,
  write it in an **Assumptions** line at the top of the timeline, and list it
  as an open gap.
- Keep events that matter: first signal, detection/alert, declaration,
  key diagnosis steps, mitigation attempts (incl. failed ones), mitigation,
  resolution, all-clear. Drop chatter.
- Compute durations from UTC times: time to detect, time to mitigate, total.

## Step 3: Facts

- **Impact:** only numbers stated in the notes (error rate, requests/users/
  orders affected, revenue, duration, SLO budget burned). Derived numbers are
  fine if you show the arithmetic. Missing number → `Unknown — <what to
  measure>` and an open gap. Never round "a lot" into a figure.
- **Root cause:** the system condition that, if absent, prevents the incident.
  Ask "why" until you reach a process/system gap, not a person's action.
- **Contributing factors:** things that made it worse or slower (missing alert,
  no canary, unclear runbook, alert fatigue).
- **Action items:** each must map to the root cause or a contributing factor.
  Owner and due date come from the notes. If absent, write `Owner: TBD` /
  `Due: TBD` and list them as open gaps — do not pick a person or date.

## Blameless language

Describe what systems and processes allowed, not who erred. Use roles, not
names, in cause analysis ("a config change was deployed without validation",
not "Dave pushed a bad config"). Names may appear only as action-item owners
and in the timeline as actors when neutral ("on-call engineer acknowledged").
Rewrite blaming quotes from the notes; do not reproduce them.

## postmortem.md template

```markdown
# Postmortem: <title> (<YYYY-MM-DD>)
Status: Draft · Severity: <from notes or Unknown> · Authors: <TBD>

## Summary
<3–5 sentences: what broke, for whom, how long, how it was fixed.>

## Impact
- Duration: <start–end UTC, total>
- <metric>: <number> (source: <timestamp>)

## Timeline (UTC)
Assumptions: <zone assumptions or "none">
| Time (UTC) | Event |

## Root cause
## Contributing factors
## What went well
## Action items
| # | Action | Type (prevent/detect/mitigate) | Owner | Due |

## Open gaps
<every Unknown / TBD / assumption, with who could fill it>
```

## Self-check before replying

- Every number in Impact appears in `facts.md` with a source.
- Every timeline time ends in `UTC`; durations match the timeline.
- Every action item has an Owner and Due (value or `TBD`) and maps to a cause.
- No person is named as a cause; no blaming quotes.
- Open gaps lists every `Unknown`, `TBD` and assumption.

## Red flags → correction

| You notice yourself… | Do instead |
|---|---|
| Filling in a plausible metric or date | Write `Unknown`/`TBD`, add to Open gaps |
| Copying local times as-is | Convert to UTC, state the zone assumption |
| "X made a mistake" | Name the missing guardrail |
| Action items like "be more careful" | Make it a concrete system/process change |
| Investigating the codebase or proposing a fix | Stop: out of scope; add an action item |
| Notes too thin to identify a root cause | Write "Root cause: undetermined", list what's needed, ask the user |
