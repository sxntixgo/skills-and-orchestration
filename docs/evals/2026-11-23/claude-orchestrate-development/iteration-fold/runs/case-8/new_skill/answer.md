I won't dispatch this task by itself. A one-line constant isn't worth an opencode run, because its spec would be as long as the code. The skill says to fold a task like this into a neighbouring task, usually the one that first uses `MAX_ROWS`.

What I'd do, in order:

1. **Plan gate (step 0):** look for the plan in `docs/plans/*-plan.md` and in any `.orchestra/*/board.md`. You didn't name a file, so I'm treating it as **not found**. I won't make up the surrounding tasks or which code uses `MAX_ROWS`.
2. **Nothing else for now:** no `.orchestra/` run, `board.md`, spec subagent or `claude-dispatch` call until I have the plan.

Reply:

> The `MAX_ROWS = 500` task is too small to send to opencode alone: its spec would be as long as the one-line change. I'll fold it into the task that first uses `MAX_ROWS` (e.g. the pagination or export task), and that task's spec and tests will cover it.
>
> I couldn't find the plan you mean. Which file is it (e.g. `docs/plans/<name>-plan.md`)? Once I have it, I'll set up the run, merge this constant into the right task and dispatch.
>
> If it really is a single standalone edit, it's quicker for me to make it directly on a branch than to orchestrate it. Say so and I'll do that.