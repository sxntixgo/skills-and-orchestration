**Verdict (dry run, using the assumptions below): reject T2 and send it back as attempt 2.** The task's own tests pass, but one "Done when" item isn't met, the change is out of scope, and it adds a dependency the task didn't name.

**Assumptions** (nothing exists on disk):
- `.orchestra/config.json` uses the defaults: `base_branch: main`, `max_rejections: 3`.
- T2 is on attempt 1. Its goal is "Parse uploaded jobs CSV into `Job` records".
- T2 may change `src/jobs/csv_import.py` and `tests/test_csv_import.py`.
- Its Done when items are: `uv run pytest tests/test_csv_import.py -q` passes, and a missing required column raises `CsvImportError` naming the column.
- RESULT.md says `status: done` with 5 passed.
- The worktree contains:
  - `csv_import.py` and its test changed
  - an untracked `__pycache__/`
  - `pyproject.toml` modified to add `pandas`
- No test covers the missing-column case. The code raises `KeyError` on line 31.

## 1. Collect
```bash
cd /workspaces/jobs
cat .orchestra/config.json
cp .worktrees/2026-11-23-csv/T2/RESULT.md .orchestra/2026-11-23-csv/tasks/T2.result.md
cat .orchestra/2026-11-23-csv/tasks/T2.task.md .orchestra/2026-11-23-csv/tasks/T2.result.md
```

## 2. Check scope
```bash
git -C .worktrees/2026-11-23-csv/T2 status --porcelain --untracked-files=all
git -C .worktrees/2026-11-23-csv/T2 diff
git -C .worktrees/2026-11-23-csv/T2 diff main...HEAD --stat   # confirm branch is on current main
cat .worktrees/2026-11-23-csv/T2/tests/test_csv_import.py   # untracked/new parts
```
- `__pycache__/` is a build artifact, not a violation. I'd delete it before any commit: `find .worktrees/2026-11-23-csv/T2 -name __pycache__ -prune -exec rm -rf {} +`
- The `pyproject.toml` change is a scope violation. It also adds a dependency (`pandas`) that the task never named, and `csv` from the standard library is enough.

## 3. Run the checks myself
```bash
cd /workspaces/jobs/.worktrees/2026-11-23-csv/T2
uv run pytest tests/test_csv_import.py -q    # assumed: 5 passed (matches RESULT.md)
uv run pytest -q                             # assumed: 48 passed
uv run ruff check . && uv run mypy src       # if configured; assumed clean
```

## 4. Read the diff
- **Correctness:** a missing column ends in `KeyError` at `src/jobs/csv_import.py:31`, which fails the second Done when item.
- **TDD:** no test covers the missing-column case. The existing tests make real assertions and none were weakened.
- **YAGNI:** `parse_rows(..., delimiter=",", encoding="utf-8")` adds two options nothing uses, at `src/jobs/csv_import.py:12`.
- **DRY:** date parsing is copied from `src/jobs/dates.py:parse_date` instead of calling it, at `src/jobs/csv_import.py:40-47`.
- **Security:** this is file input, so I'd run `security-review` on the diff. Assumed: only the size and encoding handling above, nothing critical.

## 5. Reject
I append this to `.orchestra/2026-11-23-csv/tasks/T2.task.md` and change `attempt: 1` to `attempt: 2` in its frontmatter:
```markdown
## Notes from review
- pyproject.toml — adds `pandas`, file not in the allowed list and dep not named by the task — revert pyproject.toml; use stdlib `csv.DictReader`.
- src/jobs/csv_import.py:31 — missing required column raises KeyError, Done-when requires CsvImportError naming the column — check `reader.fieldnames` against REQUIRED_COLUMNS before iterating; raise `CsvImportError(f"missing column: {name}")`.
- tests/test_csv_import.py — no test for the missing-column case — add `test_missing_column_raises` first (it must fail on the current code), then fix.
- src/jobs/csv_import.py:12 — unused `delimiter`/`encoding` params (YAGNI) — remove them.
- src/jobs/csv_import.py:40-47 — copy of `parse_date` from src/jobs/dates.py — import and call `parse_date` instead.
```
Then I send it back to the implementer, using the same worktree and continuing the same session:
```bash
rm -rf $(find .worktrees/2026-11-23-csv/T2 -name __pycache__)
claude-dispatch --continue 2026-11-23-csv T2
```
I don't commit, merge, push or fix anything myself.

## 6. Log to `.orchestra/2026-11-23-csv/board.md`
```
- 2026-11-23 T2 attempt 1 — REJECTED. Task tests 5/5 pass, full suite 48 passed, lint clean.
  Reasons: out-of-scope pyproject.toml (+pandas), missing-column Done-when unmet (KeyError, no test),
  YAGNI params, duplicated parse_date. Sent back as attempt 2 (1/3 rejections).
```

**If the review had passed** (scope clean, Done when met):
```bash
rm RESULT.md
git add -A && git commit -m "feat: parse jobs CSV into Job records (orchestra 2026-11-23-csv/T2)"   # plus the repo's trailers
cd /workspaces/jobs && git checkout main && git merge --no-ff orchestra/2026-11-23-csv/T2   # or ff, per repo
uv run pytest -q
git worktree remove .worktrees/2026-11-23-csv/T2 && git branch -d orchestra/2026-11-23-csv/T2
```
I wouldn't push. On the third rejection I'd take the task over with a `sonnet` subagent, following `references/takeover.md`.

## Reply to the orchestrator
T2 is rejected and back with the implementer as attempt 2; that's 1 of 3 rejections. The task test passes 5/5, the full suite passes 48, and lint is clean. The reasons:
- `pyproject.toml` is outside the task's files and adds `pandas`.
- A missing column raises `KeyError` instead of `CsvImportError`, and no test covers that case.
- `parse_rows` has two unused parameters.
- Date parsing is copied from `dates.parse_date`.

The notes are in `T2.task.md` and the board is updated. Nothing was merged or pushed.