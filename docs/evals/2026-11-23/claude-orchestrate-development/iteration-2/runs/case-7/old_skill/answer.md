This is a resume, not a new run. The plan exists, so the plan gate passes. I'd review and merge T1 and T2, then continue the loop through phase 3 without asking for approval.

**Assumptions** (nothing on disk):
- Repo is `/workspaces/app`, `base_branch` is `main`, `concurrency` is 2, and tests run with `uv run pytest -q`.
- The run is `2026-11-23-export`. Its `board.md` covers phase 1 only: T1 and T2 are `dispatched`, T3 is `todo`.
- The phase 1 tasks are:
  - T1: CSV serializer `src/export/csv_writer.py` and its test.
  - T2: JSON serializer `src/export/json_writer.py` and its test.
  - T3: `GET /export` endpoint, which needs T1 and T2.
- Phase 2 adds filters and streaming for large exports. Phase 3 adds an export button in the UI.

## 1. Resume
```bash
cd /workspaces/app
cat .orchestra/2026-11-23-export/board.md
cat .orchestra/config.json                    # missing → contract defaults
git status --porcelain && git branch --show-current   # expect clean, main
ls .worktrees/2026-11-23-export/T1/RESULT.md .worktrees/2026-11-23-export/T2/RESULT.md
pgrep -af opencode                            # confirm both runs actually ended
```
- Re-read `docs/plans/2026-11-23-export-plan.md` and `CLAUDE.md`/`AGENTS.md`.
- If a RESULT.md is missing or opencode is still running, that task stays `dispatched` and I wait for it. I wouldn't trust "just came back" without checking.
- **Extend the task graph to phases 2–3** (my job, no approval needed). I'd add these rows to the table:

| id | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|
| T4 | `?from=&to=&fields=` filters for /export, plus tests | opencode | T3 | src/export/filters.py, src/api/export.py, tests/test_export_filters.py | todo |
| T5 | Stream large exports (generator response), plus test | opencode | T4 | src/api/export.py, tests/test_export_stream.py | todo |
| T6 | Export button and format picker in the UI, plus test | opencode | T3 | web/src/ExportButton.tsx, web/src/ExportButton.test.tsx | todo |

- **Self-check:**
  - Every plan requirement maps to a task.
  - T4 and T5 both edit `src/api/export.py`, so T5 depends on T4.
  - T6's files don't overlap T4/T5, so T6 can run alongside T4.
  - Every task has an exact test command.

## 2. Review T1 and T2 (`claude-review-merge`, one at a time)
For each `<id>`:
```bash
cp .worktrees/2026-11-23-export/<id>/RESULT.md .orchestra/2026-11-23-export/tasks/<id>.result.md
git -C .worktrees/2026-11-23-export/<id> status --porcelain
git -C .worktrees/2026-11-23-export/<id> diff        # + read untracked files
cd .worktrees/2026-11-23-export/<id>
uv run pytest tests/test_<csv|json>_writer.py -q     # task's exact command
uv run pytest -q && uv run ruff check .              # full suite + lint
```
- **Scope:** only the task's listed files changed. I'd delete `__pycache__/` and similar artifacts, and RESULT.md must not be committed.
- **Diff review:**
  - Correctness and spec edge cases (empty rows, quoting/escaping in CSV, unicode, dates in JSON).
  - TDD: each behaviour has a test that would fail without it.
  - YAGNI: no unused options.
  - DRY: T1 and T2 should share the existing row-fetch helper rather than each copying the query.
- **Accept** (shown for T1):
  ```bash
  rm RESULT.md
  git add -A && git commit -m "feat: CSV export serializer (orchestra 2026-11-23-export/T1)"
  cd /workspaces/app && git merge --no-ff orchestra/2026-11-23-export/T1
  uv run pytest -q
  git worktree remove .worktrees/2026-11-23-export/T1 && git branch -d orchestra/2026-11-23-export/T1
  ```
  T2 goes the same way after T1, re-running the suite on `main` after each merge.
- **Reject:** write `## Notes from review` into `tasks/<id>.task.md`, one line per problem in the form `file:line — problem — fix`. Then bump `attempt` to 2, run `claude-dispatch --continue`, and set the status to `sent-back`.
- Small nits: accept and note them in the log.

**`board.md` log lines** (example outcome):
```
- 2026-11-23 14:05 T1 review: accepted, 6 passed (task), 142 passed (suite) → merged a1b2c3d
- 2026-11-23 14:12 T2 review: rejected (attempt 1) — json_writer.py:22 datetimes not ISO-8601, no test for empty result → sent-back, attempt 2
- 2026-11-23 14:13 Graph extended with phases 2–3: T4, T5, T6
```

## 3. Continue the loop
- **T3 becomes ready only when both T1 and T2 are merged.** In the example above, T2 was sent back, so the only thing running is T2 attempt 2. One opencode slot is free, but no other task is ready yet: T4 and T6 need T3.
- Once T2 merges:
  1. Run `claude-write-task` for T3. That means reading `src/api/` for the closest existing endpoint to copy and pinning `uv run pytest tests/test_export_api.py -q` as the test command.
  2. Dispatch T3 with `claude-dispatch`. Status → `dispatched`, plus a log line.
- After T3 merges, T4 and T6 run in parallel (2 slots). T5 starts after T4.
- Each result goes through the same review and merge, with a log line after every status change.
- After 3 rejections of one task, `claude-review-merge` takes it over with the cheapest capable Claude model and marks it `taken-over`.

## 4. Finish
When every task is merged, taken over or dropped:
- Run `uv run pytest -q` on `main`.
- Confirm `git worktree list` and `git branch --list 'orchestra/*'` are both empty.

## Reply to the user (at this point)
> Picked up run `2026-11-23-export` and added phases 2–3 to the board as T4 (filters), T5 (streaming, after T4) and T6 (UI button, runs alongside T4).
>
> - **T1 (CSV writer):** merged on the first try. Suite: 142 passed on `main`.
> - **T2 (JSON writer):** sent back to opencode (attempt 2). Datetimes weren't ISO-8601 and there was no test for an empty result.
>
> T3 (`/export` endpoint) starts once T2 merges. I'll keep going and report per task at the end. Nothing is pushed; that's yours to do when the run finishes.