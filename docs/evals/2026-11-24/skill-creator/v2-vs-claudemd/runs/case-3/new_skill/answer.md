I didn't draft anything: "a skill for productivity" doesn't say what task the skill does or when it should load. The skill-creator rules say to ask one question in that case.

**What I'd do, in order:**

1. Read three files together in one batch: the repo `CLAUDE.md`, one existing skill (`skills/brainstorming/SKILL.md`) to match the house style, and `plugins/skill-authoring/skills/skill-creator/SKILL.md`. I'd skip any target files because this is a new skill.
2. Stop before drafting. I'd write no files, run no `check_skill.py` and launch no subagents, and reply with one question.

**Reply to the user:**

> "Productivity" could mean a few different skills. Which of these is closest?
>
> 1. **`daily-plan`**: turns a brain-dump of tasks into a ranked plan for today, with time estimates and the top 3 tasks. The skill loads when you type something like "plan my day" or "what should I work on today".
> 2. **`meeting-notes-to-actions`**: pulls decisions, action items, owners and due dates out of raw meeting notes. The skill loads when you type something like "summarize these notes" or "extract action items".
> 3. **`weekly-review`**: compares what you planned for the week with what you got done (from git log, notes or a todo file) and writes a short report on what slipped and why, plus next week's priorities. The skill loads when you type something like "weekly review" or "what did I get done this week".
>
> Pick one, or tell me the task you want help with and how you'd ask for it. I'll draft the skill and its evals straight away.