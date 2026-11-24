Phase 3 is in `PLAN.md`, so I'd go ahead and build it. T3.2 (opus) runs on me, since this session is Opus. T3.1 (haiku) goes to a Haiku subagent. Phase 5 stays out of scope. These are the steps in order.

### 1. Read the plan and restate the goal
- Read `PLAN.md` § Phase 3. **Done when:** `GET /jobs?q=<text>` filters by title, case-insensitive; an empty `q` returns all jobs; `pytest tests/test_search.py` passes; `ruff` and `mypy` are clean.
- Read `app/routes.py`, `app/jobs.py` and `tests/test_jobs.py` from Phase 2 to copy their patterns.
- **What I assume they contain:** a FastAPI app; `list_open_jobs() -> list[dict]` returning jobs that each have a `"title"`; tests using `TestClient`.
- TodoWrite items:
  1. Phase 3 scope
  2. T3.2 search function (TDD)
  3. T3.1 route `q` (Haiku subagent)
  4. Cleanup (DRY/YAGNI/KISS)
  5. Run everything
  6. Update `PLAN.md`
- Notes go in `./.claude-skills-work/software-development/phase-3/notes.md`. They record the done-criteria, the model assignments, the assumptions below, and "Phase 5 (Redis, admin dashboard) out of scope".

### 2. Assumptions I'd state and build on
- `q` is stripped of surrounding spaces, so a whitespace-only `q` counts as empty and returns everything.
- Matching is a substring match on the title after Unicode NFC normalisation plus `casefold()`. This makes "STRASSE" match "Straße", and an "é" typed as one character match one typed as two.
- **Ranking:** titles that match `q` exactly come first. Otherwise the original order is kept (a stable sort).
- Any `q` value is a valid filter, so the endpoint never returns 400 for it.

### 3. T3.2: build it myself, tests first
First I'd write `tests/test_search.py` with only the function tests (each test checks one behaviour):
- an empty `q` returns all jobs in their original order
- a whitespace-only `q` returns all jobs
- matching ignores case (`"python"` matches `"Senior Python Dev"`)
- no match returns `[]`
- an empty job list returns `[]`
- a single job, both matching and not matching
- an exact title match ranks before partial matches
- jobs that rank the same keep their original order
- `"STRASSE"` matches `"Straße"`
- a decomposed `"e\u0301"` matches a title with a composed `"é"`

Next I'd run `pytest tests/test_search.py` and expect it to fail with an `ImportError` (red). Then I'd write `app/search.py`:

```python
import unicodedata
from typing import Any

Job = dict[str, Any]


def _fold(text: str) -> str:
    return unicodedata.normalize("NFC", text).casefold()


def search_jobs(jobs: list[Job], q: str) -> list[Job]:
    """Jobs whose title contains q (Unicode case-insensitive); exact title matches first."""
    needle = _fold(q.strip())
    if not needle:
        return list(jobs)
    matches = [job for job in jobs if needle in _fold(job["title"])]
    return sorted(matches, key=lambda job: _fold(job["title"]) != needle)
```

Then I'd rerun the tests until they pass (green).

### 4. T3.1: Haiku subagent
I'd spawn it with the Agent tool, `model: "haiku"` and this prompt:

> Implement task T3.1 of Phase 3 in this repo, and nothing else. In `app/routes.py`, give the existing `GET /jobs` handler an optional query parameter `q: str = ""`. Return `search_jobs(list_open_jobs(), q)` from `app.search` (it already exists and is tested; don't change it). Keep the handler thin, and follow the existing route and test style in `tests/test_jobs.py`.
>
> Work test-first. Add these route tests to `tests/test_search.py`:
> - `GET /jobs` with no `q` returns 200 and all open jobs
> - `?q=` returns 200 and all jobs
> - `?q=python` returns 200 and only matching titles
> - `?q=PYTHON` returns the same result
> - `?q=zzz` returns 200 and `[]`
>
> Fake `list_open_jobs` the same way Phase 2's tests do. Run them and confirm they fail, then implement. Then run `pytest`, `ruff check .` and `mypy app`. Don't commit. Report the files you changed, the commands you ran, and their output.

### 5. Cleanup, run and verify
- **Review:** check the subagent's diff. The route should do no folding or filtering of its own (DRY), and there should be no extra parameters such as a sort option (YAGNI).
- **Run:** `pytest` (the whole suite), `ruff check .` and `mypy app`.
- **Real behaviour:** start `uvicorn app.main:app --port 8001 &` and run `curl -s 'localhost:8001/jobs?q=python'`, `curl -s 'localhost:8001/jobs?q='` and `curl -s 'localhost:8001/jobs?q=STRASSE'`. Check the filtering and the order, then `kill` the server.
- Log the commands and their output in the notes.

### 6. Update `PLAN.md` (no commit)
- Remove the T3.1 and T3.2 entries and mark Phase 3 as done.
- Leave Phase 5 untouched.
- Don't run `git commit`.

### Final reply to you
> **Phase 3 (Search) is built.** `GET /jobs?q=` now filters by title. Matching ignores case using Unicode case folding plus NFC normalisation, exact title matches are listed first, and an empty or whitespace-only `q` returns every job.
>
> - **T3.2:** I built `app/search.py` myself, on Opus as the plan assigns.
> - **T3.1:** a Haiku subagent added `q` to the route in `app/routes.py`.
> - **Tests:** all in `tests/test_search.py`, written before the code.
> - **Checks:** `pytest`, `ruff check .` and `mypy app` all pass, and I checked the endpoint with curl.
>
> **Assumptions:**
> - `q` is stripped, so a whitespace-only `q` returns everything.
> - Matching is a substring match on the title.
> - Jobs that rank the same keep their original order.
>
> `PLAN.md` now marks Phase 3 as done. I haven't touched Phase 5 (Redis cache, admin dashboard) or committed anything.