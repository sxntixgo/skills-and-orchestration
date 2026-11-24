I'll build Phase 2 only. The Redis cache (T5.1) and the admin dashboard (T5.2) are Phase 5 work, and the skill says to build one phase at a time. Both are already listed in Phase 5 of `PLAN.md`, so they'll get built there and nothing is lost. A cache in front of an endpoint that doesn't exist yet would also be building ahead of need. If you want them sooner, we can move them into their own phase and give each a model.

**What I'd do, in order:**

1. **Read the plan.** `PLAN.md`, Phase 2 is done when `GET /jobs` returns 200 with a JSON list of open jobs and `pytest tests/test_jobs.py` passes.
2. **Assumptions** (I haven't seen the repo):
   - The app is FastAPI with an existing `Job` model that has a `status` field ("open" or "closed").
   - Data access goes through the existing session or repository pattern in `app/`.
   - The list has no pagination, because Phase 2 doesn't ask for it.
3. **Create TodoWrite items:**
   - T2.1 `list_open_jobs()` (sonnet)
   - T2.2 `GET /jobs` route (sonnet)
   - Run the full check
   - Update `PLAN.md`
   - Notes go in `./.claude-skills-work/software-development/phase-2/`.
4. **Delegate T2.1, because I'm on Opus and the task is assigned to Sonnet.** Agent, `model: "sonnet"`:
   > Build T2.1 in /workspaces/<repo>, test-first. Add `list_open_jobs()` in `app/jobs.py`. It returns only jobs with status "open", using the repo's existing data-access pattern and parameterized queries. Write the tests in `tests/test_jobs.py` first and run them so you see each one fail for the right reason. Then write the simplest code that passes, then refactor. Cases:
   > - no jobs gives `[]`
   > - one open job
   > - a mix of open and closed jobs returns only the open ones
   > - all jobs closed gives `[]`
   >
   > Assert on returned values, not on internal calls. Don't add caching, pagination or filters. Don't commit. Report the files you changed and the pytest output.
5. **Delegate T2.2 after T2.1 is back.** Agent, `model: "sonnet"`:
   > Build T2.2 in /workspaces/<repo>, test-first. Add `GET /jobs` in `app/routes.py` as a thin handler that calls `list_open_jobs()` and returns 200 with a JSON list. Write the tests first in `tests/test_jobs.py` using the app's test client:
   > - 200 with `[]` when there are no jobs
   > - 200 with only open jobs
   > - the response contains no internal or PII fields
   >
   > Use the existing route and auth conventions. No caching, no admin routes. Don't commit. Report the files you changed and the pytest output.
6. **Review and verify the subagents' work myself:**
   - `pytest`, the full suite, not just `tests/test_jobs.py`
   - the repo's lint and typecheck (`ruff check .`, `mypy app` if they're configured)
   - start the app, run `curl -s -w '%{http_code}' localhost:8000/jobs`, check for 200 and a JSON list, then stop the server
7. **Update `PLAN.md`:**
   - Remove the finished Phase 2 entries.
   - Add this under Phase 5:
     ```
     - Note (2026-11-23): Redis cache + admin dashboard were requested during Phase 2 and deferred here. T5.1/T5.2 need a model before they're built.
     ```
8. **No `git commit`**, since you didn't ask for one.

**Final report:** Phase 2 is done. It lists the files changed (`app/jobs.py`, `app/routes.py`, `tests/test_jobs.py`, `PLAN.md`), the pytest, lint and typecheck output, the observed `curl` response, and any deviations. The Redis cache and admin dashboard are still waiting in Phase 5.