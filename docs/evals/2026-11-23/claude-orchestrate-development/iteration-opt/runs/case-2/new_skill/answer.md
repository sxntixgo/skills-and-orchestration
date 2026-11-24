Not dispatching yet: I found no written plan for the CSV export, and the skill won't start a run without one. Your task table is fine as a task graph, but it doesn't settle the design: what the CSV contains, how big it can get, or who can call the route.

**What I'd do, in order**

1. TodoWrite with steps 0–5 from the skill.
2. Plan gate (step 0): look for a plan that covers this.
   ```bash
   ls docs/plans/ 2>/dev/null; grep -ril "export" docs/plans/ 2>/dev/null
   ```
   You didn't name a plan path, so I assume nothing matches. ⛔ I stop orchestrating here. I would not create `.orchestra/`, `board.md`, worktrees or specs.
3. Settle the design with you using the `brainstorming` skill: one question at a time, then 2–3 approaches for you to approve.
4. Write `docs/plans/2026-11-23-jobs-csv-export-plan.md` with one phase and a test command per task, commit it, then start the run from step 1.

**Graph changes I'll make once the plan exists** (the graph is my call, so these won't need your approval)

- **T3 depends on T2.** Both edit `api/routes.py`, so they can't run at the same time.
- **T3 is split.** "Adds a button and also edits `routes.py`" is two jobs. The `routes.py` part moves into T2, leaving T3 as `web/src/Jobs.tsx` plus its test.
- **T2 depends on T1.** The route calls `export_csv()`.
- **T1 may merge into T2** if `export_csv()` is only a few lines, since a separate spec for it would be as long as the code.
- **T2 gets `review: opus`.** It's a new endpoint that exposes data.

The result is a chain, T1 → T2 → T3 (or T2 → T3), so concurrency 2 won't actually run anything in parallel for this feature.

**First design question:** what should the CSV contain? For example:
- (a) every job, with all columns from the Jobs table
- (b) only the jobs in the current filtered view of `Jobs.tsx`, with the visible columns
- (c) something else