**No, neither one yet.** I'm assuming `.orchestra/config.json` either doesn't exist or leaves `max_rejections` at the default of 3. With that setting, opencode gets 3 attempts before a takeover. T2 has used 1 and T5 has used 2.

**What I'd do:**
1. Read `.orchestra/config.json` to confirm `max_rejections`. If someone lowered it to 2, T5 should be taken over now.
2. Read `board.md` and the review notes for T2 and T5.
3. **T2 (1 rejection):** run `claude-write-task` again with `attempt: 2` and the review notes under `## Notes from review`. Then run `claude-dispatch`, set the status to `dispatched`, and add a Log line.
4. **T5 (2 rejections):** this is its last opencode attempt. Send it back as `attempt: 3` with notes that are as specific as possible: the exact failing assertion, plus file:line references.
   - **One exception:** the takeover rule also applies when a task is beyond what the local model can do. If the two rejections failed the same way, or the cause is a problem in the spec, a race condition or something security-related, I'd take it over now rather than spend a third attempt. Without seeing the notes, I'm assuming it's ordinary missed edge cases, so it gets the third attempt.
5. If T5 is rejected a third time, `claude-review-merge` takes it over. It delegates to a subagent on the cheapest model that fits: `sonnet` for normal feature work, `haiku` if the notes spell out exactly what to change, `opus` if it needs judgment. The subagent gets the worktree path, the full task.md, all review notes, a summary of what went wrong each time, the TDD/YAGNI/DRY rules and the exact test command. Then I review it as usual, mark it `taken-over`, and log the model used. There will never be a fourth opencode dispatch.

**Log lines I'd add to `board.md`:**
```
- HH:MM T2 sent-back → dispatched (attempt 2)
- HH:MM T5 sent-back → dispatched (attempt 3, last before takeover)
```