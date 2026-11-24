"Productivity" could mean a lot of different skills, so I'll ask a few questions before writing anything. I haven't created any files or started any test runs yet.

**My to-do list for this skill:**
1. Find out what the skill should do and when it should be used ← *you are here*
2. Draft `SKILL.md`
3. Write 2–3 realistic test prompts in `evals/evals.json`
4. Run each test with the skill and without it, then show you the results side by side
5. Improve the skill based on your feedback, then fine-tune its description so it gets picked at the right times

**Questions for you:**

1. **What should it help with?** Some examples of what "productivity" could mean:
   - **Daily planning:** turn a messy to-do list into a time-blocked plan for the day.
   - **Weekly review:** go through open tasks, notes and calendar items, then write a short summary and next actions.
   - **Breaking down tasks:** split a vague goal like "launch the newsletter" into concrete next steps.
   - **Meeting notes to action items:** pull out decisions, owners and deadlines from notes.
   - **Something else:** describe what you do by hand today that you'd like Claude to do for you.
2. **When should it be used?** What would you typically type, for example "plan my day" or "here are my notes from standup"?
3. **What should you get back?** A Markdown checklist, a file such as `today.md`, updates to an existing to-do file, or something else?
4. **Should it work with any existing tools or files?** For example a `TODO.md`, an Obsidian vault, a calendar export, or Linear or GitHub issues. If so, what is the file path or format?
5. **Should we test it?** For something like daily planning or extracting action items, I suggest 2–3 test prompts with simple checks (for example "every action item has an owner"). If the result is mostly a matter of taste, we can skip formal tests and just review the results together.

A skill is most useful when it captures *your* way of working: your steps, your format and your rules. A general "be productive" skill mostly repeats things Claude already does without one. The more specific your answer to question 1, the more useful the skill will be.