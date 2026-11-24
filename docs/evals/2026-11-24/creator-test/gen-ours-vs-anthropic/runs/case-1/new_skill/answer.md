I wrote `skills/incident-postmortem/` with a `SKILL.md`, 5 eval cases and 2 input files. The checker passed with no failures or warnings. I haven't run the evals yet.

**Description:** "Turns pasted incident notes (chat exports with timestamps) into a blameless postmortem with summary, quantified impact, UTC timeline, root cause and contributing factors, and action items that each have an owner and due date. Use when the user pastes incident notes, a Slack/chat export or an outage log and asks for a postmortem, incident review, RCA or post-incident report."

`CHECK incident-postmortem fail=0 warn=0 chars=3317 refs=0 cases=5`

**What the skill does differently from a plain request:**
- **Facts:** every fact must come from the notes. A missing number becomes `UNKNOWN`, and a missing owner or due date becomes `TBD`. Each gap is also listed under "Open questions".
- **Timezones:** it finds the timezone the notes were written in, converts every time to UTC and moves the date forward when a time crosses midnight. If the timezone is unclear, it says what it assumed.
- **Durations:** it marks when the incident started, was detected, was mitigated and was resolved, and works out time to detect, time to mitigate and total duration.
- **Blameless rules:** the trigger is kept separate from the root cause. The text names roles and systems rather than people. A person's name appears only as an action-item owner. If you ask who was at fault, it declines that part and still writes the postmortem.
- **Output:** the postmortem is written in a fixed format to `./.claude-skills-work/incident-postmortem/postmortem.md`. It stops and asks if no notes were pasted.

**Eval cases:**
1. `checkout-pst-to-utc`: the alert and resolution times move from PST into 2026-11-04 UTC; time to detect is 12 min and total is 70 min; impact is 4,200 failed checkouts and about $61k; no "Dave" or "careless" in the summary or root cause.
2. `checkout-owners-tbd`: the migration lint keeps the owner and date stated in the notes (dave.kim, 2026-11-14); the alerting and staging items get `TBD` and appear in Open questions.
3. `dns-mixed-timezones`: the CET times are shifted 1 hour back while the phone notes stay in UTC (22:50 and 23:26 UTC on 2026-10-28); impact is `UNKNOWN` with no made-up counts.
4. `stop-no-notes`: it asks for the chat export, writes no postmortem and invents no timeline.
5. `refuse-blame`: it declines to blame Dave; the root cause is the migration that broke older versions plus the missing check against that; the postmortem is still written.

**Assumptions:**
- Output goes to the working folder above rather than a path you choose.
- Names are allowed as action-item owners.
- Due dates are never inferred from the notes; they're only used when stated.

Approve, or what should change? Next step is to run `skill-authoring:skill-reviewer`, which compares results with and without the skill.