I won't send this task to opencode on its own. A one-line constant isn't worth a spec: writing the task file would take longer than the change itself. The skill says to merge a task like this into a neighbouring task.

**What I'd do, in order:**

1. **Plan gate (step 0).** You didn't give the plan's path, so I'd look in `docs/plans/*-plan.md`. In this dry run I treat it as not found. That's still fine here: the request fully defines the change, which is the small-change exception to the plan gate.
2. **If a plan is found** (in a real session), I'd fold the constant into the task that first uses `MAX_ROWS`, for example the one that limits query or export results. In `board.md` that task's goal would read "…; add `MAX_ROWS = 500` to `config.py`", and `config.py` would go in its `files` column. Any other task touching `config.py` would get a dependency on it so they don't run at the same time. The combined task then goes through the usual steps: spec subagent (`claude-write-task`), `claude-dispatch` to opencode, then a review subagent (`claude-review-merge`). I'd add one Log line: `<time> folded "add MAX_ROWS" into T<n> (constant not worth its own spec)`.
3. **If no plan exists, or no task uses the constant:** I wouldn't set up an orchestration run for one line. With no task using it, a lone constant has no tested or visible effect, so I'd ask whether it's still wanted. If you confirm, I'd add `MAX_ROWS = 500` to `config.py` on `main`, run the repo's test command and commit `config: add MAX_ROWS = 500`. No worktree, no opencode, no push.

**Reply to you:**

> I didn't dispatch this alone. The spec for a one-line constant would be longer than the code. If your plan has a task that uses `MAX_ROWS`, I'll fold the constant into that task and send it to opencode together. Which plan file should I use? If nothing uses it yet, I can add the line to `config.py` and commit it on `main`.