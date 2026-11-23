I won't merge T1 just because RESULT.md says it's done. That file is the implementer's claim. A review subagent first reruns the checks and reads the diff, and the merge happens only if all of that passes.

**Assumptions** (nothing on disk): repo `/workspaces/app`, run `2026-11-22-csv-export`, `.orchestra/config.json` has `base_branch: main`, `review_model: sonnet`, `test_cmd: "uv run pytest -q"` and `lint_cmd: "uv run ruff check ."`. `T1.task.md` is not marked `review: opus`. Its files are `may change: app/export.py, tests/test_export.py`, and its "Done when" command is `uv run pytest tests/test_export.py -q`.

### 1. Spawn the review subagent
I use a subagent so my own context stays small. It runs on `sonnet` because that is the `review_model`; it would be `opus` if the task were marked `review: opus`.

Prompt:
> You are the reviewer for orchestration run `2026-11-22-csv-export`, task `T1`, repo `/workspaces/app`. Follow the skill `claude-review-merge` (SKILL.md + `../../contract.md`) exactly. RESULT.md says `status: done`, 12 passed. Treat that as a claim to verify.
> 1. Copy `.worktrees/2026-11-22-csv-export/T1/RESULT.md` → `.orchestra/2026-11-22-csv-export/tasks/T1.result.md`. Read it and `T1.task.md`.
> 2. Run `bash <skill-dir>/scripts/review-check.sh 2026-11-22-csv-export T1`. Don't rerun tests by hand. Compare its counts with RESULT.md's "12 passed".
> 3. Read `git -C .worktrees/2026-11-22-csv-export/T1 diff` plus any new files, skipping lockfiles and generated files. Check correctness, the spec's edge cases, TDD/YAGNI/DRY, no new deps, no secrets, and no weakened, skipped or deleted tests.
> 4. **Accept** only if every "Done when" holds, the checks pass and scope is clean. Then: `rm RESULT.md`, commit in the worktree as `feat: <goal> (orchestra 2026-11-22-csv-export/T1)` with the repo's trailers, merge into `main` the way the repo does it, rerun `test_cmd` on `main`, `git worktree remove`, `git branch -d orchestra/2026-11-22-csv-export/T1`. Otherwise **reject**: add `## Notes from review` to the task (`file:line — problem — fix`) and bump `attempt`.
> 5. Log the verdict, test numbers and reason in `board.md`. Don't push.
> 6. Reply with one line only: `MERGED T1 <commit> tests=<summary>` or `REJECTED T1 attempt=<n> notes=<count>`.

What the subagent runs:
```bash
cd /workspaces/app
cp .worktrees/2026-11-22-csv-export/T1/RESULT.md .orchestra/2026-11-22-csv-export/tasks/T1.result.md
bash <skill-dir>/scripts/review-check.sh 2026-11-22-csv-export T1
# assumed: CHECK T1 scope=ok result=yes task=pass suite=pass lint=pass  (task: 12 passed; suite: 87 passed)
git -C .worktrees/2026-11-22-csv-export/T1 diff
git -C .worktrees/2026-11-22-csv-export/T1 ls-files --others --exclude-standard
# accept path:
rm .worktrees/2026-11-22-csv-export/T1/RESULT.md
git -C .worktrees/2026-11-22-csv-export/T1 add -A
git -C .worktrees/2026-11-22-csv-export/T1 commit -m "feat: CSV export of orders (orchestra 2026-11-22-csv-export/T1)"
git checkout main && git merge --no-ff orchestra/2026-11-22-csv-export/T1
uv run pytest -q          # one summary line
git worktree remove .worktrees/2026-11-22-csv-export/T1
git branch -d orchestra/2026-11-22-csv-export/T1
```

Line appended to `board.md`:
```
- 2026-11-23 T1 MERGED a1b2c3d — review-check: scope ok, task 12 passed (matches RESULT.md), suite 87 passed on main, lint ok; diff clean (TDD/YAGNI/DRY ok)
```
I also set T1's status in the board's task table to `merged`.

### 2. If the review fails instead
If any check fails (scope `N-out`, a failing test, a count that doesn't match, weakened tests or a problem in the diff), the subagent returns `REJECTED T1 attempt=2 notes=N`. I would then send the task back with `claude-dispatch --continue` instead of merging. If this were the 3rd rejection, a Claude model would take the task over (see `references/takeover.md`).

### 3. My reply to you (assuming the accept path)
> T1 is merged into `main` as `a1b2c3d`. I reran the tests rather than relying on RESULT.md: the task's tests passed (12, matching its claim), the full suite passed on `main` (87), lint is clean and scope is clean. The worktree and branch are removed. Nothing was pushed.