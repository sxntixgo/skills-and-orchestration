Phase 2 isn't wrapped up yet. Passing tests don't count as done until I've run the full checks and the real endpoint. Here's the order I'd follow:

**1. Re-check the done-criteria** in `PLAN.md` Phase 2: `GET /jobs` returns 200 with a JSON list of open jobs, and `pytest tests/test_jobs.py` passes. T2.1 and T2.2 were both assigned to sonnet. I'm assuming they ran on sonnet (or a sonnet subagent). If either one didn't, I'd say so in the report.

**2. Run the full checks, not just the Phase 2 file:**
```bash
pytest                       # whole suite, not only tests/test_jobs.py
ruff check . && mypy app     # assuming the repo uses these (Phase 3 names them)
```

**3. Run the real behaviour.** I'm assuming a FastAPI/uvicorn app; I'd use the repo's actual entrypoint:
```bash
uvicorn app.main:app --port 8000 & PID=$!
sleep 2
curl -s -i http://localhost:8000/jobs        # expect 200, JSON array, only open jobs
kill $PID                                    # don't leave the dev server running
```
I'd check that closed jobs are excluded and that an empty DB returns `[]` with a 200.

**4. Update `PLAN.md`:** remove the finished Phase 2 section. Phases 3 and 5 stay as they are. I wouldn't pull any Phase 3 or 5 work in. Phase 5's T5.1 and T5.2 have no model assigned, so I'd flag that rather than invent one. The file would then read:
```markdown
# Plan: job board API

## Phase 3 — Search
Done when: `GET /jobs?q=<text>` filters by title (case-insensitive); empty `q` returns all;
`pytest tests/test_search.py` passes; ruff and mypy clean.
- T3.1 (model: haiku) Add `q` parsing to the route.
- T3.2 (model: opus) Design and implement the title-matching function in `app/search.py`
  (unicode case folding, ranking exact matches first).

## Phase 5 — Scale
- T5.1 Add a Redis cache for `GET /jobs`.
- T5.2 Admin dashboard for job moderation.
```

**5. Log** a wrap-up note in `./.claude-skills-work/software-development/phase-2/notes.md`: files changed, commands run with their results, and deviations from the plan.

**6. No `git commit`**, since you didn't ask for one.

**Reply to you:**

> Phase 2 is done. The full `pytest` suite passes, ruff and mypy are clean, and a real `GET /jobs` returned 200 with only open jobs (`[]` when empty). Files changed: `app/jobs.py`, `app/routes.py`, `tests/test_jobs.py` and `PLAN.md`. I removed Phase 2 from `PLAN.md`. No deviations from the plan, and nothing is committed; I'll commit if you want me to. Phase 5's T5.1 and T5.2 have no model assigned, so tell me which model each should use before that phase starts. Next up is Phase 3: T3.1 on haiku and T3.2 on opus.

If any check fails, or the real call doesn't return what the plan says, I'd report the full output and leave Phase 2 in the plan instead of claiming it's done.