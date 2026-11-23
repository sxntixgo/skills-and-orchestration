T7 has hit `max_rejections` (3), so I take it over. I'd give it to **haiku**: the fix is in one function, and the spec and review notes say exactly what to change. If haiku's attempt is rejected, it goes to sonnet.

**Assumptions:** the repo is `/workspaces/app`, the run is `r1` and `base_branch=main`. T7 may change `src/schedule/tz.py` and `tests/test_tz.py`. Its test command is `pytest tests/test_tz.py -q`. The third rejection's `## Notes from review` lines are already in `.orchestra/r1/tasks/T7.md`, and the task shows `attempt: 3`.

1. **Read** `.orchestra/r1/tasks/T7.md`, including all three rounds of review notes, and `.orchestra/r1/tasks/T7.result.md`. I don't send it back with `claude-dispatch --continue`.

2. **Log to `board.md`:**
   `T7 — rejected x3 (tz edge case in to_local_midnight) → TAKEOVER haiku: mechanical, notes specify exact change`

3. **Spawn a subagent** with the Agent tool and `model: "haiku"`. Prompt:
   ```
   Work only in /workspaces/app/.worktrees/r1/T7. Don't commit, push, or switch branches.

   Task (full text of .orchestra/r1/tasks/T7.md follows: goal, may change/create files,
   steps, Done when, out of scope):
   <task.md pasted verbatim>

   Notes from review (all 3 rounds):
   <notes pasted verbatim, file:line — problem — fix>

   Previous attempts: the local model handled the normal case but kept getting the
   timezone edge case wrong in one function (e.g. DST transition / naive vs aware datetime,
   per the notes). The notes above state the exact fix; apply exactly that.

   Rules: TDD: first add a test for the edge case that fails on the current code, then the
   simplest change that makes it pass. YAGNI (no extra params/branches), DRY (reuse existing
   helpers), follow the repo's style. Change only the files the task allows.

   Run `pytest tests/test_tz.py -q` until it passes. Reply with: files changed, test command,
   last ~20 lines of its output, anything you could not do.
   ```

4. **Review haiku's work** using steps 2–4 of the skill:
   - Delete any leftover `RESULT.md` from opencode in the worktree so the subagent's output isn't confused with it.
   - Run `bash <skill-dir>/scripts/review-check.sh r1 T7` and expect `CHECK T7 scope=ok … task=pass suite=pass lint=pass`.
   - Read the diff with `git -C .worktrees/r1/T7 diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'` plus any untracked files. I check that the edge-case test would fail without the fix, that no tests were weakened, and that each review note is addressed.

5. **Next step depends on the review:**
   - **Accept:** commit in the worktree as `fix: <goal> (orchestra r1/T7)` with the repo's trailers and mark the task `taken-over: haiku`. Merge into `main`, run `test_cmd` there, then `git worktree remove .worktrees/r1/T7` and delete the branch. Don't push.
   - **Reject:** write the notes as `file:line — problem — fix` and hand it to **sonnet** with the same prompt plus haiku's failure. If sonnet fails, go to opus. If opus fails, stop and report to the user.

6. **Log to `board.md`:**
   `T7 — taken-over (haiku) — MERGED <sha> — suite 214 passed, 0 failed — opencode failed tz edge case x3`

**Reply:**
`TAKEOVER T7 haiku 3 rejections; tz edge-case fix fully specified in spec + review notes`