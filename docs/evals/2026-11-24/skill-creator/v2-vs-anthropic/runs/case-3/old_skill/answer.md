**What I'd do:** I'd add todos, write no files yet, and ask the user what they want. "Productivity" is too broad to draft from. The skill-creator says to capture intent and interview before drafting. The repo's CLAUDE.md adds a second reason to ask first: a skill only earns its token cost if it encodes a process the model doesn't already follow. A generic "be productive" skill would add nothing.

**TodoWrite items:**
1. Capture intent: what the skill does, its trigger, output format, whether to test it ← in progress
2. Interview: edge cases, inputs, success criteria
3. Draft `skills/<name>/SKILL.md` (frontmatter `name` matches the directory name, description says "what it does. Use when…", scope, checklist, STOP gates, red flags, checkpoint files)
4. Write `evals/evals.json` with 2–3 realistic prompts and confirm them with the user
5. Run each eval with the skill and without it, all in the same turn, into `<name>-workspace/iteration-1/`
6. Draft assertions while the runs are going; save `timing.json` as each run finishes
7. Grade the runs, then `python -m scripts.aggregate_benchmark`, then an analyst pass, then `eval-viewer/generate_review.py`
8. Iterate on the user's feedback
9. Optimize the description, if the user wants
10. Run skill-reviewer and update `plan.md`

**Reply to the user:**

> I can build this, but "productivity" covers a lot. A skill only helps if it gives Claude a repeatable process it wouldn't follow on its own, so I need to narrow it down first. Some directions it could go:
>
> - **Daily planning:** turn a brain-dump of tasks into a prioritized plan for the day, with time estimates and a written `today.md` you can come back to.
> - **Weekly review:** go through what got done, what slipped and why, and set next week's top 3 priorities. Saved to a file so each week builds on the last.
> - **Breaking down a big task:** split a vague goal ("launch the newsletter") into concrete next actions, each finishable in under an hour.
> - **Inbox or meeting triage:** sort a pile of notes or emails into do / delegate / defer / drop, with draft replies.
> - **Something you already do by hand:** if you have a routine you repeat, describe it and I'll turn it into a skill.
>
> To get started, could you tell me:
> 1. Which of these is closest, or what's the actual pain point?
> 2. What would you type when you want it? For example, "plan my day" or "help me with this list."
> 3. What should you end up with: a markdown file, a checklist in the chat, calendar blocks, something else?
> 4. Does it need any of your tools or files, like a todo file, notes folder, or calendar export?
>
> Once I know that, I'll draft the skill and 2–3 test prompts. Then I'll run each prompt with the skill and without it, so you can see whether it actually helps.

I'd stop there and wait for the answers. No files are written and no subagents are spawned until the intent is pinned down.