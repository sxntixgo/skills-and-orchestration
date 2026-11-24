I couldn't find a run to resume, so I'm stopping to ask which one before doing anything else.

**What I'd do, in order**

1. Read `plugins/orchestration/contract.md` for where run state is kept.
2. Look for the run without opening any source files:
   ```bash
   cd /workspaces/<repo>
   ls -d .orchestra/*/ 2>/dev/null
   ls .orchestra/*/board.md 2>/dev/null
   git worktree list
   git branch --list 'orchestra/*'
   ```
3. **What I assume:** You didn't name the run, and nothing in `.orchestra/` points to one: no `board.md`, no `.worktrees/<run>/` and no `orchestra/*` branches. So there's nothing to resume from.
4. **What I'd skip:**
   - No new run or task graph, because rebuilding one from memory could re-run or overwrite finished work.
   - No dispatches.
   - No log entry, because there's no `board.md` to write to.
   - No subagents.

**Reply to the user:**

> I can't find the run to pick up. There's no `.orchestra/<run>/board.md` in this repo, and no `.worktrees/` or `orchestra/*` branches left over from one. Which run was it? Any of these will do:
> - the run name (e.g. `2026-11-21-csv-export`), or
> - the path to its `board.md` (it may be in a different repo or container), or
> - the plan it was running (`docs/plans/…-plan.md`).
>
> Once I have the run, I'll read its `board.md` and the plan. For tasks marked `dispatched`, I'll check whether opencode is still running (log growing, process alive) or has finished (`RESULT.md` in the worktree). Finished tasks get reviewed, and the loop picks up from there. If you only have the plan and the board is gone, I'll start a new run from it. Before planning any task, I'll check which work is already merged on `main`.