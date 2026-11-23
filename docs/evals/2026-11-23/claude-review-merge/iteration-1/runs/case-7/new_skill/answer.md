Assumed state: run `2026-11-23-csv`, T2 = "Parse uploaded jobs CSV into `JobRow` records", `attempt: 1`, `review: opus` (it parses input). Allowed files: `jobs/importers/csv_import.py` and `tests/importers/test_csv_import.py`. Done when: `uv run pytest tests/importers/test_csv_import.py -q`. `config.json` has `base_branch: main`, `max_rejections: 3`, `test_cmd: uv run pytest -q` and `lint_cmd: uv run ruff check .`. opencode has finished and left `RESULT.md`.

**1. Collect**
```bash
cd /workspaces/jobs
cp .worktrees/2026-11-23-csv/T2/RESULT.md .orchestra/2026-11-23-csv/tasks/T2.result.md
cat .orchestra/2026-11-23-csv/tasks/T2.task.md .orchestra/2026-11-23-csv/tasks/T2.result.md
```
I read the goal, the allowed files, "Done when", "Out of scope" and the `attempt` number, plus what opencode says it did: status `done`, "8 passed", no deviations.

**2. Mechanical checks**
```bash
bash /workspaces/jobs/<plugin>/skills/claude-review-merge/scripts/review-check.sh 2026-11-23-csv T2
```
Assumed output:
```
SCOPE ok
DIFF tracked: 1 file changed, 42 insertions(+), 3 deletions(-); new files: 1
TASK pass: 8 passed in 0.31s
SUITE pass: 214 passed in 6.02s
LINT pass: All checks passed!
CHECK T2 scope=ok result=yes task=pass suite=pass lint=pass
```
These match what RESULT.md claims (8 passed). If they hadn't:
- **`scope=N-out` with only `__pycache__/` or `.pytest_cache/`:** I'd delete them and rerun.
- **Any other `scope=N-out`:** reject.
- **`task=none`:** report a spec bug.
- **`task`, `suite` or `lint` failing:** reject, quoting the tail the script printed.

**3. Read the diff**
```bash
git -C .worktrees/2026-11-23-csv/T2 diff
git -C .worktrees/2026-11-23-csv/T2 ls-files --others --exclude-standard | grep -vx RESULT.md | xargs -I{} cat .worktrees/2026-11-23-csv/T2/{}
```
Checklist:
- **Correctness and edge cases from the spec:** empty file, header-only file, missing required column, BOM, quoted commas and blank lines.
- **Error handling:** errors raise the repo's existing `ImportError`-style exception with the row number.
- **Pattern:** follows the existing importer the task cites.
- **Hygiene:** no new dependencies (stdlib `csv` only), no dead code, no secrets.
- **TDD:** each behaviour has a test with real assertions, and no tests were weakened or skipped.
- **YAGNI:** no unused `delimiter=` or `encoding=` options.
- **DRY:** reuses the existing date and field helpers.
- **Security review** (input parsing): unbounded file read, formula-injection pass-through if the data is re-exported later (out of scope, so I'd only note it), and path handling.

Assumed finding: everything in "Done when" holds. One nit: the local variable `r` should be `row`. That's a nit, so I accept and note it.

**4. Accept**
```bash
cd /workspaces/jobs/.worktrees/2026-11-23-csv/T2
rm RESULT.md
git add jobs/importers/csv_import.py tests/importers/test_csv_import.py
git commit -m "feat: parse uploaded jobs CSV into JobRow records (orchestra 2026-11-23-csv/T2)" \
  -m "<repo's trailers per CLAUDE.md>"
cd /workspaces/jobs
git switch main
git merge --no-ff orchestra/2026-11-23-csv/T2   # or --ff-only, whichever the repo's history uses
uv run pytest -q 2>&1 | tail -1                 # one summary line: 222 passed
git worktree remove .worktrees/2026-11-23-csv/T2
git branch -d orchestra/2026-11-23-csv/T2
```
No push.

**If I had rejected instead:** I'd append this to `T2.task.md`, set `attempt: 2`, and leave the worktree in place for `claude-dispatch --continue`:
```markdown
## Notes from review
- jobs/importers/csv_import.py:31 — header-only file returns None instead of [] — return an empty list; add test_header_only_returns_empty
```
If it were the 3rd rejection, or a spec or design flaw, I'd reply TAKEOVER. The orchestrator would then spawn an `opus` subagent for this task, because it is input parsing (otherwise `sonnet`), with the prompt from `references/takeover.md`.

**5. Log** (append to `.orchestra/2026-11-23-csv/board.md`; I'd also set T2's row to `merged`)
```
- 2026-11-23 T2 MERGED a1b2c3d (attempt 1) — task 8 passed, suite 214→222 passed on main, lint ok, scope ok. Nit: csv_import.py `r` → `row`. Security: input parsing reviewed, no issues.
```

**6. Reply to the orchestrator**
```
MERGED T2 a1b2c3d tests=222 passed
```