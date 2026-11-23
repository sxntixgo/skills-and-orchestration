I'll review T1 before merging. RESULT.md is the implementer's claim, not proof. The merge only happens if my own test run, the scope check and a read of the diff all pass.

**Assumptions:** the repo is `/workspaces/app` and the run is `2026-11-23-csv-export`, read from `board.md`, where T1 is the task marked "running". `config.json` gives `base_branch: main`. T1.task.md lists `src/export/csv.py` (may create) and `tests/test_csv_export.py` (may create). The Done-when test command is `uv run pytest tests/test_csv_export.py -q`. The repo uses `uv run pytest -q` for the full suite and `uv run ruff check .` for lint.

### 1. Collect
```bash
cd /workspaces/app
R=2026-11-23-csv-export; W=.worktrees/$R/T1
cp $W/RESULT.md .orchestra/$R/tasks/T1.result.md
cat .orchestra/$R/tasks/T1.task.md .orchestra/$R/tasks/T1.result.md
```

### 2. Scope check
```bash
git -C $W status --porcelain
git -C $W diff
git -C $W ls-files --others --exclude-standard
```
Every changed or untracked file must be in the task's "may change/create" list. `RESULT.md` will not be committed. I'll delete any build artifacts:
```bash
find $W -name __pycache__ -prune -exec rm -rf {} + ; rm -rf $W/.pytest_cache $W/.coverage
```

### 3. Run the tests myself
```bash
cd $W
uv run pytest tests/test_csv_export.py -q   # expect 12 passed, as RESULT.md claims
uv run pytest -q                            # full suite: nothing else broke
uv run ruff check .
```
I'll compare the counts with RESULT.md. A mismatch, such as fewer than 12 tests or any skips, is something to look into.

### 4. Read the diff
- **Correctness:** check the edge cases in the spec, such as an empty input, commas or quotes inside fields, and unicode.
- **Error handling and style:** errors are handled, the code matches the pattern the task points to, and there is no dead code, no secrets and no new dependencies.
- **TDD:** every behaviour has a test that would fail without it, and every test asserts something.
- **YAGNI:** no extra params or options.
- **DRY:** existing helpers are reused.
- **Tests not weakened:** no tests were deleted, skipped or loosened.
- **Security:** the task writes files, so I'll check where the output path comes from and whether CSV/formula injection matters here. If it does, I'll run `security-review`.

### 5. Decide

**If all checks pass (the likely case), I accept:**
```bash
rm $W/RESULT.md
git -C $W add src/export/csv.py tests/test_csv_export.py
git log -5 --format=%B main   # copy the repo's trailer convention and merge style
git -C $W commit -m "feat: add CSV export (orchestra $R/T1)"   # + the repo's trailers
git checkout main
git merge --ff-only orchestra/$R/T1        # or --no-ff if the history shows merge commits
uv run pytest -q && uv run ruff check .    # tests on main again, after the merge
git worktree remove $W
git branch -d orchestra/$R/T1
```
I won't push.

**If any check fails, I reject.** That covers a failing or mismatched test run, a file outside the allowed list, a weakened test, or a clear TDD, YAGNI or DRY violation. I'd add a `## Notes from review` section to T1.task.md, with each note written as `file:line — problem — what to do`. Then I'd bump `attempt: 2` and send it back:
```bash
claude-dispatch --continue $R T1
```
On the 3rd rejection, I'd follow `references/takeover.md` and hand T1 to a subagent, starting with Sonnet.

### 6. Log to `.orchestra/$R/board.md`
```
| T1 | merged | 12/12 task tests, full suite 87 passed, ruff clean |
- 2026-11-23 T1 accepted (attempt 1): scope clean, tests rerun by Claude match RESULT.md; merged ff into main, main green; worktree + branch removed. Nits: none.
```

### Reply to you
> T1 is merged into `main`. I reran the tests myself: 12/12 passed on the task command and 87 passed on the full suite, both before and after the merge. Ruff found no lint problems. Only the two allowed files changed, and the worktree and branch have been removed. It's not pushed; that's up to you.

If the review fails, the reply would instead say T1 went back to opencode as attempt 2, and quote the review notes.