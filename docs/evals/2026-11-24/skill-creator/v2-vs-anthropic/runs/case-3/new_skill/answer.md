**What I'd do**

1. Read the repo's `CLAUDE.md` and one sibling skill (e.g. `skills/brainstorming/SKILL.md`) together, to learn the house style.
2. Stop before drafting. "A skill for productivity" doesn't name a task or say when the skill should run, so a draft would mean making up your requirements. I'd write no files, run no commands and start no subagents.
3. Ask you one question:

---

"Productivity" could mean several different skills. Which of these fits, or what did you have in mind?

1. **`daily-plan`**: turns a messy to-do list or your notes into a ranked plan for today, with the top 3 tasks, time blocks and what to defer. *Use when you say "plan my day" or "prioritize these tasks."*
2. **`meeting-notes`**: turns raw meeting notes or a transcript into decisions, action items (owner and due date) and open questions, saved to a file. *Use when you say "summarize this meeting" or "extract action items."*
3. **`weekly-review`**: reads your git log and task file for the week, then writes what got done, what slipped and next week's priorities. *Use when you say "weekly review" or "what did I do this week."*

Once you pick one, I'll draft the `SKILL.md` and its evals, check them with the validation script, and hand the skill to `skill-reviewer` for measurement.