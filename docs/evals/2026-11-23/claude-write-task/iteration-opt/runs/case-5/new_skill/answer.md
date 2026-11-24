**1. Read (assumed contents):**
- `docs/plans/2026-11-23-export-plan.md`, section "T3 CSV export endpoint". I assume it gives `def export_orders_csv(start: date, end: date) -> Response`, the columns `id,created_at,customer_email,total`, 4 test cases (happy path, empty range, `start > end` → 400, comma/quote escaping) and the command `pytest tests/test_export.py -q`.
- `.orchestra/2026-11-23-export/board.md`: T1 is `done`. I assume T1 added `query_orders(start, end)` at `api/orders.py:40`.
- The closest existing endpoint pattern. I assume it's a FastAPI router in `api/reports.py:12–35` (a GET route with date query params, registered in `api/__init__.py:8`), with its tests at `tests/test_reports.py:1–30` using the `client` fixture.
- `api/export.py` and `tests/test_export.py` don't exist yet.

**2. Run the check once:** `pytest tests/test_export.py -q`. Expected result: "file or directory not found" (exit 4). That's the right kind of failure because nothing unrelated is broken.

**3. File count:** 2 files to create, plus one line to register the router in `api/__init__.py`, so 3 total. That's under 5, so the task doesn't need splitting.

**4. Write `.orchestra/2026-11-23-export/tasks/T3.task.md`:**

```markdown
---
id: T3
run: 2026-11-23-export
depends_on: [T1]
attempt: 1
---
# Add GET /export/orders.csv returning orders in a date range as CSV
## Context
Third task of the export run. T1 added `query_orders(start, end)` (api/orders.py:40); this
endpoint wraps it. Copy the router/date-param pattern of api/reports.py:12–35 and its tests in
tests/test_reports.py:1–30 (`client` fixture). Use stdlib `csv` only.
## Files
- may create: api/export.py, tests/test_export.py
- may change: api/__init__.py (one line: include the export router, as at api/__init__.py:8)
- must NOT touch: everything else (and never .orchestra/, .git/)
## Steps
1. Read docs/plans/2026-11-23-export-plan.md, section "T3 CSV export endpoint": signature,
   CSV columns and the 4 test cases are defined there.
2. Write the 4 test cases in tests/test_export.py; run the test command, see them fail.
3. Implement in api/export.py: call `query_orders(start, end)` (don't re-query the DB), write
   rows with `csv.writer` to a `io.StringIO`, return `Response(media_type="text/csv")` with
   header `Content-Disposition: attachment; filename="orders.csv"`.
4. Register the router in api/__init__.py next to the reports router.
5. Run the test command until it passes.
## Done when
- `pytest tests/test_export.py -q` passes
- GET /export/orders.csv?start=2026-01-01&end=2026-01-31 returns 200, text/csv, header row
  first in the plan's column order
## Out of scope
- Streaming/pagination, other formats (XLSX/JSON), auth changes
- Changing query_orders or api/reports.py; refactors or formatting of other files
- New dependencies (pandas etc.)
```

**5. Update `board.md`:** add `tasks/T3.task.md` to the T3 row's spec column and leave the status as `todo`.

**6. Reply to the orchestrator:**

.orchestra/2026-11-23-export/tasks/T3.task.md