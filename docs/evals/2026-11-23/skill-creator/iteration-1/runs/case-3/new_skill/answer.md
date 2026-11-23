I've stopped at Stage 1 before drafting anything. "Productivity" is too broad to define a skill around, and the skill-creator rules say to ask rather than make up requirements.

**What I'd do, in order:**

1. **TodoWrite**, one item per stage:
   - Stage 1 — Clarify intent (⛔ gate). Marked in progress.
   - Stage 2 — Frontmatter
   - Stage 3 — Body
   - Stage 4 — Scaffold + evals
   - Stage 5 — Hand off to skill-reviewer

2. **Write `./.claude-skills-work/productivity-tbd/plan.md`** so the work can resume if interrupted. `productivity-tbd` is a placeholder name until the scope is clear:
   ```markdown
   # Skill plan: productivity-tbd (name pending)
   Status: Stage 1 — awaiting user input (STOP GATE)

   ## Brief
   "Make me a skill for productivity." Too vague to define trigger/scope.

   ## Trigger
   OPEN — need the concrete situation where this fires.

   ## Scope
   DOES: OPEN
   DOES NOT: publish/install anything; (rest OPEN)

   ## Success criteria
   OPEN

   ## Questions sent to user
   1. Situation / trigger
   2. Concrete output
   3. Inputs/tools available
   4. Out of scope
   5. What "worked" looks like
   ```

3. **Commands:** none. I wouldn't run `scripts/new_skill.sh` or load the `references/*.md` files yet, because those belong to Stages 2–4.

4. **Reply to the user:**

> I need a few answers before I draft anything. "Productivity" could mean many different skills, and I don't want to guess what you need. I've saved a draft plan to `./.claude-skills-work/productivity-tbd/plan.md`.
>
> 1. **When should it fire?** What exactly are you doing, or what would you type, when you'd want it? For example: "plan my day from my TODO file," "summarize what I changed this week for a standup," "split a big task into steps," "triage my GitHub notifications."
> 2. **What should it produce?** A file (which format, and where it goes), a message in chat, edits to an existing file, or commands it runs?
> 3. **What does it work from?** A TODO.md or notes file, git history, GitHub issues, a calendar export? Are there tools it should or shouldn't use?
> 4. **What should it NOT do?** For example: never edit files without asking, never push, don't handle scheduling.
> 5. **How would you know it worked?** Describe one or two results you'd be happy with.
>
> Answer whichever you can and I'll write up the trigger, scope and success criteria for your approval. Once you approve, I'll draft the name and description.