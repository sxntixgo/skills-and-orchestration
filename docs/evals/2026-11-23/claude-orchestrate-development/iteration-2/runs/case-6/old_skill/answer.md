Not orchestrating yet: the skill's plan gate (step 0) stops here because there's no written plan. A todo title plus an empty repo leaves the stack, architecture and scope open. Those are your decisions, so they get settled in `brainstorming` and saved by `writing-plans` before any task graph exists.

## What I would do, in order

1. **TodoWrite** with one item per required step:
   - 0 Plan gate (in progress)
   - 1 Set up run
   - 2 Task graph
   - 3 Loop
   - 4 Finish
2. **Find the todo task.** I'd search the user's todo source (e.g. `grep -rn "Research app" ~/…/TODO.md` or the todo tool they use). Since none of this exists here, I assume it says only:
   > **Research app (headless runner + web UI)**: run research jobs (brief → report, like `claude-orchestrate-research`) headless, plus a web UI to submit briefs, watch progress and read reports.
3. **Plan gate check:**
   - `ls /workspaces/<repo>/docs/plans/` → nothing there. I assume the repo has only `.devcontainer/` and no `CLAUDE.md`/`AGENTS.md`.
   - Verdict: there's no plan, and this isn't a small, pinned-down change, so ⛔ stop orchestrating.
4. **Not done yet (each waits for the plan):**
   - no `.orchestra/`, `config.json` or `board.md`
   - no `.git/info/exclude` edits
   - no subagents or dispatches
   - I won't choose a stack inside `board.md`. That's on the skill's red-flag list.
5. **Start `brainstorming`** (frugal-skills), asking one question at a time (reply below).
6. **After the design is agreed:** run `writing-plans` → `docs/plans/2026-11-23-research-app-plan.md` (phased, with test commands), then return to this skill at step 1:
   - create run `2026-11-23-research-app`
   - add `.orchestra/` and `.worktrees/` to `.git/info/exclude`
   - write the default config (`concurrency` 2, `max_rejections` 3, `base_branch` main)
   - check that the tree is clean on `main` and the test command works
   - then build the task graph in `board.md` and run the write → dispatch → review → merge loop

## Reply to the user

> I found the todo "Research app (headless runner + web UI)". There's no plan for it yet, and the repo has only the devcontainer. The orchestrator needs a written plan before it splits the work, and the design is your call, so let's settle it quickly and I'll write the plan to `docs/plans/`. Then I'll orchestrate the build without further check-ins.
>
> **First question:** what does the "headless runner" run?
> - **A)** The existing research pipeline (brief → opencode researcher sub-tasks → report, like `claude-orchestrate-research`), so the app is a job queue and UI around it.
> - **B)** A new, self-contained research loop (search → fetch → summarize against a local model) built inside this app.
> - **C)** Something else. Please describe it.
>
> After that I'll ask about the UI scope (submit, progress, report viewer, auth?), the stack, and where jobs run.