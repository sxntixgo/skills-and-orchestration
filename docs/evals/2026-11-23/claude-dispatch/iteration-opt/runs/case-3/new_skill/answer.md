T3 goes back to its own opencode session with `--continue`. It reuses the same worktree and does not create a new one.

**Assumptions** (I can't see the files):
- The active run is in `board.md`. I'll call it `<run>` (e.g. `auth-refactor`).
- T3 is marked `sent back` after attempt 1.
- `claude-review-merge` has already added the review notes to T3's task file, so opencode will see them when it resumes.
- The worktree `.worktrees/<run>/T3` and branch `orchestra/<run>/T3` still exist.

**Steps, in order**

1. **Preconditions** (read `board.md` and T3's task file):
   - The task file exists and includes the review notes.
   - T3's `depends_on` are merged into `base_branch`.
   - No other dispatched task owns any of T3's files.
   - A `concurrency` slot is free. If not, the script exits 3 and I wait.

   If any check fails, I don't dispatch and I tell you why.

2. **Dispatch in the background** (Bash, `run_in_background: true`):
   ```bash
   bash plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh <run> T3 --continue
   ```

3. **Update `board.md`:**
   ```
   | T3 | dispatched | attempt 2 (send-back, --continue) | started 2026-11-23 HH:MM |
   ```

4. **While it runs:** I do other orchestration work and don't poll. I also leave `.worktrees/<run>/T3` alone until it exits.

5. **When it exits:** I read only the last line, `DISPATCH T3 exit=<rc> result=<yes|no> log=<path>`, and log the outcome in `board.md`:
   - **exit=0, result=yes:** goes to `claude-review-merge` for re-review.
   - **exit=0, result=no:** I check the log tail and send it back once more with "write RESULT.md".
   - **exit=2:** the worktree or task is missing. I fix it and redispatch with `--continue`.
   - **exit=4:** the model server is unreachable. I pause all dispatching and tell you.
   - **exit=124:** timed out. I read the log tail, then split the task or take it over.
   - **exit=125:** stalled after a retry. I check the model server; if that doesn't fix it, I pause and tell you.
   - **Any other code:** I run `tail -50 <log>`, then fix the setup or take over.

**Reply to you:**
> T3 has been sent back to its opencode session with the review notes (attempt 2, same worktree, running in the background). I'll report the outcome when it exits and pass it to review if it finishes.