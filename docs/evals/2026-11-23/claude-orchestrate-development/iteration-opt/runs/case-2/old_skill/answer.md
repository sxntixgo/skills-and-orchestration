I can't start dispatching yet because I can't find a written plan for this work, and the skill requires one first. The task table you gave says which files change, but not the design. One problem in the table also needs fixing before dispatch: T2 and T3 both edit `api/routes.py`.

**What I'd do, in order:**

1. Look for a plan: any path you gave (none), then `ls docs/plans/` for anything covering CSV export. I'm assuming there isn't one, so nothing else happens: no `.orchestra/` run, no `board.md`, no worktrees, no dispatches.
2. Fix the task graph for when we do start. Two tasks that run at the same time can't edit the same file, so T3 will wait for T2 (`depends_on: [T2]`):

   | id | goal | depends_on | files |
   |---|---|---|---|
   | T1 | `export_csv()` + tests | — | `api/export.py`, `tests/test_export.py` |
   | T2 | `/export` route + tests | T1 | `api/routes.py`, `tests/test_routes.py` |
   | T3 | Export button in Jobs + its route change | T2 | `web/src/Jobs.tsx`, `api/routes.py` |

   T2 needs T1's function, so the three run one after another. Concurrency 2 doesn't help here unless T3's change to `routes.py` moves into T2. Then T3 would only touch `web/src/Jobs.tsx` and could be written and run alongside T2. I'll do that if you agree.

   You don't need to approve the task table; the task graph is mine to plan. The design is yours.

**My reply to you:**

> Is there a written plan for the CSV export? If so, give me its path. If not, we'll settle the design first, starting with one question:
>
> **Which data does `export_csv()` export, and with which columns?** For example: all jobs or only the filtered view, and fixed columns or the ones shown in the table.
>
> After that I'll ask about auth and size limits on `/export`, and whether it streams or builds the file in memory. Then I'll save `docs/plans/2026-11-23-csv-export-plan.md` with a test command for each task, commit it, and start dispatching with the graph above.