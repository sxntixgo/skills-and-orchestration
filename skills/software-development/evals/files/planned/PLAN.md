# Plan: job board API

## Phase 2 — List endpoint
Done when: `GET /jobs` returns 200 with a JSON list of open jobs; `pytest tests/test_jobs.py` passes.
- T2.1 (model: sonnet) Add `list_open_jobs()` in `app/jobs.py` + tests.
- T2.2 (model: sonnet) Add the `GET /jobs` route in `app/routes.py` + tests.

## Phase 3 — Search
Done when: `GET /jobs?q=<text>` filters by title (case-insensitive); empty `q` returns all;
`pytest tests/test_search.py` passes; ruff and mypy clean.
- T3.1 (model: haiku) Add `q` parsing to the route.
- T3.2 (model: opus) Design and implement the title-matching function in `app/search.py`
  (unicode case folding, ranking exact matches first).

## Phase 5 — Scale
- T5.1 Add a Redis cache for `GET /jobs`.
- T5.2 Admin dashboard for job moderation.
