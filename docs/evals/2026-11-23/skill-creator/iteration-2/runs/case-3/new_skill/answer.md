"Productivity" is too broad to turn into a skill yet, so I haven't drafted anything. The skill-creator process has a stop gate here: it pins down when the skill triggers, what it covers and how we'll know it works before anything gets written.

**What I'd do, in order:**

1. **TodoWrite**, one item per stage: Clarify intent · Frontmatter · Body · Scaffold + evals · Hand off. Mark Stage 1 in progress.
2. **Write** `./.claude-skills-work/productivity/plan.md`. "productivity" is a placeholder; I'll rename it once we pick a name.
   ```markdown
   # Skill plan: <name TBD> (working dir: productivity)
   Status: Stage 1 — clarify intent (BLOCKED: awaiting user answers)

   ## Trigger (use when…)
   TBD: brief "a skill for productivity" is too broad to state a concrete trigger.

   ## Scope
   DOES: TBD
   Does NOT: TBD

   ## Success criteria (observable)
   TBD

   ## Open questions
   1. Which task or workflow?
   2. What triggers it?
   3. Inputs / outputs?
   4. Out of scope?
   5. Constraints (tools, files, conventions)?

   Next: get answers → fill in trigger/scope/criteria → user approval → Stage 2
   ```
3. **Ask you the questions below**, then stop. I won't read the references, draft frontmatter or run `scripts/new_skill.sh` until you approve the plan.

**My reply to you:**

> "Productivity" covers too much for me to write a clear rule for when the skill should kick in. I'd have to guess, and the guess would probably be wrong. I need a few answers first (saved in `./.claude-skills-work/productivity/plan.md`):
>
> 1. **Which task?** What do you do over and over that this should handle? For example: turning a messy TODO list into a daily plan, writing standup or weekly-status notes from git activity, sorting a notes/inbox folder, or splitting a big ticket into subtasks.
> 2. **When should it kick in?** What would you actually type when you want it? A rough example prompt is enough.
> 3. **Inputs and outputs:** what does it read (git log, a markdown file, issues) and what should it produce (a file, a message, edits)?
> 4. **What's off limits?** For example: it never sends messages, edits calendars or closes issues.
> 5. **How will we know it works?** What would a good result look like for one real example?
>
> Once you answer, I'll write up when it triggers, what it covers and how we'll judge it for your approval. Then I'll draft the description, the skill body and 3–5 test cases.