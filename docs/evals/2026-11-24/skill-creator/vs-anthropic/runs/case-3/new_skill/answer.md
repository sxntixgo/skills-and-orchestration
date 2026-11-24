**What I'd do, in order:**

1. **TodoWrite**, one item per stage: Clarify intent (⛔ gate) · Frontmatter · Body · Scaffold + evals · Hand off. Stage 1 is in progress.
2. **Not read the references yet.** They're batch-read when drafting starts, and drafting is blocked until Stage 1 is approved.
3. **Write `./.claude-skills-work/productivity/plan.md`.** "productivity" is a placeholder name until the scope is set.
   ```markdown
   # Skill plan: <name TBD> (working dir: productivity)
   Status: Stage 1 (clarify intent): BLOCKED, waiting on the user

   Brief: "Make me a skill for productivity." Too vague to draft.

   ## Trigger (the "Use when…" line)
   TBD. Need the concrete situation in which Claude should load this skill.

   ## Scope
   DOES: TBD
   Does NOT: TBD

   ## Success criteria (observable)
   TBD

   ## Open questions sent to the user
   1. Which productivity task?
   2. What request triggers it?
   3. What should it produce, and where?
   4. What does Claude currently get wrong here?
   5. Out of scope?

   Resume: once the user answers, fill in the sections above, get approval, then go to Stage 2.
   ```
4. **Stop and reply.** No frontmatter, body, scaffold or evals until you approve the plan.

**Reply to the user:**

"Productivity" is too broad to write a good skill for yet. The description needs a concrete trigger so Claude loads the skill at the right time. I've saved a draft plan at `./.claude-skills-work/productivity/plan.md`. Please answer these:

1. **Which task?** For example: triaging a TODO list or inbox, planning your day or week, writing a standup or status update, breaking a big task into steps, running a weekly review, or cleaning up meeting notes.
2. **Trigger:** what would you typically type when you want it? Paste a real example if you have one.
3. **Output:** what should it produce, and where? For example: a markdown file in a set location, an updated `TODO.md`, or a message in chat.
4. **Why a skill?** What does Claude get wrong or skip today on this task? Skills here only pay off when they add a process Claude doesn't already follow. Restating general productivity advice doesn't help.
5. **Out of scope:** anything it should *not* do, such as touching calendars, sending messages or changing files outside a set folder.

Once you approve the trigger, scope and success criteria, I'll draft the frontmatter, then the body, then scaffold 3–5 evals, and hand it off to `skill-reviewer`.