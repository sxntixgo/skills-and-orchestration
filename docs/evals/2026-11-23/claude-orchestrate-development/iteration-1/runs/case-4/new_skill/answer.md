I'll resume the run from `board.md` and the plan. I'm assuming a single unfinished run and the board state shown below.

**Assumptions** (nothing on disk to check)
- Repo: `/workspaces/app`. Run: `.orchestra/2026-11-22-csv-export/`. Plan: `docs/plans/2026-11-20-csv-export-plan.md`. Phase 1 has T1–T5; phase 2 has T6–T7.
- `config.json` is at defaults: `concurrency: 2`, `review_model: sonnet`.
- The board at crash time:

| id | phase | goal | status |
|---|---|---|---|
| T1, T2 | 1 | … | merged |
| T3 | 1 | CSV parser (review: opus) | dispatched (attempt 2) |
| T4 | 1 | export endpoint | review |
| T5 | 1 | download UI, depends_on T3 | todo |
| T6, T7 | 2 | … | todo |

**What I'd do, in order**

1. **Find the run:** `ls -t /workspaces/app/.orchestra/`. If more than one run is unfinished, I'd stop and ask which one.
2. **Read only `board.md` and the plan.** No source files, diffs or logs in this thread. TodoWrite: resume check, loop, end of phase 1.
3. **Check T3 (`dispatched`):**
   ```bash
   pgrep -af "dispatch.sh 2026-11-22-csv-export T3"
   test -f /workspaces/app/.worktrees/2026-11-22-csv-export/T3/RESULT.md && echo result=yes
   stat -c '%y %s' /workspaces/app/.orchestra/2026-11-22-csv-export/logs/T3.2.jsonl; date
   ```
   - Assumed result: no process and no `RESULT.md`. The crash killed the background dispatch.
   - If `RESULT.md` had existed, T3 would go straight to review.
4. **Restart T3** in the background (`run_in_background: true`):
   ```bash
   bash <claude-dispatch>/scripts/dispatch.sh 2026-11-22-csv-export T3 --continue
   ```
   - It uses the same worktree and the same opencode session, so any partial work is kept.
   - The attempt number stays at 2: a crash isn't a rejection, so it doesn't count toward `max_rejections`.
5. **Check T4 (`review`):** its review subagent may have died partway through a merge.
   ```bash
   git -C /workspaces/app status --short --branch     # clean on main? no MERGE_HEAD?
   git -C /workspaces/app branch --merged main | grep -F orchestra/2026-11-22-csv-export/T4
   ```
   - If it's already merged: mark T4 `merged` and pick up the commit from `git log -1 --format=%h main`.
   - If a merge is half-done: `git merge --abort`, then review again.
   - Assumed result: clean tree, not merged. Spawn one review subagent (model `sonnet`):
     > "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-22-csv-export`, task `T4` in repo `/workspaces/app`. The previous review was interrupted by a session crash; start fresh. Reply with one line: `MERGED T4 <commit> tests=<n passed>` | `REJECTED T4 attempt=<n> notes=<count>` | `TAKEOVER T4 <reason>`."
6. **Update `board.md`:** T3 → `dispatched (attempt 2, restarted 10:42)`, T4 → `review`. Log line:
   `- 2026-11-23 10:42 resumed after session crash: T3 run dead, no RESULT.md → redispatched --continue (attempt 2); T4 review restarted (not merged, tree clean)`
7. **Continue the loop:**
   - **Slots:** T3 uses one of the two slots. T5 waits for T3, and T6–T7 are phase 2, so nothing else can start yet.
   - **T4 verdict:** log it. If rejected, send it back with `--continue` at attempt +1.
   - **T3 exits:** handle it by its `DISPATCH` line. exit=0 with `RESULT.md` → review with model `opus` (T3 is marked `review: opus`). When T3 is merged, write T5's spec (sonnet subagent) and dispatch it.
8. **End of phase 1** (T1–T5 all merged or dropped):
   - An `opus` subagent runs `code-review` over `git diff <phase-1 start>..main`.
   - Its findings become phase-2 tasks. I log them, then stop the session.

**Reply to the user, now**
> I've picked up run `2026-11-22-csv-export`. The crash killed T3's opencode run before it finished, so I restarted it in the same worktree and session (still attempt 2). T4's review was cut off before it merged, so it's running again. T1–T2 are merged, and T5 is waiting for T3. Phase 1 continues; I'll report when it's done.

**Reply when phase 1 is done**
> Phase 1 done. Start a new session and say: resume run `2026-11-22-csv-export`.