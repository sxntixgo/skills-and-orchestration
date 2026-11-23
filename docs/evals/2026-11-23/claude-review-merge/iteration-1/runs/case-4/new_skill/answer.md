Before moving on, T4 still needs its post-merge steps from the skill: check main's tests, remove the worktree and branch, and log it in `board.md`. Here's what I'd do, in order.

**Assumptions:** the run is `2026-11-21-csv-export` and the repo is at `/workspaces/<repo>`. `board.md` already has an ACCEPT verdict for T4, because review ran and you did the merge yourself. `config.json` has `test_cmd: "uv run pytest -q"`.

1. **Confirm the merge and that nothing extra came in:**
   ```bash
   cd /workspaces/<repo>
   git log --oneline -3 main
   git branch --merged main | grep 'orchestra/2026-11-21-csv-export/T4'
   git show --stat --format='%h %s' main | grep -E 'RESULT.md|\.orchestra/|__pycache__' || echo clean
   ```
   - If `RESULT.md` or build artifacts reached main, I'd stop and tell you. Fixing that needs a follow-up commit on main, and I won't add one without asking.
   - If `board.md` has no review verdict for T4, the merge skipped review. In that case I'd run the review before cleanup, while the worktree still exists: `bash <skill-dir>/scripts/review-check.sh 2026-11-21-csv-export T4`, then read the diff.

2. **Keep the result file before deleting the worktree:**
   ```bash
   test -f .orchestra/2026-11-21-csv-export/tasks/T4.result.md || \
     cp .worktrees/2026-11-21-csv-export/T4/RESULT.md .orchestra/2026-11-21-csv-export/tasks/T4.result.md
   ```

3. **Run the full suite on main** and keep one summary line:
   ```bash
   git switch main && uv run pytest -q 2>&1 | tail -1
   ```
   If this fails, I'd report it and stop. I would not clean up or move on.

4. **Clean up:**
   ```bash
   git worktree remove .worktrees/2026-11-21-csv-export/T4
   git branch -d orchestra/2026-11-21-csv-export/T4   # -d, not -D: refuses if it isn't merged
   ```

5. **Log it in `.orchestra/2026-11-21-csv-export/board.md`:**
   - Task table: `| T4 | … | merged | <sha> | attempt 1 |`
   - Log line: `2026-11-23 T4 MERGED <sha> (merged by user) — main: 142 passed, 0 failed; worktree + branch removed`

6. **Unblock what depended on T4:**
   ```bash
   grep -l 'depends_on:.*T4' .orchestra/2026-11-21-csv-export/tasks/*.task.md
   ```
   Tasks whose dependencies are now all merged become ready for dispatch.

No push; you do that.

**Reply:**

> T4 checks out: main's tests are green (`142 passed, 0 failed`), `RESULT.md` didn't reach main, the worktree and `orchestra/2026-11-21-csv-export/T4` branch are removed, and `board.md` records it as `MERGED <sha>`. T5 depended on T4 and is ready to dispatch. Nothing is pushed; that's yours to do when you're ready.