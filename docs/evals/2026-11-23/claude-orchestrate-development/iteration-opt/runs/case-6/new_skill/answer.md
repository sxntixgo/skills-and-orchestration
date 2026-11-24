The plan gate stops this run: a todo task isn't a plan, and the repo has no `docs/plans/`. So I'd dispatch nothing and start settling the design with you.

**What I'd do, in order**

1. **TodoWrite**, one item per required step (0 to 5). Step 0 is in progress.
2. **Find the todo.** Search the todo list or tracker for "Research app (headless runner + web UI)". *Assumed result:* a title plus 2–3 lines of notes, roughly "run research jobs headlessly; web UI to start them and read the results". There's no stack, no data model and no phases.
3. **Plan gate (step 0).** I'd check `docs/plans/*-plan.md` and find nothing, since the repo has only `.devcontainer/`. The request doesn't pin down a small change, so I ⛔ stop orchestrating. I don't create `.orchestra/`, `config.json` or `board.md`, spawn no spec or review subagents, and write nothing to a log. Choosing a stack or architecture inside `board.md` is the skill's red flag.
4. **Design with you.** I'd use the `brainstorming` skill if it's installed; otherwise I ask one question at a time. The topics are:
   - what a "research job" is
   - how it runs (CLI, queue, schedule)
   - where results go
   - who uses the UI (local only or multi-user)
   - which stack
   
   Then I'd offer 2–3 approaches and get your approval.
5. **Write the plan.** I'd save a phased plan with a test command for each task to `docs/plans/2026-11-23-research-app-plan.md`, using `writing-plans` if it's installed. Then `git add` and `git commit -m "Plan: research app"`.
6. **Return to orchestration with that plan.** That covers step 1 (set up the run and check that tests pass on `main`) and step 2 (task graph). Phase 1 would probably be scaffolding, the test command and the shared job model, so later tasks can reuse it.

**My reply to you**

> I found the todo "Research app (headless runner + web UI)", but it's only a one-line idea. There's no written plan, so I can't start orchestration yet. The design is your call; I only split a plan into tasks. Let's settle the design first, then I'll write and commit a phased plan in `docs/plans/` and start the run.
>
> First question: what does one "research job" do? For example:
> - **(a)** Run an LLM agent on a question and produce a written report.
> - **(b)** Run a fixed pipeline (fetch sources, then summarise).
> - **(c)** Something else.