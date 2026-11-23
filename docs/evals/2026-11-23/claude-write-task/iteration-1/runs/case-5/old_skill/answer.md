I'd write `.orchestra/2026-11-23-export/tasks/T3.task.md` with three allowed files, not two: the endpoint also has to be registered in `api/main.py`, which the board row leaves out. Nothing below was run. File contents I couldn't see are marked as assumptions.

### What I'd do, in order

1. **Read the inputs.**
   - The plan section `## T3 CSV export endpoint` in `docs/plans/2026-11-23-export-plan.md`.
   - `.orchestra/2026-11-23-export/board.md`. I'd read `config.json` only for `base_branch`; I assume it is `main`.
   - **Assumed plan contents:**
     - Signature: `def export_orders_csv(start: date, end: date) -> StreamingResponse`, at route `GET /export/orders.csv?start=YYYY-MM-DD&end=YYYY-MM-DD`.
     - Columns: `id,created_at,customer_email,total`.
     - Four tests: happy path, empty range, `start > end` returns 400, and quoting of commas and quotes.
     - Test command: `uv run pytest tests/test_export.py -q`.
2. **Read the code first (skill step 1).**
   - T1's output. I assume T1 adds `list_orders(start, end) -> list[Order]` in `api/queries.py`. If T1 isn't merged yet, I'd read `.orchestra/2026-11-23-export/tasks/T1.task.md` and the plan instead, and pin the name from there.
   - The closest existing endpoint and its test. I assume these are `api/reports.py:18` (an APIRouter with a date-range GET) and `tests/test_reports.py:1-25` (a `TestClient` fixture and seeded orders).
   - `api/main.py`. I assume routers are included explicitly, e.g. `app.include_router(reports.router)` at `api/main.py:14`. In that case the new router needs a one-line registration in `api/main.py`. That file isn't in the board row, so I add it to the task's Files.
3. **Pin the check (skill step 3).**
   - `uv run pytest tests/test_export.py -q` should fail now with "file or directory not found", because the test file doesn't exist yet.
   - `uv run pytest -q --co` should collect cleanly. That confirms nothing unrelated is broken.
4. **Write the task file** (below).
5. **Update `board.md`.** In T3's row, I'd change the Files column to `api/export.py, api/main.py, tests/test_export.py` and append this log line:
   `2026-11-23 T3 spec written → .orchestra/2026-11-23-export/tasks/T3.task.md (added api/main.py: router registration)`

### `.orchestra/2026-11-23-export/tasks/T3.task.md`

```markdown
---
id: T3
run: 2026-11-23-export
depends_on: [T1]
attempt: 1
---
# Add GET /export/orders.csv that streams orders in a date range as CSV

## Context
Users need to download orders as CSV (plan: docs/plans/2026-11-23-export-plan.md, "T3 CSV export endpoint").
Data comes from T1's `list_orders(start, end)` in api/queries.py — reuse it, do not query the DB directly.
Copy the router + date-range pattern from api/reports.py:18 and the test setup from tests/test_reports.py:1-25.
Routers are registered in api/main.py:14.

## Files
- may create: api/export.py, tests/test_export.py
- may change: api/main.py (one `include_router` line only)
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. Create tests/test_export.py with the client/seed setup from tests/test_reports.py and these 4 tests:
   - `test_export_happy_path`: 2 orders in range → 200, `content-type: text/csv; charset=utf-8`,
     header row `id,created_at,customer_email,total` + 2 data rows.
   - `test_export_empty_range`: no orders in range → 200, header row only.
   - `test_export_start_after_end`: start=2026-11-10&end=2026-11-01 → 400.
   - `test_export_escapes_commas_and_quotes`: email/field containing `,` and `"` is quoted per RFC 4180.
2. Run `uv run pytest tests/test_export.py -q`; see them fail (404 / import error).
3. Create api/export.py: `router = APIRouter()`, and
   `@router.get("/export/orders.csv") def export_orders_csv(start: date, end: date) -> StreamingResponse`.
   - If `start > end`: `raise HTTPException(status_code=400, detail="start must be <= end")`.
   - Call `list_orders(start, end)`; write rows with the stdlib `csv.writer` into `io.StringIO`
     (columns in the order above; `created_at` as ISO 8601, `total` as `str(order.total)`).
   - Return `StreamingResponse(iter([buf.getvalue()]), media_type="text/csv")` with header
     `Content-Disposition: attachment; filename="orders.csv"`.
4. In api/main.py add `app.include_router(export.router)` next to the existing include_router lines.
5. Run the test command; all 4 pass.

## Done when
- `uv run pytest tests/test_export.py -q` passes (4 passed)
- `GET /export/orders.csv?start=…&end=…` returns a CSV download with the header row above

## Out of scope
- Other formats (XLSX/JSON), pagination, auth changes, extra query filters
- Changing list_orders or anything in api/queries.py (T1 owns it)
- New dependencies (use stdlib csv), refactoring api/reports.py, formatting other files
```

### Reply to orchestrator

T3 spec is written at `.orchestra/2026-11-23-export/tasks/T3.task.md`. One change from the board row: I added `api/main.py`, because the new router has to be registered there. That's a one-line change, and I've updated the board row to match.

The check is `uv run pytest tests/test_export.py -q`. It fails now only because the test file doesn't exist yet; the rest of the suite collects cleanly.

The task depends on T1's `list_orders`. Dispatch it only after T1 is merged.