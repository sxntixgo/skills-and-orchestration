T1 is set to run in the background. These are the steps I'd take:

**1. Check preconditions.** I'd read only the task's header and `board.md`:
```bash
cd /workspaces/<repo>
head -20 .orchestra/2026-11-21-export/tasks/T1.md   # depends_on, files, base_branch
cat .orchestra/2026-11-21-export/board.md
```
What I assume I find: `T1.md` exists, `depends_on: []`, and `base_branch: main`. No other task is marked `dispatched` on the board, so T1's files have no owner. Dispatch goes ahead. If `depends_on` listed a task that wasn't merged yet, or a dispatched task owned any of T1's files, I'd stop and tell you which one.

**2. Start the run** with Bash `run_in_background: true`:
```bash
bash <skill-dir>/scripts/dispatch.sh 2026-11-21-export T1
```
This creates the worktree `.worktrees/2026-11-21-export/T1` on branch `orchestra/2026-11-21-export/T1`.

**3. Update `board.md`:**
```
| T1 | dispatched | attempt 1 | started 2026-11-23 <HH:MM> | worktree .worktrees/2026-11-21-export/T1 |
```

**4. Wait without polling.** I'd do other orchestration work until the exit notification. Then I'd read only the last line, `DISPATCH T1 exit=<rc> result=<yes|no> log=<path>`, and act on it:
- **exit=0, result=yes:** log `finished` and hand off to `claude-review-merge`.
- **exit=0, result=no:** run `tail -50 <log>`. Then send it back once, telling opencode to write RESULT.md:
  ```bash
  bash <skill-dir>/scripts/dispatch.sh 2026-11-21-export T1 --continue
  ```
- **exit=2:** fix the setup error (missing task, or a worktree that exists or is missing) and dispatch again.
- **exit=3:** wait for a running task to free a slot, then retry.
- **exit=4:** pause all dispatching and tell you the model server (LLM endpoint) can't be reached. No retry loop.
- **exit=124:** a timeout. Run `tail` on the log, then split the task or take it over.
- **exit=125:** it stalled and was already retried. Check the model server before one more try; otherwise pause and tell you.
- **Any other code:** an opencode error. Run `tail -50 <log>`, then fix the setup or take over.

Each outcome goes into `board.md`, for example `| T1 | finished | attempt 1 | exit=0 result=yes | log <path> |`.

**Reply to you now:**
> T1 is running in the background on opencode, in `.worktrees/2026-11-21-export/T1` (branch `orchestra/2026-11-21-export/T1`). It has no dependencies and no file conflicts, and `board.md` marks it dispatched (attempt 1). I'll report when it exits and then move it to review.