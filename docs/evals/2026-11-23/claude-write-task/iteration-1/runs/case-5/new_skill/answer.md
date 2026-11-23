## What I'd do, in order

**1. Read the code first (Read/Grep only, nothing edited yet)**
- `docs/plans/2026-11-23-export-plan.md`, section "T3 CSV export endpoint". It already gives the signature, the CSV columns, the 4 test cases and the test command, so the spec will point to it instead of copying it.
- `.orchestra/2026-11-23-export/board.md` and `tasks/T1.task.md`, to see what T1 delivered. I assume T1 is merged and added `fetch_export_rows(session, start, end)` in `api/queries.py`.
- The closest existing endpoint and its test. I assume these are `api/reports.py:12-38` (a FastAPI `APIRouter` with `Depends(get_session)`) and `tests/test_reports.py:1-30`, which uses the `client` fixture from `tests/conftest.py:9`.
- `api/main.py`, to see how routers get registered. I assume they're added one by one with `app.include_router(...)` at `api/main.py:14-16`.

**2. Pin the files**
The board row lists only `api/export.py` and `tests/test_export.py`. But because routers are registered in `api/main.py`, the endpoint can't be reached unless one `include_router` line goes there. I'll add `api/main.py` as "may change (one line)". That makes 3 files, well under the limit. I'll note the change on the board.

**3. Pin the check**
Run `uv run pytest tests/test_export.py -q`. I expect `ERROR: file or directory not found: tests/test_export.py` because the file doesn't exist yet. I also run `uv run pytest tests/test_reports.py -q` to confirm the suite isn't broken for unrelated reasons (assumed green).

**4. Write `.orchestra/2026-11-23-export/tasks/T3.task.md`:**

```markdown
---
id: T3
run: 2026-11-23-export
depends_on: [T1]
attempt: 1
---
# Add the CSV export endpoint in api/export.py

## Context
Read docs/plans/2026-11-23-export-plan.md, section "T3 CSV export endpoint": it gives the
function signature, the CSV columns (in order), the 4 test cases and the test command. Follow it exactly.
Get the rows with T1's `fetch_export_rows` (api/queries.py); do not query the DB yourself.
Copy the router/endpoint pattern from api/reports.py:12-38 and the test pattern from
tests/test_reports.py:1-30 (`client` fixture, tests/conftest.py:9).

## Files
- may create: api/export.py, tests/test_export.py
- may change: api/main.py (only one `app.include_router(export.router)` line, next to the others at :14-16)
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. Create tests/test_export.py with the plan's 4 test cases, one test function each.
2. Run `uv run pytest tests/test_export.py -q` and see them fail (404 / import error).
3. Create api/export.py: `router = APIRouter()` and the endpoint with the plan's signature.
   Write the CSV with the stdlib `csv` module into `io.StringIO`, header row first, columns in the plan's order.
   Return `Response(content=..., media_type="text/csv")` with the
   `Content-Disposition` header the plan gives.
4. Register the router in api/main.py.
5. Re-run the test command until all 4 pass.

## Done when
- `uv run pytest tests/test_export.py -q` passes (4 passed)
- the endpoint returns `text/csv` whose header row equals the plan's column list

## Out of scope
- New dependencies (no pandas). Use stdlib `csv` only.
- Streaming, pagination, extra query params or formats beyond the plan's signature.
- Changes to api/queries.py, api/reports.py, conftest.py, or formatting of any other file.
```

**5. Update the board**
In `.orchestra/2026-11-23-export/board.md`, add to the log: `2026-11-23 T3 spec written → tasks/T3.task.md (added api/main.py: router registration, 1 line)`. I'd also update T3's files cell to `api/export.py, tests/test_export.py, api/main.py`. I leave the status at `todo`, because dispatching is the orchestrator's step.

## Reply to the orchestrator

```
.orchestra/2026-11-23-export/tasks/T3.task.md
```