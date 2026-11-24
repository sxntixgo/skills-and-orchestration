I'll resume the run from `board.md` and the plan. I'm assuming exactly one unfinished run exists; the steps below say what happens if not.

**1. Find the run** (you didn't name one)
```bash
cd /workspaces/<repo>
ls .orchestra/
grep -l -E '\| (todo|dispatched|review|sent-back) ' .orchestra/*/board.md
```
- **Exactly one unfinished run:** resume it. I assume `.orchestra/2026-11-22-csv-export/`, with plan `docs/plans/2026-11-20-csv-export-plan.md`, `concurrency` 2.
- **More than one:** stop and ask: "Which run: `<a>` or `<b>`?"
- **None:** stop and say: "No unfinished run in `.orchestra/`. Which plan should I start?"

**2. TodoWrite:** resume check → loop (step 3) → end of phase (step 4) → finish (step 5, only if this is the last phase).

**3. Re-read the state.** I read only `board.md`, the plan and `.orchestra/config.json`. No source files, diffs or logs. I assume this board for phase 2:

| id | phase | status |
|---|---|---|
| T1–T3 | 1 | merged (phase 1 review logged) |
| T4 | 2 | merged |
| T5 | 2 | dispatched |
| T6 | 2 | review |
| T7 | 2 | todo (depends on T5) |
| T8 | 2 | todo (depends on T4) |

**4. Check the repo after the crash** (a review subagent may have died mid-merge):
```bash
git status --porcelain; git branch --show-current     # clean, on main?
test -e .git/MERGE_HEAD && echo MERGE_IN_PROGRESS
git worktree list; git branch --list 'orchestra/*'
```
If a merge is half-done, I run `git merge --abort` and let T6's review run again. Any other dirty state means I stop and report it rather than clean it up myself.

**5. Check the in-flight tasks:**
- **T5 (dispatched):**
  ```bash
  ls .worktrees/T5/RESULT.md
  pgrep -af 'opencode.*T5'
  stat -f %m <T5 log>
  ```
  - RESULT.md present: set status to `review`.
  - Process alive and log growing: leave it running.
  - No process, no RESULT.md: the run died with the session. Re-dispatch it with `claude-dispatch` at the same attempt number, since a crash isn't a rejection.
- **T6 (review):**
  ```bash
  git log main --oneline --grep 'T6'
  git branch --merged main | grep orchestra/T6
  ```
  - Already merged: set it to `merged` with the commit and log that.
  - Not merged: run the review again.

**6. Log it in `board.md`:**
`- 2026-11-23 HH:MM resumed after session crash; T5 run dead → re-dispatched (attempt 1); T6 not merged → re-review`

**7. Continue the loop:**
- Review T6 in a subagent (one review at a time):
  - Model: `review_model` (sonnet), or `opus` if T6 is marked `review: opus`.
  - Prompt: "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-22-csv-export`, task `T6` in repo `/workspaces/<repo>`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` | `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`."
- T8 is ready because T4 is merged, and its files don't overlap T5. That fills the second of the 2 slots.
  - Spec subagent (`spec_model`, sonnet): "Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-22-csv-export/tasks/T8.task.md` for: <T8 row> + plan section `docs/plans/2026-11-20-csv-export-plan.md#<T8 heading>`. Reply with one line: the path, or `BLOCKED: <reason>`."
  - Then I dispatch it with `claude-dispatch`.
- T7 waits until T5 is merged.
- After every state change, I update the table and add one Log line.
- A rejected task goes back to dispatch with attempt + 1. After 3 rejections it's a takeover on the model ladder.

**8. End of phase 2** (every task merged, taken over or dropped):
- An `opus` subagent reviews `git diff <phase-2 start>..main` with `code-review`. It looks for duplication across tasks, inconsistent patterns and missing integration.
- Its findings become phase 3 tasks in `board.md`, and I log the review.
- Then I stop the session.

**Final message** (assuming phase 3 remains):
> Resumed run `2026-11-22-csv-export` after the crash. T5's opencode run had died, so I re-dispatched it, and T6's review never finished, so it ran again. Phase 2 is now done: T4–T8 are merged, and the phase review added 2 tasks for phase 3. Start a new session and say: resume run `2026-11-22-csv-export`.