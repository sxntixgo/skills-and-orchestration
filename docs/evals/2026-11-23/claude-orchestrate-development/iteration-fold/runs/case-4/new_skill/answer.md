Nothing to resume yet: you didn't name the run, so I'd look for it on disk. In this dry run I'm treating its `board.md` as not found, so I'd stop and ask you for the run name rather than guess or rebuild it.

**What I'd do, in order**

1. Look for runs (from the repo root `/workspaces/<repo>`):
   ```bash
   ls -t .orchestra/*/board.md 2>/dev/null
   cat .orchestra/config.json 2>/dev/null
   git worktree list
   git branch --list 'orchestra/*'
   ```
   - **Exactly one `board.md` with open tasks:** resume that run (step 2).
   - **More than one:** ask which run you mean.
   - **None** (my assumption, since you didn't name one): stop. I would not rebuild a board from the worktrees or branches, and I would not re-plan without the plan file.

2. If a run were found, resume it this way:
   - Read only that run's `board.md` and the plan it points to. I wouldn't open source files, diffs or logs in this thread.
   - Check each `dispatched` task:
     - **Finished** (the worktree has a `RESULT.md`): mark it `review`. Then spawn one review subagent at a time on `review_model`, or `opus` if the task is marked `review: opus`. Prompt: "Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `<id>` in repo `/workspaces/<repo>`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` | `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`."
     - **Still running** (process alive, log growing): leave it and wait.
     - **Dead with no `RESULT.md`:** re-dispatch with `claude-dispatch` in the same worktree. This counts as the same attempt, not a rejection.
   - Tasks in `review` or `sent-back` go back through review or dispatch as their status says.
   - Add one line to the `## Log` in `board.md`, for example: `<time> resumed after session crash; T3 finished→review, T4 running, T5 dead→redispatched`.
   - Carry on the loop from step 3 within `concurrency`. At the end of the phase, run the opus phase review, then stop and hand off.

**Reply to you**

> I couldn't find a run to resume: there's no `.orchestra/<run>/board.md` in this repo. Which run was it (`YYYY-MM-DD-<slug>`), or which repo or branch was it in? If the `.orchestra/` folder is gone, send me the plan path (`docs/plans/…-plan.md`). I'll start a new run from it and pick up any finished `orchestra/*` worktrees instead of redoing them.