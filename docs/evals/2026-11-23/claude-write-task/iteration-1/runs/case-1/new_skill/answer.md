Task written to `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`. No run was mentioned, so I'd create a one-task run.

**Steps, in order**

1. Read the code first (the task touches only the route and its test):
   ```
   cat .orchestra/config.json                          # missing → contract defaults
   sed -n '1,200p' api/routes.py
   grep -rn "offset\|limit\|page" api/ --include=*.py   # look for an existing pagination pattern
   ls tests/ && sed -n '1,80p' tests/test_routes.py
   ```
   What I assume these show:
   - The app uses FastAPI.
   - `GET /jobs` is at `api/routes.py:42`: `def list_jobs(db: Session = Depends(get_db))` returns `db.query(Job).order_by(Job.id).all()`.
   - There is no pagination helper yet.
   - `GET /users` at `api/routes.py:18` shows the `Query(...)` param style to copy.
   - Tests use the `client` fixture in `tests/conftest.py`, and the jobs tests are in `tests/test_routes.py`.
   - `make_job` is my placeholder name for a job factory or fixture in `conftest.py`. If none exists, I'd add one to the task's files.
2. Set up the run:
   ```
   mkdir -p .orchestra/2026-11-23-jobs-pagination/tasks
   grep -qx '.orchestra/' .git/info/exclude || printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
   ```
3. Check the test command before writing the task:
   ```
   uv run pytest tests/test_routes.py -q -k pagination
   ```
   It should report "no tests ran" (exit 5), not an import or collection error. I'll assume it does.
4. Write `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`:

```markdown
---
id: T1
run: 2026-11-23-jobs-pagination
depends_on: []
attempt: 1
---
# Add page/page_size pagination to GET /jobs

## Context
`list_jobs` (api/routes.py:42) returns every job. Add 1-based pagination with
`page` (default 1) and `page_size` (default 20, max 100). The response body stays a plain
JSON list (no envelope), so existing clients keep working. Copy the `Query(...)` param style
from `list_users` (api/routes.py:18). Tests use the `client` fixture (tests/conftest.py).

## Files
- may change: api/routes.py, tests/test_routes.py
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In tests/test_routes.py add, with names containing `pagination`:
   - `test_jobs_pagination_default`: create 25 jobs (use `make_job`) → `GET /jobs` returns 20, ids 1–20.
   - `test_jobs_pagination_second_page`: 25 jobs, `GET /jobs?page=2&page_size=10` → ids 11–20.
   - `test_jobs_pagination_past_end`: 5 jobs, `GET /jobs?page=3&page_size=10` → `[]`, status 200.
   - `test_jobs_pagination_invalid`: `page=0`, `page_size=0`, `page_size=101` → each 422.
2. Run the test command; see the new tests fail.
3. In `list_jobs` add params `page: int = Query(1, ge=1)` and
   `page_size: int = Query(20, ge=1, le=100)`.
4. Keep `.order_by(Job.id)`; add `.offset((page - 1) * page_size).limit(page_size)` before `.all()`.
5. Run the test command; all pass.

## Done when
- `uv run pytest tests/test_routes.py -q` passes (including the 4 new tests)
- `GET /jobs` with no params returns at most 20 jobs, lowest ids first

## Out of scope
- Total count, `next`/`prev` links, response envelope or headers
- Pagination on other endpoints; a shared pagination helper
- Renaming or refactoring `list_jobs`; formatting other code; new dependencies
```

5. Write `.orchestra/2026-11-23-jobs-pagination/board.md`:
   ```
   | id | goal | depends_on | status | attempt |
   |----|------|-----------|--------|---------|
   | T1 | GET /jobs pagination | – | spec written | 1 |

   ## Log
   - 2026-11-23 T1 spec written → tasks/T1.task.md
   ```

**Reply to the user**

> I wrote the task at `.orchestra/2026-11-23-jobs-pagination/tasks/T1.task.md`. It only changes `api/routes.py` and `tests/test_routes.py`, and it's checked by `uv run pytest tests/test_routes.py -q`.
>
> I decided three things you didn't specify:
> - Pages start at 1.
> - The response stays a plain list, with no total count.
> - `page_size` is capped at 100, and invalid values return 422.
>
> If you want a total count in the response or no cap, tell me and I'll revise the task. Otherwise it's ready to send to opencode with `claude-dispatch`.