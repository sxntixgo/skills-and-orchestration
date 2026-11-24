What I'd do, in order:

1. **Invoke `skill-authoring:skill-creator`.** CLAUDE.md requires it whenever a skill is created or edited.
2. **Add the skill-creator checklist as TodoWrite items:** intake, scope, draft SKILL.md, evals, baseline comparison, review. Mark **intake** as in progress.
3. **Write the intake checkpoint** to `./.claude-skills-work/skill-creator/01-intake.md`:
   ```markdown
   # Intake: new skill
   Raw request: "Make me a skill for productivity."
   Status: BLOCKED. Waiting on the user.

   ## Why blocked
   - "Productivity" doesn't give a concrete trigger, so the `description` can't be written.
   - Repo rule: a skill earns its token cost by encoding a process the model doesn't
     already follow, not by restating general advice. "Be productive" tips
     would likely measure about 0 lift (see the security-review history).

   ## Open questions
   1. Which recurring task, specifically?
   2. What does the user say or do when it should trigger?
   3. What output or artifact should it produce, and where?
   4. Which plugin: frugal-skills or skill-authoring?

   ## Resume
   Answer the questions above, then continue at step 02-scope.
   ```
4. **Stop at the intake gate.** I wouldn't create any skill directory, SKILL.md or evals yet. I'd also avoid guessing a scope: that would mean inventing requirements, which is on the red-flags list.

**Final reply to the user:**

> "Productivity" is too broad for me to write a skill that triggers reliably or does better than having no skill. Can you narrow it down?
>
> 1. **Which task do you repeat?** For example: a daily standup summary from git log and open PRs, triaging a TODO/issue backlog into a prioritized plan, writing a weekly review, or breaking a vague task into time-boxed steps.
> 2. **When should it trigger?** Give a phrase you'd actually type, like "plan my day" or "triage my issues".
> 3. **What should it produce, and where?** For example, a markdown file in `notes/`, or a reply in chat.
> 4. **Which plugin should it go in?** `frugal-skills` by default.
>
> Once you answer, I'll draft the SKILL.md and evals, then run the with-skill vs. without-skill comparison. My progress so far is saved in `.claude-skills-work/skill-creator/01-intake.md`.