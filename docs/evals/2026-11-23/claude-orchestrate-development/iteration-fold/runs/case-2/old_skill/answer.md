**Not dispatching yet: there's no written plan for this work, so the plan gate in step 0 stops the run.**

**What I'd do, in order**

1. Look for a plan: `ls docs/plans/`, then `git log --oneline -- docs/plans/`. You didn't name a plan path, so I'm treating it as not found.
2. Stop at the plan gate. A task table isn't a plan. It names files but not the design: which jobs get exported, which columns, filters, how big exports are handled, and who is allowed to export. This isn't a small change the request already pins down, so I can't skip the gate. I would not create `.orchestra/`, `board.md`, subagents or dispatches yet.
3. Settle the design with you, one question at a time. If the `brainstorming` skill is installed, I'd use it.
4. Write a phased plan with a test command for each task to `docs/plans/2026-11-23-jobs-csv-export-plan.md`, commit it, then start the run.

**Changes I'll make to the task table once the plan exists.** These follow the skill's rules, so I won't ask you to approve them again:
- **Merge T1 into T2.** On its own, the `export_csv()` spec would be about as long as the code, and the route needs that code anyway. The new T2 covers `api/export.py`, `api/routes.py` and their tests, and is marked `review: opus` because it writes files and serves data.
- **Keep T2 and T3 from overlapping.** Both edit `api/routes.py`, so they can't run at the same time. T3's backend change moves into T2. T3 then changes only `web/src/Jobs.tsx` and its test, with `depends_on: T2`.
- **Expect one task at a time.** Each task needs the previous one, so concurrency 2 won't be used. Running them in parallel would mean two tasks editing the same file.

**My reply**

> I'm not dispatching yet because there's no written plan for the CSV export. I looked in `docs/plans/` and found nothing that covers it. If a plan exists somewhere else, send me the path and I'll start right away. Otherwise, first question: what should one CSV row be? (a) one row per job with the columns shown in the Jobs table, (b) one row per job with all job fields, or (c) something else, such as per-run rows.
>
> Once there's a plan, I'll merge T1 into T2 and move T3's `api/routes.py` edit into T2. T3 will then only touch `Jobs.tsx` and wait for T2. As written, T2 and T3 can't run together because both edit `routes.py`.