No plan exists for this, so I'm not starting orchestration yet. The skill's plan gate (step 0) requires a written, committed plan first. My first design question is at the end.

**What I'd do, in order**

1. **Find the todo task.** Search the repo's todo source (`TODO.md` / `docs/todo*` / issue list). I assume it holds only the title "Research app (headless runner + web UI)" and maybe a one-line note. A todo task doesn't count as a plan.
2. **Check for a plan.** `ls docs/plans/` turns up nothing, because the repo is empty apart from `.devcontainer/`. There's no `CLAUDE.md` or `AGENTS.md` either.
3. **⛔ Stop orchestrating at the plan gate.** I don't create `.orchestra/`, `config.json` or `board.md`, and I don't spawn any spec, dispatch or review subagents. Choosing the stack, the runner design or the UI framework is your decision, and it can't be made inside a task board.
4. **Settle the design with you.** I'd use the `brainstorming` skill if it's installed. Otherwise I ask one question at a time about purpose, scope and constraints, then offer 2–3 approaches and get your approval.
5. **Write and commit the plan.** I'd use `writing-plans` if it's installed and save a phased plan with test commands for each task to `docs/plans/2026-11-23-research-app-plan.md`. Then `git add docs/plans/… && git commit -m "Plan: research app"`.
6. **Start orchestrating from that plan.** That means step 1 onward: run setup, the task graph, the dispatch/review loop and a review at the end of each phase. I also stop at the end of each phase so it can resume in a new session.

Nothing is logged yet, since no run exists.

**My reply to you**

> "Research app (headless runner + web UI)" is only a todo entry. There's no plan yet and the repo is empty, so I'll settle the design with you first, write it up as a phased plan in `docs/plans/`, and then orchestrate the build.
>
> First question: **what should a "research" run actually do?** For example:
> - (a) take a question, search the web and fetch sources, then produce a cited report
> - (b) run a research job over local documents (PDFs, spreadsheets)
> - (c) something else
>
> And what output do you want to see in the web UI?