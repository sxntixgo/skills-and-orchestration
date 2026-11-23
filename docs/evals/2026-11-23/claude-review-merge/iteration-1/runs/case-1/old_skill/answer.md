T1 gets merged only if my own checks pass. RESULT.md is just opencode's claim, so I re-run the tests and read the diff before merging. Below is what I'd do, in order.

**Assumptions** (I can't see any of this):
- Repo is `/workspaces/app`, active run is `2026-11-23-csv-export`, and `.orchestra/config.json` uses the defaults (`base_branch: main`, `max_rejections: 3`).
- `T1.task.md` says: may change `app/export.py`, `tests/test_export.py`. Done when: `uv run pytest tests/test_export.py -q` passes.
- The repo has `uv run pytest -q` and `uv run ruff check .`, and merges with `--no-ff`.
- This is attempt 1.

### 1. Collect
```bash
cd /workspaces/app
R=2026-11-23-csv-export; W=.worktrees/$R/T1
cp $W/RESULT.md .orchestra/$R/tasks/T1.result.md
cat .orchestra/$R/tasks/T1.task.md .orchestra/$R/tasks/T1.result.md
```
I note what RESULT.md claims: the test command, "12 passed", Deviations and Questions.

### 2. Scope check
```bash
git -C $W status --porcelain --untracked-files=all
git -C $W diff
git -C $W diff --stat
```
- Every changed or untracked file must be on the task's "may change/create" list.
- Untracked files are opened and read as well.
- Build artifacts like `__pycache__/` and `.pytest_cache/` get deleted; they aren't scope violations.
- `RESULT.md` must not be committed.

### 3. Run the checks myself
```bash
cd $W
uv run pytest tests/test_export.py -q
uv run pytest -q
uv run ruff check .
```
- I compare the count with the claimed "12 passed".
- I also check the diff hasn't deleted, skipped (`skip`/`xfail`) or weakened any tests to get there.

### 4. Read the diff
- **Code review:** correctness, the edge cases the spec names, error handling, fit with the existing pattern, no dead code, no secrets, no new dependencies.
- **TDD:** every behaviour change has a test that would fail without it, and every test has real assertions.
- **YAGNI:** no unused params, options or "just in case" branches.
- **DRY:** existing helpers are reused.
- If it touches input, files, auth or the network, I also run `security-review`.

### 5a. Accept (every "Done when" holds, tests green, scope clean)
```bash
cd /workspaces/app/$W
rm RESULT.md; find . -name __pycache__ -prune -exec rm -rf {} +
git add -A && git commit -m "feat: export orders as CSV (orchestra $R/T1)"   # + repo trailers
cd /workspaces/app && git checkout main
git merge --no-ff orchestra/$R/T1
uv run pytest -q && uv run ruff check .
git worktree remove $W && git branch -d orchestra/$R/T1
```
Small nits (naming, a comment) don't block the merge; I note them in the log. I don't edit opencode's code on accept, and I don't push.

### 5b. Reject (tests fail, count doesn't match, scope violation, weakened tests, or a principle clearly broken)
- I add `## Notes from review` to `T1.task.md`, one line per issue: `file:line — problem — what to do`.
- I bump `attempt: 2`.
- I send it back with `claude-dispatch --continue` and don't merge.

### 6. Log in `.orchestra/$R/board.md`
```
| T1 | merged | attempt 1 | task: 12 passed (claimed 12) · full: 148 passed · ruff clean · main green after merge |
2026-11-23 T1 accepted: diff in scope, Done-when met. Nits: <none|…>
```
For a rejection, the line records `rejected (1/3)` and the reason instead.

### Reply to the user
On accept:
> T1 merged into `main` (`--no-ff`). I re-ran the tests: 12/12 for the task and the full suite is green (148 passed), ruff is clean, and `main` is still green after the merge. The worktree and branch are removed. Nothing has been pushed.

On reject:
> T1 not merged. <reason, e.g. "`tests/test_export.py` has 12 passing tests but 2 of them have no assertions" / "it changed `app/models.py`, which is outside the task's files">. The notes are in `T1.task.md`, and it's back with opencode as attempt 2.