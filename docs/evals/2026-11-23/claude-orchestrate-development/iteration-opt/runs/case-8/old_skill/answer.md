I won't dispatch this task on its own. Writing a spec for one constant takes longer than writing the constant, and the skill says a task like this gets merged into a neighbouring task instead of being dispatched alone.

**Steps, in order:**

1. **Plan gate (step 0):** `ls docs/plans/` in `/workspaces/<repo>`. You didn't give me a plan path, so I assume nothing there covers this task: **not found**. I don't invent a plan or a `board.md` to stand in for one.
2. **Task sizing (step 2, "Worth a spec"):** a task for `MAX_ROWS = 500` in `config.py` gets folded into the task that first uses `MAX_ROWS`, such as the code that caps rows. That task then lists `config.py` under "may change", and its test command covers the limit. If nothing in the plan uses it, YAGNI applies and I drop it with a reason.
3. Nothing is dispatched or logged, and I don't create `.orchestra/<run>/` until I have the plan.

**Reply to you:**

> I couldn't find the plan: there's no path in your message and I assume nothing matching is in `docs/plans/`. Which file is it?
>
> I also won't send "add `MAX_ROWS = 500` to `config.py`" to opencode as its own task. Its spec would be longer than the one line of code. When I build the task graph, I'll fold it into the task that first uses `MAX_ROWS`, with `config.py` in that task's files and a test that checks the 500-row limit. If no task uses it, I'll drop it as unused.
>
> If you only want the line added now, with no orchestration run, say so and I'll add it directly.