**What I'd do:** load the `skill-creator` skill, then ask questions before writing anything. "Productivity" could mean many different skills, and the name, trigger description, steps and evals all depend on which one. I would not create any files, run commands or spawn subagents yet.

**Reply to the user:**

> "Productivity" covers a lot. A few questions so I build the right skill:
>
> 1. **What task should it handle?** Some examples:
>    - Daily planning or triage: turn a brain-dump or an inbox into a prioritized plan for today.
>    - Weekly review: summarize the week's git commits, PRs and notes into what got done, what's stuck and what's next.
>    - Meeting notes: turn raw notes or a transcript into decisions, action items and owners.
>    - Focus or time-blocking: build a calendar-style schedule from tasks and their estimates.
>    - Something else you keep asking Claude to do the same way each time.
> 2. **When should it trigger?** Give a phrase or two you'd actually type, like "plan my day" or "weekly review."
> 3. **Inputs and outputs:** where does the data come from (pasted text, files, git, a TODO.md, a calendar export), and what should the result be (a chat reply, a markdown file, or edits to an existing file)?
> 4. **Your conventions:** any format, prioritization method (Eisenhower, MoSCoW, time estimates) or tools it must use or avoid?
> 5. **Scope:** just for you in this repo (`.claude/skills/`) or published as a plugin in the marketplace?
>
> If you'd rather I pick, I'd suggest **`daily-plan`**. It takes a brain-dump plus any open TODOs, sorts them by urgency and impact, caps the day at what's realistic, and writes `plans/YYYY-MM-DD.md` with the top 3 tasks, a time-blocked schedule and a "not today" list. Once you confirm or redirect, I'll draft `SKILL.md`, add 3–5 eval cases with realistic prompts, and run them with and without the skill so you can compare the outputs.