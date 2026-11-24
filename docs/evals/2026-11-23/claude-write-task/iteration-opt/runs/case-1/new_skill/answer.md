I'd save this as `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`. You didn't name a run, so I'd start a new one and note the task in its `board.md`.

**What I'd do, in order:**
1. **Read the code first.** Open `api/routes.py` (the `GET /jobs` handler), `tests/test_routes.py`, and look for any existing endpoint that already uses query parameters. I'm assuming this is a FastAPI app where `GET /jobs` is at `api/routes.py:42` and calls `list_jobs(db)` from `api/db.py`. I'm also assuming no endpoint paginates yet, so I'd copy the closest query-parameter pattern instead: `GET /jobs/{id}` at `api/routes.py:58`. I wouldn't cite a pagination pattern that doesn't exist.
2. **Check the test command.** Run `pytest tests/test_routes.py -k jobs_pagination -q` once. It should report "no tests ran", not an unrelated error.
3. **Write the file below**, then add a line to `.orchestra/2026-11-23-jobs-pagination/board.md`: `T1 — GET /jobs pagination — tasks/T1.task.md — todo`.

```markdown
---
id: T1
run: 2026-11-23-jobs-pagination
depends_on: []
attempt: 1
---
# Add page/page_size query params to GET /jobs (default page_size 20)
## Context
GET /jobs (api/routes.py:42) returns every job. Add offset pagination via query params.
Copy the query-param style of GET /jobs/{id} (api/routes.py:58): FastAPI `Query(...)` with bounds.
Response shape stays a JSON list (no envelope), so existing clients keep working.
## Files
- may change: api/routes.py, tests/test_routes.py
- must NOT touch: everything else (and never .orchestra/, .git/)
## Steps
1. In tests/test_routes.py add tests named `test_jobs_pagination_*`, seeding 25 jobs with the existing fixture:
   - `_default`: GET /jobs → 20 items, the first 20 by current ordering
   - `_second_page`: GET /jobs?page=2&page_size=10 → items 11–20
   - `_past_end`: GET /jobs?page=4&page_size=10 → 200, []
   - `_invalid`: page=0 → 422; page_size=0 → 422
2. Run them; see them fail.
3. In the GET /jobs handler add `page: int = Query(1, ge=1)` and `page_size: int = Query(20, ge=1)`.
4. Apply `offset=(page-1)*page_size`, `limit=page_size` to the existing query (slice in SQL if
   list_jobs builds one, otherwise slice the list). Keep the current ordering.
5. Run the tests; all pass.
## Done when
- `pytest tests/test_routes.py -k jobs_pagination -q` passes
- `pytest tests/test_routes.py -q` still passes (no regressions)
- GET /jobs with no params returns at most 20 jobs
## Out of scope
- Response envelope (total, next links), cursor pagination
- Paginating other endpoints; refactoring list_jobs; new dependencies
- Reformatting other code in routes.py
```

**My reply:**

The task is written to `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`. It changes 2 files and the check is `pytest tests/test_routes.py -k jobs_pagination -q`. You didn't specify these, so I picked them:
- **Response shape:** it stays a plain list.
- **No upper limit on `page_size`:** a client can request any size.

If you want a maximum page size (e.g. `le=100`) or a `{items, total}` wrapper, tell me and I'll add it.