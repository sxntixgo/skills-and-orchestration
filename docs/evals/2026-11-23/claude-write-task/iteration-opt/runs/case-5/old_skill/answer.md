1. **Read the inputs** (read-only):
   - `docs/plans/2026-11-23-export-plan.md`, section "T3 CSV export endpoint". It gives the signature, the CSV columns, the 4 test cases and the test command. I'm assuming the command is `uv run pytest tests/test_export.py -q`.
   - `.orchestra/2026-11-23-export/board.md` and `tasks/T1.task.md`, to see what T1 provides. I'm assuming T1 adds `api/queries.py::list_orders(filters)`, which T3 reuses.
   - The closest existing pattern. I'm assuming `api/reports.py:12-40` (a router GET endpoint that uses `get_db`) and `tests/test_reports.py:1-25` (`client` fixture from `tests/conftest.py`).
   - `api/export.py` and `tests/test_export.py` don't exist yet.

2. **Check the test command:** run `cd /workspaces/<repo> && uv run pytest tests/test_export.py -q`. I expect `ERROR: file or directory not found` (exit 4), which is the right failure for a task that hasn't started. I'd also run `uv run pytest tests/test_reports.py -q` to confirm the suite itself isn't broken for unrelated reasons (assume it passes).

3. **Write `.orchestra/2026-11-23-export/tasks/T3.task.md`:**

```markdown
---
id: T3
run: 2026-11-23-export
depends_on: [T1]
attempt: 1
---
# Add the CSV export endpoint in api/export.py

## Context
Design, signature, CSV columns and the 4 test cases are in docs/plans/2026-11-23-export-plan.md,
section "T3 CSV export endpoint" — read it first; it is the source of truth.
Copy the endpoint pattern of api/reports.py:12-40 (router, get_db dependency) and the test
pattern of tests/test_reports.py:1-25 (`client` fixture from tests/conftest.py).
Get the rows with `list_orders` from api/queries.py (added by T1); do not query the DB yourself.

## Files
- may create: api/export.py, tests/test_export.py
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. Create tests/test_export.py with the 4 test cases from the plan section, one test function each.
2. Run `uv run pytest tests/test_export.py -q`; see them fail.
3. Create api/export.py with the function exactly as the plan's signature; build the CSV with the
   stdlib `csv` module (csv.writer over io.StringIO), header row = the plan's columns in that order.
4. Register the router the same way api/reports.py is registered — if that requires editing a file
   not listed above, stop and report it under Questions in RESULT.md.
5. Run the test command until all 4 pass.

## Done when
- `uv run pytest tests/test_export.py -q` passes (4 passed)
- the endpoint returns the plan's CSV header as the first line

## Out of scope
- other formats (XLSX, JSON), streaming, pagination, extra query params
- new dependencies (pandas etc.) — use stdlib csv
- changes to api/queries.py, api/reports.py or any refactor/reformatting of other files
```

   Assumption for step 4: if `api/reports.py` is wired up through `api/__init__.py` or `main.py`, the board row doesn't list that file. Rather than widen the scope myself, the spec tells the implementer to stop and report it. In a real run, if I confirmed during step 1 that registration needs `api/main.py`, I'd add it under "may change" (that's 3 files, still under the limit) and replace step 4 with the exact `include_router` line.

4. **Update `board.md`:** in the T3 row, set the spec path to `tasks/T3.task.md`. Leave the status as `todo`, since the orchestrator owns dispatch.

5. **Reply to the orchestrator:**

```
.orchestra/2026-11-23-export/tasks/T3.task.md
```