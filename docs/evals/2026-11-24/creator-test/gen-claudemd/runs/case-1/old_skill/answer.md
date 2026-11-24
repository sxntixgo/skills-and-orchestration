I wrote the `incident-postmortem` skill and its evals to disk. The evals JSON parses, but I haven't run the with-skill vs. without-skill comparison yet, so I can't say whether the skill actually helps.

**Files** (in `skills/incident-postmortem/`):
- `SKILL.md` (about 100 lines):
  - **Trigger:** it fires when you paste incident notes or a chat export and ask for a postmortem, incident review or RCA (root-cause write-up).
  - **Sections:** summary, impact with numbers, UTC timeline, root cause and contributing factors, what went well, action items, open questions.
  - **Checklist and saved progress:** each step writes `notes.md`, then `timeline.md`, `facts.md` and `postmortem.md` to `./.claude-skills-work/incident-postmortem/<YYYY-MM-DD-slug>/`. A later session can pick up from the first missing file.
  - **Main rules:**
    - It never guesses a timezone. With no timezone, it asks or marks the times as unconfirmed.
    - It never invents impact numbers, owners or due dates. Missing ones show as `Unknown — need X` or `TBD — assign`.
    - Relative due dates like "end of next week" become an ISO date, with your original wording kept next to it.
    - The writing is blameless: it refers to roles, not names, and the root cause is never "human error".
    - Every root cause and contributing factor gets at least one action item.
  - **Missing information:** it asks once, as a single numbered list. If you've said "don't ask", it writes the draft anyway and lists the gaps at the end.
- `evals/evals.json` has 4 cases:
  1. A checkout outage with times in `-08:00`. It checks the UTC conversion, the revenue math (1,840 × $52), the blameless rewrite, and that missing owners are marked TBD rather than invented.
  2. Notes with no timezone that cross midnight. The skill should ask, not guess.
  3. A cert-expiry incident pasted inline, which should produce a complete postmortem.
  4. A Slack thread about lunch, where the skill should not fire.
- `evals/files/checkout-outage.txt` and `evals/files/search-degradation-no-tz.txt` are the input notes for cases 1 and 2.

**Not done:**
- I didn't use the `skill-creator` and `skill-reviewer` skills because they aren't available in this session. I followed the `CLAUDE.md` conventions by hand instead.
- I didn't update `plan.md` or the README's skill list.

To finish the work as the repo requires, run `skill-authoring:skill-reviewer` on the skill (start the session with `claude --plugin-dir .`). That also runs the evals comparison.