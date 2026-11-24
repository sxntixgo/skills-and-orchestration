Run `2026-11-23-export` is still in progress, so I resume it rather than set it up again. I'll review T1 and T2 one at a time, keep the Phase 1 loop going, and stop at the end of Phase 1.

**Assumptions:**
- The plan is committed and `.orchestra/2026-11-23-export/board.md` exists. It has an earlier Log line showing T1 and T2 were dispatched.
- Config is the default: `concurrency` 2, `max_rejections` 3, `review_model` sonnet, `base_branch` main.
- Phase 1 has 4 tasks:
  - T1: the shared export serializer, in `src/export/serialize.ts` plus its tests.
  - T2: the CSV writer, in `src/export/csv.ts` plus its tests.
  - T3: the export endpoint. It depends on T1 and T2, and its goal cell says `review: opus` because it parses input and writes files.
  - T4: the CLI flag. It depends on T1.

If `board.md` turned out to be missing, I'd do step 1 (run setup) and step 2 (task graph) from scratch. I wouldn't trust the report that T1 and T2 came back without a board entry to match it.

### Ordered actions

1. **TodoWrite:** one item each for resume, review T1, review T2, loop Phase 1, phase review, and handoff.
2. **Resume.** I read only `docs/plans/2026-11-23-export-plan.md` and `.orchestra/2026-11-23-export/board.md`. No source files, diffs or opencode logs go into this thread.
3. **Confirm both runs finished:**
   ```bash
   ls .worktrees/T1/RESULT.md .worktrees/T2/RESULT.md
   ```
   I only check that the files exist. I don't read them, because merging on what RESULT.md says isn't allowed.
4. **Update `board.md`:**
   - Table: T1 and T2 change from `dispatched` to `review`.
   - Log: `2026-11-23 HH:MM T1, T2 finished (opencode) → review`.
5. **Review T1 with a subagent** (model `sonnet`). Reviews run one at a time because each can merge into main.
   > Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-export`, task `T1` in repo `/workspaces/<repo>`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`.

   Assumed reply: `MERGED T1 a1b2c3d tests=14`.
   - Board: T1 becomes `merged`.
   - Log: `HH:MM T1 MERGED a1b2c3d tests=14 (opencode, first try)`.
6. **Start T4 straight away.** T1 is merged, nothing is running, and T4's files don't overlap with T2.
   - The spec subagent (`sonnet`) gets this prompt:
     > Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-export/tasks/T4.task.md` for: `T4 | 1 | CLI --export flag | opencode | T1 | src/cli/export.ts, tests/cli/export.test.ts | todo` + plan section `docs/plans/2026-11-23-export-plan.md#phase-1`. Reply with one line: the path, or `BLOCKED: <reason>`.
   - Then I dispatch T4 with `claude-dispatch` in this thread.
   - Board: T4 becomes `dispatched`.
   - Log: `HH:MM T4 dispatched (opencode, attempt 1)`.
7. **Review T2 with a subagent:** same prompt as step 5, with T2 in place of T1.
   - If merged: T2 becomes `merged` and I log it. T3 is now unblocked: it gets a spec subagent, then a dispatch. That keeps 2 running, which is the concurrency limit.
   - If rejected: T2 becomes `sent-back` and I log the attempt number. I dispatch it again with `--continue` and the review notes. I don't fix the code myself.
8. **Continue the loop** as each run finishes. I review each one with a subagent and update `board.md` with a Log line after every state change.
   - T3 is reviewed by a subagent on `opus` because it's marked `review: opus`.
   - After 3 rejections a task becomes a takeover, starting on the lowest model that fits (haiku, then sonnet, then opus). The prompt includes the full task, the review notes, and the TDD/YAGNI/DRY rules.
9. **Phase review.** Once all Phase 1 tasks are merged or dropped, an `opus` subagent reviews the phase with the `code-review` skill:
   > Use the `code-review` skill to review `git diff <phase-1 start commit>..main` in `/workspaces/<repo>` for duplication across T1–T4, inconsistent patterns and missing integration. Reply with at most 5 one-line findings, or `CLEAN`.
   - Each finding becomes a new Phase 2 row in `board.md`, or a fix task now if it blocks Phase 2.
   - Log: `HH:MM Phase 1 review: <n findings → tasks>`.
10. **Stop.** I don't start Phase 2 in this session.

### Final reply to the user

> Phase 1 is done: T1–T4 are merged (outcomes are in `.orchestra/2026-11-23-export/board.md`), and the phase review added <n> tasks to Phase 2. Start a new session and say: resume run `2026-11-23-export`.