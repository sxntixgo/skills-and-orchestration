**What I'd do:** Nothing on disk yet. "Productivity" is too broad to write a useful skill: the description wouldn't trigger reliably and the body would end up as generic advice. No commands, files or subagents at this point. I'd reply with the message below and wait for the answer.

**Reply to the user:**

> "Productivity" could mean a lot of things. Before I write it, which of these is closest?
>
> 1. **Daily planning**: turns a brain-dump into a prioritized plan for today, with time blocks and a top 3.
> 2. **Task capture and triage**: pulls TODOs out of notes, code comments or meeting transcripts into one list, tagged by urgency and effort.
> 3. **Weekly review**: summarizes what got done (git log, closed issues, notes), what slipped and what's next.
> 4. **Focus sessions**: breaks one big task into 25–50 min chunks, tracks progress and checks in between chunks.
> 5. **Something else**: describe a recurring chore you'd like Claude to handle the same way every time.
>
> I also need to know:
> - **Where your tasks live**: plain markdown files (which path?), GitHub issues, or something else?
> - **What should trigger it**: a phrase like "plan my day", or a slash command?
> - **Scope**: personal (`~/.claude/skills/`) or inside a project/plugin repo?
>
> If you'd rather not decide, I'll default to **#1 Daily planning**: a personal skill that reads and writes `~/notes/today.md`, triggered by "plan my day" or "what should I work on". After you confirm, I'll write `SKILL.md` and 3–4 eval cases.