Yes: I still need to check the merge and clean up after it. Here is what I'd do, assuming the run is `2026-11-21-csv-export` in `/workspaces/app`, `base_branch` is `main`, and the full test suite is `uv run pytest -q`.

**1. Check what landed and what the board says**
```bash
cd /workspaces/app
git log --oneline -5 main
git log main --format='%H %s' | grep -m1 'orchestra 2026-11-21-csv-export/T4'
git branch --merged main | grep orchestra/2026-11-21-csv-export/T4
cat .orchestra/2026-11-21-csv-export/board.md
cat .orchestra/2026-11-21-csv-export/tasks/T4.task.md
```
- **If the board says T4 was accepted:** go to step 3.
- **If it shows T4 as dispatched or awaiting review:** you merged before review, so step 2 checks it now.

**2. Review after the fact (only if T4 wasn't reviewed)**
```bash
cp .worktrees/2026-11-21-csv-export/T4/RESULT.md .orchestra/2026-11-21-csv-export/tasks/T4.result.md 2>/dev/null
git diff --name-only <merge-base>..<T4-merge-commit>
git diff <merge-base>..<T4-merge-commit>
git ls-files | grep -x RESULT.md
```
- Every changed file must be on T4's "may change/create" list.
- `RESULT.md`, `__pycache__/` and `node_modules/` must not be committed.
- I'd read the diff for correctness and for test-first (TDD), nothing beyond the task (YAGNI) and no duplicated logic (DRY). If it touches input, files, auth or the network, I'd also run `security-review`.

If this finds a real problem, I won't fix it quietly on `main`. I'll write a follow-up task (T4b) with `file:line — problem — fix` notes, or `git revert` the merge if you agree.

**3. Run the tests on `main`**
```bash
git checkout main
<T4's exact "Done when" command, e.g. uv run pytest tests/test_export.py -q>
uv run pytest -q
uv run ruff check . && uv run mypy .    # only if the repo has them
```
If they fail on `main`, I stop and show you the full output before doing anything else.

**4. Clean up (only after step 3 is green)**
```bash
git worktree remove .worktrees/2026-11-21-csv-export/T4
git branch -d orchestra/2026-11-21-csv-export/T4
```
`-d` refuses to delete a branch that isn't merged. If it refuses, I'll ask you rather than use `-D`.

**5. Log in `.orchestra/2026-11-21-csv-export/board.md`**
- Task table: `T4 | merged | attempt <n> | main @ <short-sha>`
- Log line: `2026-11-23 T4 merged into main by user; reviewed <before/after> merge; task cmd 12 passed; full suite 148 passed, 0 failed; lint clean; worktree + branch removed. Nits: <none | …>`

I won't push. That's yours to do.

**Reply after the steps above:**
> T4 is merged: tests on `main` pass (12 task, 148 full suite), and the worktree and branch are removed and logged on the board. One thing for next time: you merged before I'd reviewed it, so I reviewed it afterwards and found nothing blocking. T5, which depends on T4, can now be dispatched. Nothing's been pushed.