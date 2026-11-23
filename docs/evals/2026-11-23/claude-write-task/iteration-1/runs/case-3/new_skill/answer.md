T2's spec is updated for attempt 2: the review problems are in a new `## Notes from review` section with `file:line` references, and the empty-list case is now a required test. The repo isn't on disk in this dry run, so I assumed what it contains (listed at the end).

## What I'd do, in order

**1. Find the run and what was rejected** (read-only):
```bash
cd /workspaces/<repo>
ls .orchestra/                                   # → 2026-11-21-csv-export (the only open run)
cat .orchestra/2026-11-21-csv-export/board.md    # T2 row: rejected, attempt 1
cat .orchestra/2026-11-21-csv-export/tasks/T2.task.md
cat .orchestra/2026-11-21-csv-export/tasks/T2.result.md
git -C .worktrees/2026-11-21-csv-export/T2 diff main --stat
git -C .worktrees/2026-11-21-csv-export/T2 diff main -- web/src/App.tsx api/routes/export.py
```

**2. Read the code behind each problem** (skill step 1):
- `api/routes/export.py`: I assume the 500 comes from building the CSV header with `rows[0].keys()` at line 18, which raises `IndexError` when there are no rows.
- `web/src/App.tsx`: the attempt added a "Download CSV" button at lines 42–51. That belongs to T3, which depends on T2.
- The pattern to copy is `api/routes/reports.py:12–30` (a streaming response with a fixed column list).

**3. Confirm the check** (skill step 3). In the T2 worktree, with the new empty-list test added temporarily:
```bash
uv run pytest tests/test_export.py -q    # expect: test_export_empty fails with 500, nothing else fails for unrelated reasons
```
Then discard the scratch test: `git -C .worktrees/2026-11-21-csv-export/T2 checkout -- tests/test_export.py`.

**4. Rewrite `.orchestra/2026-11-21-csv-export/tasks/T2.task.md`.** Everything from attempt 1 stays. The changes are: bump `attempt`, add the empty-list test to Steps and Done when, name `App.tsx` explicitly as off-limits, and add Notes from review.

```markdown
---
id: T2
run: 2026-11-21-csv-export
depends_on: [T1]
attempt: 2
---
# Add GET /api/items/export returning all items as CSV

## Context
T1 added `list_items()` in `api/services/items.py:8`. This endpoint streams those items as CSV.
Copy the pattern in `api/routes/reports.py:12-30` (StreamingResponse + fixed column list).
The download button in the UI is T3. It is not part of this task.

## Files
- may change: api/routes/export.py, api/main.py, tests/test_export.py
- must NOT touch: everything else, in particular web/ (incl. web/src/App.tsx), and never .orchestra/, .git/

## Steps
1. In tests/test_export.py, add `test_export_empty`: with no items, GET /api/items/export → 200,
   body is exactly `id,name,price\r\n` (header only). Run it and see it fail.
2. In api/routes/export.py, define `COLUMNS = ["id", "name", "price"]` and write the header from
   `COLUMNS`, not from the first row. Write rows with `csv.DictWriter(..., fieldnames=COLUMNS)`.
3. Keep the existing tests `test_export_items` (happy path) and `test_export_content_type` passing.
4. Run the test command below and paste its output in RESULT.md.

## Done when
- `uv run pytest tests/test_export.py -q` passes (3 tests)
- Empty DB → 200 with header line only. Never a 500.
- `git diff main --stat` lists only the files under "may change"

## Out of scope
- Any frontend change (button, link, fetch): that is T3
- Pagination, filters, query params, other formats (JSON/XLSX)
- Refactoring reports.py or extracting a shared CSV helper; new dependencies; reformatting other files

## Notes from review
- web/src/App.tsx:42-51 — added a Download CSV button; this file is not in the task — revert it entirely, leave web/ untouched (T3 does the UI).
- api/routes/export.py:18 — header built from `rows[0].keys()` → IndexError → 500 when there are no items — use the fixed `COLUMNS` list for the header and DictWriter fieldnames; add `test_export_empty` first (step 1).
```

**5. Reset the worktree for attempt 2.** In the T2 worktree, discard attempt 1's `App.tsx` change so the next run starts clean:
```bash
git -C .worktrees/2026-11-21-csv-export/T2 checkout main -- web/src/App.tsx
```

**6. Log in `board.md`.** Update the T2 row to `status: ready, attempt: 2` and append:
```
2026-11-23 T2 spec revised for attempt 2 (out-of-scope App.tsx edit; 500 on empty list) → tasks/T2.task.md
```

## Reply to you

I updated T2 for attempt 2 in `.orchestra/2026-11-21-csv-export/tasks/T2.task.md`:
- **`App.tsx`:** the spec now says to revert the change and lists `web/` as off-limits, because the UI is T3.
- **Empty list:** the 500 came from building the CSV header from the first row. The spec now requires a fixed column list and a `test_export_empty` test written first (expects 200 with the header line only).
- **Worktree:** I reverted attempt 1's `App.tsx` edit so the next run starts clean.

That's attempt 2 of 3. Next is `claude-dispatch` for T2.

Assumptions (the repo isn't on disk in this dry run):
- The run is `2026-11-21-csv-export`.
- T2 is a FastAPI CSV export endpoint.
- The 500 comes from `export.py:18`.
- The pattern to copy is `reports.py:12-30`.
- T3 owns the UI.