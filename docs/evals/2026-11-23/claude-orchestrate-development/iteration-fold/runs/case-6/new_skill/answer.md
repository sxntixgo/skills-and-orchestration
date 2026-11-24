No plan exists for this yet, so I can't start orchestrating. The skill's plan gate (step 0) needs a written, committed plan, and a todo task is only an idea. We need to settle the design first, starting with the question at the end.

**What I'd do, in order**

1. **TodoWrite** with the skill's steps: 0 Plan gate, 1 Set up run, 2 Task graph, 3 Loop, 4 End of phase, 5 Finish.
2. **Find the todo task:**
   ```bash
   cd /workspaces/<repo>
   git status && git log --oneline | head
   ls docs/plans 2>/dev/null
   grep -rniI "Research app" --exclude-dir=.git . 2>/dev/null
   ```
   I'm assuming it's in your task list, not in the repo, since the repo only has `.devcontainer/`. I'm also assuming it says only "Research app (headless runner + web UI)", with no stack, scope or acceptance criteria.
3. **Plan gate check:** there's no `docs/plans/` folder and no plan covering this, so I stop orchestrating. I won't create `.orchestra/`, `config.json` or `board.md`. Choosing a stack or architecture while writing `board.md` is one of the skill's red flags.
4. **Settle the design with you** using the `brainstorming` skill if it's installed, otherwise by hand. That means one question at a time about purpose, scope and constraints. Then I'd offer 2–3 approaches and get your approval.
5. **After you approve,** I'd write `docs/plans/2026-11-23-research-app-plan.md` (with `writing-plans` if installed). It would be split into phases, each with tasks and exact test commands, starting with Phase 1: project skeleton, test and lint setup, and the shared core. Then:
   ```bash
   git add docs/plans/2026-11-23-research-app-plan.md && git commit -m "Plan: research app"
   ```
6. **Then step 1:** set up the run `.orchestra/2026-11-23-research-app/`, add `.orchestra/` and `.worktrees/` to `.git/info/exclude`, and write `config.json` with the defaults plus `test_cmd`/`lint_cmd` from the plan. After that comes the task graph and the dispatch loop, one session per phase.

Nothing is logged yet because no run exists.

**Reply to you**

I'll start building once we've agreed a design and committed a plan.

First question: what should one "research" run do? For example:
- **(a)** take a question, search the web, read sources and write a cited report;
- **(b)** run a fixed pipeline over documents you supply (PDF, XLSX, URLs);
- **(c)** something else.

The web UI would start runs and show their results either way.