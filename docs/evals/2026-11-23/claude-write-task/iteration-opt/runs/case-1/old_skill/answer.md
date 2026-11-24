The spec is written to `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`. You didn't name a run, so I started a new one. Nothing below was actually executed; these are the steps I'd take.

**Assumptions:** `api/routes.py` is a FastAPI router. `GET /jobs` is `list_jobs()` at `api/routes.py:42`. It returns `list[JobOut]` from a SQLAlchemy `select(Job).order_by(Job.id)`. Tests are in `tests/test_routes.py` and use a `client` fixture (`tests/conftest.py`). `GET /runs` at `api/routes.py:88` already uses `Query(..., ge=1)` params, so that's the pattern to copy. No pagination helper exists yet. The test runner is `uv run pytest`.

**1. Read the code**
- `api/routes.py`: `list_jobs` and the `/runs` handler (the `Query` pattern)
- `tests/test_routes.py`: the existing `/jobs` tests and how they seed jobs
- `tests/conftest.py`: the `client` and DB fixtures

**2. Set up the run**
```bash
cd /workspaces/<repo>
mkdir -p .orchestra/2026-11-23-jobs-pagination/{tasks,logs}
grep -qx '.orchestra/' .git/info/exclude || echo '.orchestra/' >> .git/info/exclude
grep -qx '.worktrees/' .git/info/exclude || echo '.worktrees/' >> .git/info/exclude
```

**3. Check the test command once before the tests exist**
```bash
uv run pytest tests/test_routes.py -q -k jobs
```
The current `/jobs` tests should pass. If anything fails for unrelated reasons (imports, fixtures), I'd fix the spec or report it before handing off.

**4. Write `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`**
```markdown
---
id: T1
run: 2026-11-23-jobs-pagination
depends_on: []
attempt: 1
---
# Add page/page_size pagination to GET /jobs

## Context
GET /jobs (`list_jobs`, api/routes.py:42) returns every job. Add offset pagination via query
params. Copy the `Query(..., ge=1)` style from the GET /runs handler (api/routes.py:88).
Response body stays a plain list of JobOut (no envelope) so existing clients keep working.

## Files
- may change: api/routes.py, tests/test_routes.py
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In tests/test_routes.py add (seed 25 jobs with the existing seeding helper/fixture):
   - `test_list_jobs_default_page_size`: GET /jobs → 200, 20 items, ids 1–20.
   - `test_list_jobs_second_page`: GET /jobs?page=2&page_size=10 → ids 11–20.
   - `test_list_jobs_page_past_end`: GET /jobs?page=4&page_size=10 → 200, [].
   - `test_list_jobs_invalid_params`: page=0, page_size=0, page_size=101 → each 422.
2. Run the test command; see the new tests fail.
3. In `list_jobs` add params:
   `page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=100)`.
4. Apply to the existing query, keeping `order_by(Job.id)`:
   `.offset((page - 1) * page_size).limit(page_size)`.
5. Run the test command; all pass.

## Done when
- `uv run pytest tests/test_routes.py -q -k jobs` passes
- GET /jobs with no params returns at most 20 jobs; ordering unchanged

## Out of scope
- Response envelope / total count / Link headers / next-page URLs
- Pagination on any other endpoint, or a shared pagination helper
- Renaming, refactoring or reformatting other handlers; new dependencies
```

**5. Log it in `.orchestra/2026-11-23-jobs-pagination/board.md`**
```markdown
| id | goal | status | attempt |
|---|---|---|---|
| T1 | GET /jobs pagination | spec ready | 1 |

## Log
- 2026-11-23 T1 spec written: tasks/T1.task.md
```

**Two decisions I made that you didn't specify:**
- **Max `page_size` is 100.** An invalid `page` or `page_size` returns a 422 error.
- **The response stays a plain list.** It doesn't include a total count, so existing clients keep working. Change either and I'll update the spec.

Next step is `claude-dispatch`. I haven't dispatched it.