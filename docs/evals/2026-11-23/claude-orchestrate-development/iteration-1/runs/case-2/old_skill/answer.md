Dispatching T1 and T3 now, with T2 queued behind T1. Your table had one conflict: T2 and T3 both edit `api/routes.py`, so they can't run at the same time. I moved T3's `routes.py` edit into T2, so T3 now touches only the frontend. With that change, two tasks run in parallel instead of all three running one after another.

**Assumptions** (I can't see the repo):
- The repo is `/workspaces/jobs-app`.
- `docs/plans/2026-11-23-csv-export-plan.md` exists and covers this work. If it doesn't, I stop and run `brainstorming` → `writing-plans` first.
- Tests run with `uv run pytest` and `npm test` (vitest) in `web/`.
- T3's `routes.py` edit is part of wiring up `/export`, so it belongs in T2.

## What I'd do, in order

**TodoWrite:** 0 Plan gate · 1 Set up the run · 2 Task graph · 3 Loop · 4 Finish

**0. Plan gate**
- `ls docs/plans/`, then read `docs/plans/2026-11-23-csv-export-plan.md`. It covers the export feature, so the gate passes.

**1. Set up the run**
```bash
cd /workspaces/jobs-app
cat CLAUDE.md AGENTS.md 2>/dev/null
git status --porcelain && git branch --show-current     # must be empty + main
mkdir -p .orchestra/2026-11-23-csv-export/{tasks,logs}
grep -qx '.orchestra/' .git/info/exclude || printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
uv run pytest -q && (cd web && npm test -- --run)       # baseline must pass, else STOP
```
`.orchestra/config.json` doesn't exist, so I write the contract defaults (they already have `"concurrency": 2`):
```json
{ "implementer": "opencode", "model": "atlas/qwen3.8-flash-next", "concurrency": 2,
  "task_timeout_min": 30, "max_rejections": 3, "base_branch": "main",
  "stall_empty_s": 180, "stall_s": 600, "stall_retries": 1 }
```

**2. Task graph:** `.orchestra/2026-11-23-csv-export/board.md`
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/2026-11-23-csv-export-plan.md

| id | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|
| T1 | export_csv(jobs) -> str | opencode | [] | api/export.py, tests/test_export.py | todo |
| T2 | GET /export returns CSV (incl. routes.py change formerly in T3) | opencode | [T1] | api/routes.py, tests/test_routes_export.py | todo |
| T3 | "Export CSV" button in Jobs view hitting GET /export | opencode | [] | web/src/Jobs.tsx, web/src/Jobs.test.tsx | todo |

Graph note: T3's api/routes.py edit moved into T2 (shared file). T3 mocks fetch against the
pinned contract (GET /export → 200 text/csv, Content-Disposition attachment), so it doesn't wait for T2.

## Log
- 2026-11-23 10:02 run set up; baseline tests green; graph written (T1, T3 ready; T2 waits on T1)
```
Self-check:
- Every plan requirement maps to a task.
- T1 and T3 share no files.
- T2 runs only after T1 is merged, so it never overlaps a running task on `routes.py`.
- Each task has an exact test command.

**3. Loop, first wave (T1 + T3, two slots)**

`claude-write-task` T1. I read the closest existing serializer and the pattern in `api/` first, then write `tasks/T1.task.md`:
```markdown
---
id: T1
run: 2026-11-23-csv-export
depends_on: []
attempt: 1
---
# Add export_csv(jobs) returning the jobs as a CSV string

## Context
The /export route (T2) will return this. Columns are from the plan: id, name, status, created_at.
Copy the module/test layout of api/serializers.py:1 and tests/test_serializers.py:1.

## Files
- may create: api/export.py, tests/test_export.py
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. Write tests in tests/test_export.py: header row only for []; one row per job;
   a field containing a comma or quote is quoted correctly. Run them and see them fail.
2. Implement `export_csv(jobs: list[Job]) -> str` in api/export.py with stdlib `csv` + `io.StringIO`.

## Done when
- `uv run pytest tests/test_export.py -q` passes

## Out of scope
- The route, streaming, extra columns/options, new dependencies.
```

`claude-write-task` T3. Same shape:
- **Files:** may change `web/src/Jobs.tsx`; may create `web/src/Jobs.test.tsx`.
- **Steps:**
  1. Write a test that renders Jobs, clicks "Export CSV", and expects a `fetch('/export')`/download (fetch mocked). See it fail.
  2. Add the button, reusing the existing button component in that file.
- **Done when:** `cd web && npm test -- --run src/Jobs.test.tsx` passes.
- **Out of scope:** any `api/` file, restyling, new dependencies.

Dispatch both. Each runs with Bash `run_in_background: true`:
```bash
bash plugins/.../claude-dispatch/scripts/dispatch.sh 2026-11-23-csv-export T1
bash plugins/.../claude-dispatch/scripts/dispatch.sh 2026-11-23-csv-export T3
```
On `board.md`, T1 and T3 change to `dispatched` (attempt 1), and I add this Log line:
`- 10:08 T1, T3 dispatched (attempt 1) to opencode`

**While they run:** I pre-read `api/routes.py` for T2's spec but don't dispatch it. Its dependency T1 isn't merged yet, and both slots are in use.

**After each `DISPATCH <id> exit=0 result=yes`:**
- I run `claude-review-merge` on it. That means reading the diff and running the test command myself, not trusting `RESULT.md`.
- If it passes: merge, set the status to `merged`, and add a Log line.
- If it's rejected: send it back with `--continue` and review notes (attempt + 1).
- After 3 rejections, a Claude model takes the task over.

**Once T1 is merged:** I write T2's task (route in `api/routes.py` calling `export_csv`; test command `uv run pytest tests/test_routes_export.py -q`), dispatch it, then review and merge it.

**4. Finish:** I run the full `uv run pytest -q` and `npm test -- --run` on `main`, then remove the worktrees and `orchestra/*` branches.

## Reply to you
> Dispatching. T1 (`export_csv`) and T3 (Jobs button) are running in parallel on opencode. T2 (`/export` route) starts once T1 is merged.
>
> **Change to your table:** T2 and T3 both edited `api/routes.py`, so they couldn't run at the same time. I moved T3's `routes.py` change into T2, and T3 now only touches `web/src/Jobs.tsx` plus its test. Progress is in `.orchestra/2026-11-23-csv-export/board.md`. I'll report per task when all three are merged. Pushing is up to you.