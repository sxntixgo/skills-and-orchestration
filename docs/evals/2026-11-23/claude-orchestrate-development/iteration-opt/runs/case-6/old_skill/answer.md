**I'm stopping at the plan gate: no orchestration yet.** The todo task gives a title and maybe a few lines. That's not a plan, the repo has no `docs/plans/`, and a research app with a headless runner and a web UI leaves the stack, architecture and scope open. The skill won't let me pick those inside `board.md`, so we need to settle the design first.

**What I'd do, in order:**

1. **Find the todo task.** I'm assuming it's in the user's todo list (e.g. `TODO.md`) and reads about like: "Research app: headless runner that runs research jobs, plus a web UI to start them and read the reports." It has no stack, architecture or acceptance criteria.
2. **Run step 0 (plan gate).** I'd check for a plan the user gave me or one under `docs/plans/*-plan.md`. There is none, since the repo only has `.devcontainer/`. This isn't a small change the request already pins down, so I'd stop orchestrating.
3. **Skip the rest for now.** I would not create `.orchestra/`, edit `.git/info/exclude`, write `config.json` or `board.md`, spawn subagents or dispatch anything until a committed plan exists.
4. **Settle the design with you.** The `brainstorming` skill isn't installed, so I'd ask one question at a time about purpose, scope and constraints, then offer 2–3 approaches and get your approval.
5. **Write and commit the plan.** After you approve, I'd save a phased plan with a test command per task to `docs/plans/2026-11-23-research-app-plan.md` and commit it (`git add docs/plans/… && git commit -m "Plan: research app"`).
6. **Return to the skill at step 1** with that plan: set up the run `2026-11-23-research-app`, build the task graph and run the loop. The session stops after Phase 1 is reviewed.

**My reply to you:**

> There's no written plan for "Research app (headless runner + web UI)", and the repo only has the devcontainer. Before I split this into tasks, the design has to come from you, not from me guessing a stack. I'll ask a few questions one at a time, offer 2–3 approaches, then write and commit a phased plan to `docs/plans/` and start orchestrating from it.
>
> **First question:** what is one research job? For example:
> (a) a question goes in and the runner returns a written report with sources (search, fetch, summarise)
> (b) a scripted pipeline over files or data you provide
> (c) something else
>
> Also, who starts jobs: only you, on this machine, or other people over the network?