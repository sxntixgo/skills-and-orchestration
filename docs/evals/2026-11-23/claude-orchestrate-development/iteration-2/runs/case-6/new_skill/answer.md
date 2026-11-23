**What I'd do, in order:**

1. **Read the contract.** Read `plugins/orchestration/contract.md` (done here).
2. **Find the todo task.** Look it up wherever the user keeps todos. I don't know which tracker that is, so I'm assuming it's a `TODO.md` or a todo-app entry I can read. Assumed content: *"Research app (headless runner + web UI): run research jobs headless, browse/start them from a web UI."* No acceptance criteria, stack or scope.
3. **Plan gate (step 0): ⛔ stop orchestrating.** The input is a todo task, not a written, committed plan. The repo is empty apart from `.devcontainer/`, so there's no `docs/plans/`. The skill only allows skipping the gate for small changes that are already fully specified, and this isn't one. So I would **not**:
   - create `.orchestra/`
   - edit `.git/info/exclude`
   - write `config.json` or `board.md`
   - spawn any spec or review subagents
   - dispatch anything

   Choosing a stack or architecture inside `board.md` is exactly what this gate forbids.
4. **Settle the design with the user.** I'd use the `brainstorming` skill if it's installed. Otherwise I'd ask one question at a time about purpose, then scope, then constraints, then offer 2–3 approaches and get approval. Nothing is logged yet because no run exists.
5. **After the design is approved** (later turns):
   - Save a phased plan with test commands for each task to `docs/plans/2026-11-23-research-app-plan.md`, using `writing-plans` if it's installed.
   - Commit it on `main`: `git add docs/plans && git commit -m "Research app: plan"`.
   - Come back to this skill at step 1: set up `.orchestra/2026-11-23-research-app/`, then the task graph, then the loop.

**Reply to the user:**

> I found the todo "Research app (headless runner + web UI)", but it's a one-liner and the repo is empty. Before I split it into tasks for opencode, we need a short written design and plan, because the stack and architecture are your call, not mine. I'll ask a few questions, one at a time, then propose 2–3 approaches and write the plan to `docs/plans/`. After that, orchestration runs without further check-ins.
>
> **First question: what is a "research job" in this app?** For example:
> - **(a)** A question that the headless runner answers by searching and fetching sources, then writing a report (like the existing `research` workspace flow).
> - **(b)** A generic long-running script or job queue, where the web UI just starts jobs, watches them and shows their output.
> - **(c)** Something else.