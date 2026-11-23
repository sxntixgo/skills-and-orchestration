The todo task is an idea, not a plan, so the plan gate in step 0 stopped the run. I haven't orchestrated anything yet. The next step is to settle the design with you.

**What I'd do, in order:**

1. **TodoWrite**, one item per required step: 0 plan gate, 1 set up run, 2 task graph, 3 loop, 4 finish.
2. **Find the todo task.** I'd search the user's todo source, e.g. `grep -rn "Research app (headless runner + web UI)" ~/ TODO.md docs/ 2>/dev/null`.
   - *Assumed result:* a short note along the lines of "Research app: a headless runner that executes research jobs (claude-orchestrate-research style) without an interactive session, plus a web UI to submit questions, watch progress and read reports." It has no stack, no architecture and no acceptance criteria.
3. **Plan gate (step 0).**
   - Run `ls docs/plans/ 2>/dev/null; git -C /workspaces/<repo> log --oneline | head; ls -A /workspaces/<repo>`.
   - *Assumed result:* no `docs/plans/`. The only content is `.devcontainer/` and an initial commit.
   - There's no written plan, and the request doesn't pin down a small change, so the gate fails.
   - ⛔ I stop orchestrating here:
     - no `.orchestra/` folder
     - no `config.json`
     - no `board.md`
     - no worktrees
     - no subagents or opencode dispatches
   - Choosing the stack or architecture myself inside `board.md` is exactly the red flag the skill warns against.
4. **Start `brainstorming` (frugal-skills) with you.**
   - We settle the design one question at a time.
   - Then `writing-plans` saves `docs/plans/2026-11-23-research-app-plan.md`, a phased plan.
   - Then I come back to this skill at step 1 with that plan.
5. **Log:** nothing yet. `board.md` only exists once there's a plan. The only log entry is the TodoWrite item "0 plan gate: blocked, no plan → brainstorming".

**Reply to the user:**

> I found the todo task "Research app (headless runner + web UI)". The repo only has the devcontainer and there's no plan in `docs/plans/`. A todo line isn't enough to build from, and the stack and architecture are your call, not mine. So before I orchestrate anything, let's settle the design (brainstorming) and save a phased plan (writing-plans). Then I'll split it into tasks and run opencode on them.
>
> First question: what should the headless runner actually run?
> **A)** The existing `claude-orchestrate-research` flow: `claude -p` inside the research devcontainer, writing `runs/<run>/report.md`.
> **B)** Its own pipeline that calls opencode researchers directly, without Claude orchestrating.
> **C)** Something else. Please describe it.
>
> (After that: the web UI's scope, which could be submit-only, live progress or a report reader; the stack; and whether it's single-user/local or needs auth.)