**Resuming the existing run for phase 1. T1 and T2 are reviewed one at a time by subagents, T3 then goes through write → dispatch → review, phase 1 gets an opus review, and the session stops. Phases 2 and 3 run in later sessions.**

Assumptions (I can't see these files):
- The plan is committed. `.orchestra/2026-11-23-export/board.md` exists.
- Config uses the contract defaults: `concurrency: 2`, `review_model: sonnet`, `base_branch: main`.
- Board rows: T1 is the export serializer (`src/export/serialize.py` + tests). T2 is the CSV file writer (`src/export/csv_writer.py` + tests) and is marked `review: opus` because it writes files. T3 is the `export` CLI command, which depends on T1 and T2. Phases 2 and 3 are T4–T8, all `todo`.
- If `board.md` were missing, the phase-1 runs would have no run state to resume. I'd stop and ask you rather than rebuild a board around them.

**Steps**

1. **TodoWrite:** (0) plan gate, (1) resume run, (3) loop phase 1, (4) phase 1 review and hand-off.

2. **Plan gate:** `docs/plans/2026-11-23-export-plan.md` exists and is committed, so it passes. No setup step, because this is a resume.

3. **Resume.** I read only `board.md` and the plan. T1 and T2 are `dispatched`. Checking that they finished:
   ```
   test -f .worktrees/2026-11-23-export/T1/RESULT.md && echo T1 done
   test -f .worktrees/2026-11-23-export/T2/RESULT.md && echo T2 done
   pgrep -f "opencode.*2026-11-23-export" || echo no runs alive
   ```
   I check only that RESULT.md exists. I don't open it or any diff or log in this thread. Board update: T1 and T2 → `review`. Log:
   `- 14:05 T1, T2 finished (RESULT.md present) → review`

4. **Review T1.** Agent, model `sonnet`:
   > Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-export`, task `T1` in repo `/workspaces/<repo>`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` | `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`. If the skill isn't loaded, read `plugins/orchestration/skills/claude-review-merge/SKILL.md`.

   Say it replies `MERGED T1 a1b2c3d tests=14`. Board: T1 → `merged`. Log: `- 14:12 T1 MERGED a1b2c3d tests=14 (opencode, 1st try)`

5. **Review T2.** This starts only after T1's review is back, because each review can merge into `main`. It uses the same prompt with `T2` and model `opus`, since T2 is marked `review: opus`.
   - If it's `MERGED`: board → `merged`, plus a log line.
   - If it's `REJECTED T2 attempt=1 notes=3`: board → `sent-back`. I redispatch with `--continue` through `claude-dispatch`, using the notes the review wrote into the task. Attempt becomes 2, board → `dispatched`, plus a log line.
   - After 3 rejections: takeover, marked `taken-over`.

6. **T3 becomes ready** once T1 and T2 are merged. Spec subagent, model `sonnet`:
   > Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-export/tasks/T3.task.md` for: `T3 | 1 | export CLI command | opencode | T1,T2 | src/cli/export.py, tests/test_cli_export.py | todo` + plan section `docs/plans/2026-11-23-export-plan.md#phase-1`. Reply with one line: the path, or `BLOCKED: <reason>`.

   Then dispatch here with `claude-dispatch` (`dispatch.sh` with `2026-11-23-export T3`). Board → `dispatched`, plus a log line. When RESULT.md appears, the review runs as in step 4 and the board and log are updated.

7. **Phase 1 review**, once T1–T3 are all merged or dropped. Agent, model `opus`:
   > Use the `code-review` skill if installed. Review phase 1 of run `2026-11-23-export` in `/workspaces/<repo>`: `git diff <phase-1 start commit>..main`. Look only for what per-task reviews miss: duplication across T1–T3, inconsistent patterns, missing integration. Reply with at most 5 one-line findings, or `CLEAN`.

   Each finding becomes a new task row in phase 2 (`todo`), or a fix task now if it blocks phase 2. Log: `- 15:40 Phase 1 review (opus): <n findings → T9…|CLEAN>`

8. **Stop.** I don't continue into phase 2 in this session.

**Final message to you**

> Phase 1 done: T1 merged (opencode, 1st try), T2 <merged / merged after send-back>, T3 merged. Phase review: <CLEAN | n findings added as T9…>. Tests pass on `main`. Start a new session and say: resume run `2026-11-23-export`.

Nothing has been pushed. Pushing is up to you once all phases are done.