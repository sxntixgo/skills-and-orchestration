Resuming the existing run: I review T1 and T2 one at a time, then carry on with phase 1 and stop when phase 1 is done.

**Assumptions:** the run is `.orchestra/2026-11-23-export/` and its `board.md` lists phase 1 as T1 and T2 (both `dispatched`), T3 (depends on T1) and T4 (depends on T2). Config uses the defaults: `concurrency` 2, `review_model` sonnet, `base_branch` main. T2 touches input parsing, so its goal cell says `review: opus`.

### Steps, in order

1. **Resume. I read only the plan and the board.** Setup and the task graph already exist, so I don't redo them.
   ```bash
   cat docs/plans/2026-11-23-export-plan.md .orchestra/2026-11-23-export/board.md
   test -f .worktrees/T1/RESULT.md && echo T1 done; test -f .worktrees/T2/RESULT.md && echo T2 done
   ```
   I only check that each RESULT.md exists. I don't read it, its diff or the logs in this thread.
   Board change: T1 and T2 go to `review`. Log line: `<time> T1,T2 finished (opencode) → review`.

2. **Review T1.** Agent, model `sonnet`:
   > Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-export`, task `T1` in repo `/workspaces/<repo>`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`.

   I log the verdict line on the board.
   - `MERGED`: status becomes `merged`.
   - `REJECTED`: status becomes `sent-back` and I re-dispatch with `claude-dispatch --continue` (attempt + 1).
   - `TAKEOVER`: an implementer subagent takes the task over (details in step 4).

3. **Review T2, only after the T1 review has replied.** Reviews run one at a time because each one may merge into main. Same prompt with `T2`, but on model `opus` because the task is marked `review: opus`. Board and log are updated the same way.

4. **Continue the loop.** Ready tasks are those whose dependencies are merged and whose files don't overlap a task that's still running, up to 2 at a time.
   - **Spec:** for each ready task (e.g. T3), an Agent on `sonnet`:
     > Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-export/tasks/T3.task.md` for: `<T3 row from board.md>` + plan section `docs/plans/2026-11-23-export-plan.md#phase-1`. Reply with one line: the path, or `BLOCKED: <reason>`.
   - **Dispatch:** `claude-dispatch` T3 runs here. The board shows `dispatched`, with one log line.
   - When each run finishes, it gets a review exactly as in step 2.
   - A task rejected 3 times is taken over by an implementer subagent on the next model up. The prompt contains the full task, the review notes, and the rules TDD, YAGNI and DRY. The task is then reviewed again and marked `taken-over (<model>)`.

5. **End of phase 1**, once every phase-1 task is merged or dropped. Agent, model `opus`:
   > Using the `code-review` skill if installed, review `git diff <phase-1 start commit>..main` in `/workspaces/<repo>` for duplication across tasks, inconsistent patterns and missing integration. Reply with at most 5 one-line findings, or `CLEAN`.

   Findings become new phase-2 rows in `board.md` (or a fix task now if something is broken). Log line: `<time> phase 1 review: <n findings | clean>`.

6. **Stop the session.** Phases 2 and 3 are not started here.

### Final reply to the user (filled in from the real outcomes)

> Phase 1 done: T1 merged (`<commit>`, opencode on the first try), T2 merged (`<commit>`, after 1 send-back), T3 and T4 merged. The phase review found `<n>` issues, which are now phase-2 tasks T5 and T6 in `board.md`. Start a new session and say: resume run `2026-11-23-export`.