**Actions, in order:**

1. TodoWrite: 5 items, one per stage. Stage 1 (Clarify intent) is in progress and the rest are pending.
2. Write `./.claude-skills-work/productivity/plan.md` as a placeholder. I'll rename it once there's a real skill name:
   ```markdown
   # plan: <productivity skill — name TBD>
   Stage: 1 (clarify intent) — ⛔ STOP GATE, waiting for the user
   Trigger: UNKNOWN (brief: "a skill for productivity")
   Scope DOES / does NOT: UNKNOWN
   Success criteria: UNKNOWN
   Open questions: see the reply to the user
   Resume: answer the questions, fill in the three fields, get approval, then go to Stage 2
   ```
3. Stop here. I won't read the references, draft frontmatter, scaffold or write evals until Stage 1 is approved.

**Reply to the user:**

"Productivity" is too broad for me to start drafting. I'd be guessing what the skill should do, and a vague skill won't get picked up at the right moments. A skill is also only worth its tokens if it gives Claude a set process it wouldn't follow anyway. Re-explaining general productivity advice doesn't help. Please answer these:

1. **The task:** What exactly should Claude do? For example: break a goal into a daily plan, triage a todo list or inbox, run a weekly review, write standup notes from git activity, or timebox a work session.
2. **The trigger:** What would you actually type when you want it? Give me one or two real example requests.
3. **The input and output:** What does it read (a todo file, git log, calendar export, notes) and what does it write (a file, a checklist, a message)? Where should the output go?
4. **Out of scope:** What should it never do? For example: edit tasks without asking, connect to external apps, or give general coaching.
5. **Success:** How would you check that a run went well?

Once I have your answers, I'll write the trigger, scope and success criteria into `plan.md` for you to approve before I draft anything. Progress is saved in `./.claude-skills-work/productivity/plan.md`.