I'd orchestrate this as a three-task run: the plan exists, so the plan gate passes and I go straight to setup without asking you to approve the task graph.

**Assumptions** (I can't see the repo): `docs/plans/csv-export.md` covers four things:
- `GET /jobs/export.csv` honours the list endpoint's filters (`status`, `created_from`, `created_to`).
- Columns are `id,title,company,status,created_at`.
- Cells starting with `= + - @` are neutralised so spreadsheets don't run them as formulas.
- The jobs list page gets an "Export CSV" button.

The stack is FastAPI and SQLAlchemy, tested with `uv run pytest`, plus a React frontend tested with `npm test`. `base_branch` is `main`, and there's no `.orchestra/config.json` yet.

## 1. TodoWrite
0 Plan gate · 1 Set up run · 2 Task graph · 3 Loop (write → dispatch → review → merge) · 4 Finish/report

## 2. Plan gate
`docs/plans/csv-export.md` exists and covers the work → pass. Mark the todo done.

## 3. Set up the run (`run = 2026-11-23-csv-export`)
```bash
cd /workspaces/jobs
cat docs/plans/csv-export.md CLAUDE.md AGENTS.md 2>/dev/null
git status --porcelain && git rev-parse --abbrev-ref HEAD     # must be empty / main
mkdir -p .orchestra/2026-11-23-csv-export/{tasks,logs}
grep -qx '.orchestra/' .git/info/exclude || printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
uv run pytest -q && (cd frontend && npm test -- --run)          # baseline must be green
```
Then I'd write `.orchestra/config.json` with the contract defaults: `implementer` opencode, `model` atlas/qwen3.8-flash-next, `concurrency` 2, `task_timeout_min` 30, `max_rejections` 3, `base_branch` main, `stall_empty_s` 180, `stall_s` 600, `stall_retries` 1.

⛔ If the tree is dirty, the branch isn't `main`, or the baseline tests fail, I stop and tell you.

## 4. `board.md`
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/csv-export.md

| id | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|
| T1 | `jobs_to_csv(rows) -> str` with column order + formula-injection escaping | opencode | [] | app/jobs/csv_export.py, tests/jobs/test_csv_export.py | todo |
| T2 | `GET /jobs/export.csv` using list filters + T1, `text/csv` + attachment header | opencode | [T1] | app/jobs/routes.py, tests/jobs/test_export_route.py | todo |
| T3 | "Export CSV" button on jobs list linking to `/jobs/export.csv?<current filters>` | opencode | [] | frontend/src/jobs/JobsList.tsx, frontend/src/jobs/JobsList.test.tsx | todo |

## Log
```
Self-check:
- Every requirement maps to a task:
  - columns and escaping → T1
  - filters and endpoint → T2
  - button → T3
- T1 and T3 have disjoint files, so both run at once (concurrency 2).
- T2 waits only on T1, because it reuses T1's code.
- Every task has an exact test command.
- The filter logic already exists in the list endpoint. T2 reuses that query helper rather than copying it.

## 5. Loop

**Round 1: T1 and T3 in parallel.**
- `claude-write-task` writes T1 and T3. For each, I'd open the closest pattern, run its test command once to see it fail, and save the file. T1 looks like this:
  ```markdown
  ---
  id: T1
  run: 2026-11-23-csv-export
  depends_on: []
  attempt: 1
  ---
  # Add jobs_to_csv(rows) that serialises jobs to CSV text

  ## Context
  The CSV export (docs/plans/csv-export.md) needs one serialiser shared by the endpoint (T2).
  Copy the module layout of app/jobs/serializers.py:1-30. Use the stdlib `csv` module, no new deps.

  ## Files
  - may create: app/jobs/csv_export.py, tests/jobs/test_csv_export.py
  - must NOT touch: everything else (and never .orchestra/, .git/)

  ## Steps
  1. Write these tests first and see them fail:
     - header row `id,title,company,status,created_at`
     - one job → one row, `created_at` in ISO 8601
     - a title containing a comma and a quote is quoted correctly
     - a cell starting with `=`, `+`, `-` or `@` is prefixed with `'`
     - an empty list → header only
  2. Implement `jobs_to_csv(rows: Iterable[Job]) -> str` using `csv.writer` on `io.StringIO`, with a private `_safe(value) -> str` for the prefix.

  ## Done when
  - `uv run pytest tests/jobs/test_csv_export.py -q` passes

  ## Out of scope
  - Streaming, extra columns, config options, touching routes
  ```
- `claude-dispatch`, both run in the background:
  ```bash
  bash plugins/.../claude-dispatch/scripts/dispatch.sh 2026-11-23-csv-export T1   # run_in_background
  bash plugins/.../claude-dispatch/scripts/dispatch.sh 2026-11-23-csv-export T3   # run_in_background
  ```
- On `board.md`, T1 and T3 go to `dispatched (attempt 1)`.
  - Log: `10:05 T1 dispatched a1` and `10:05 T3 dispatched a1`
- While they run I'd draft T2's spec; it's saved but not dispatched yet.

**Each `DISPATCH <id> exit=0 result=yes` line** → `claude-review-merge`:
```bash
cp .worktrees/2026-11-23-csv-export/T1/RESULT.md .orchestra/2026-11-23-csv-export/tasks/T1.result.md
git -C .worktrees/2026-11-23-csv-export/T1 status --porcelain; git -C ... diff
(cd .worktrees/2026-11-23-csv-export/T1 && uv run pytest tests/jobs/test_csv_export.py -q && uv run pytest -q && uv run ruff check .)
```
- I'd read the diff for TDD, YAGNI, DRY and scope. T1 also gets a `security-review` for the formula-injection guard.
- **Accept:**
  ```bash
  rm RESULT.md
  git commit -am "feat: jobs_to_csv serialiser (orchestra 2026-11-23-csv-export/T1)"
  git checkout main && git merge --no-ff orchestra/2026-11-23-csv-export/T1
  uv run pytest -q
  git worktree remove .worktrees/2026-11-23-csv-export/T1
  git branch -d orchestra/2026-11-23-csv-export/T1
  ```
  - Log: `10:21 T1 merged a1 — 6 passed, full suite 148 passed`
- **Reject:** I'd add `## Notes from review` to the task, written as `file:line — problem — fix`, bump `attempt`, then run `dispatch.sh ... T1 --continue`.
  - Log: `T1 sent-back a2 — <reason>`
- **Third rejection:** the task is taken over by a Sonnet subagent working in the same worktree. Its prompt contains:
  - the absolute worktree path and "don't commit, push or switch branches"
  - the full task.md and all review notes
  - what earlier attempts got wrong
  - the TDD, YAGNI and DRY rules
  - "run the test command until it passes; reply with files changed, the command, and the last ~20 lines of output"

  I review its work the same way.
  - Log: `T1 taken-over (sonnet)`

**Round 2: T2,** as soon as T1 is merged. I'd refresh the spec against `main` and dispatch it (`board.md` updated). Its test command is `uv run pytest tests/jobs/test_export_route.py -q`, and it gets the same review, with `security-review` for the query-param input. T3 is reviewed and merged whenever it finishes, using `cd frontend && npm test -- --run src/jobs/JobsList.test.tsx` plus lint and typecheck.

**Dispatch failures:**
- exit 3: wait for a free slot.
- exit 4 or 125 with atlas down: pause and tell you.
- exit 124: split the task or take it over.

## 6. Finish
```bash
git checkout main && uv run pytest -q && (cd frontend && npm test -- --run && npm run lint && npm run typecheck)
git worktree list; git branch --list 'orchestra/*'    # both must be empty of run items
```

## Final message (example)
> **CSV export is built and merged into `main` (not pushed).** All 3 tasks are merged and the full suite passes on `main`: backend 155 passed, frontend 42 passed.
>
> | Task | Outcome | Commit |
> |---|---|---|
> | T1 `jobs_to_csv` | opencode, first try | `a1b2c3d` |
> | T3 Export button | opencode, first try | `d4e5f6a` |
> | T2 `/jobs/export.csv` | opencode after 1 send-back (it had copied the filter query instead of reusing the list endpoint's helper) | `b7c8d9e` |
>
> No worktrees or `orchestra/*` branches are left.
>
> **What's left for you:**
> - Push `main` (or open a PR) and deploy.
> - Follow-up: export of very large job lists isn't streamed. The plan left that out of scope, so I did too.
>
> The run log is in `.orchestra/2026-11-23-csv-export/board.md`.