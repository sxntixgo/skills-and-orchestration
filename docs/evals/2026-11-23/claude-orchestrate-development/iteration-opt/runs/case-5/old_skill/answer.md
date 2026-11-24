Neither should be taken over yet. Takeover happens after `max_rejections` rejected attempts, and the default is 3. T2 has used 1 of its 3 opencode attempts and T5 has used 2. Both go back to opencode with their review notes. T5's next attempt is its last; if that one is rejected, T5 is taken over.

**Assumptions:** the run is under `.orchestra/<run>/`. `config.json` either has no `max_rejections` or has it set to 3. The reviewers returned `REJECTED`, not `TAKEOVER`. T2 and T5 don't share files.

**What I'd do:**

1. **Read only two files, `board.md` and `.orchestra/config.json`,** to confirm both tasks are `sent-back` and `max_rejections` is 3. I would not open the diffs or the review notes here, so this thread stays small.

2. **Re-dispatch both** with `claude-dispatch`. That's two tasks, within `concurrency: 2`. Each task file already has its bumped `attempt` and its `Notes from review`.
   - T2 → attempt 2
   - T5 → attempt 3

3. **Update `board.md`:** set both rows to `dispatched` and add these log lines:
   ```
   - 2026-11-23 HH:MM T2 re-dispatched (attempt 2/3) after 1 rejection
   - 2026-11-23 HH:MM T5 re-dispatched (attempt 3/3, final opencode try) after 2 rejections
   ```

4. **Review each result as it finishes.** A subagent on `review_model` reviews it (or `opus` if the task is marked `review: opus`), with this prompt: "Use the `claude-review-merge` skill … task `<id>` … Reply with one line: MERGED / REJECTED / TAKEOVER."

5. **If T5 is rejected a third time,** mark it `taken-over` and spawn an implementation subagent in its worktree on the cheapest model that fits, following `takeover.md`:
   - `sonnet` for normal feature work
   - `haiku` if the notes spell out exactly what to change
   - `opus` for a design flaw or a bug nobody has located

   The subagent gets the full task file, all review notes and a summary of what went wrong in the three attempts. Its result is then reviewed like any other.

**One exception:** `takeover.md` also allows an early takeover "when the task is beyond the local model." If a reviewer had returned `TAKEOVER <id> <reason>` (for example, the spec has a design flaw, or the task needs security judgment), I'd take that task over now. Two ordinary rejections don't meet that bar.