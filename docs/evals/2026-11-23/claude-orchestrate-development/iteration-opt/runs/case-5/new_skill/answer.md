**Neither yet.** Takeover starts only after `max_rejections` rejections. I'm assuming the default of 3, since I can't see `.orchestra/config.json`. T2 has 1 rejection and T5 has 2, so both go back to opencode with the review notes.

What I'd do:

1. **Read `.orchestra/config.json` and `board.md`** to confirm `max_rejections` (assumed 3) and the two rows. I'm assuming T2 and T5 are `sent-back`, the notes are in each task's review file, and the run name is `<run>`.
2. **Resend T2** (attempt 2) with `claude-dispatch --continue` and the review notes, provided no running task shares its files.
3. **Resend T5** (attempt 3) the same way. This is its last opencode attempt.
4. **Log both in `board.md`:**
   - `HH:MM T2 sent-back → dispatched (attempt 2, review notes via --continue)`
   - `HH:MM T5 sent-back → dispatched (attempt 3 of 3; next rejection = takeover)`
5. **When each run finishes**, spawn a review subagent (`review_model`, or `opus` if the task is marked `review: opus`) with this prompt: "Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `<id>` in repo `/workspaces/<repo>`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` | `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`."
6. **If T5 is rejected a third time**, a Claude subagent takes it over. It starts at `sonnet`, or `opus` if the task is about security, concurrency or a design flaw. Its prompt gets the full task, all review notes, and the TDD/YAGNI/DRY rules. It works in the worktree, then gets reviewed again and is marked `taken-over (<model>)`.

There's one exception. If a reviewer replies `TAKEOVER <id> <reason>` (for example, the spec is beyond what the local model can do, or there's a design flaw), I take that task over right away, whatever its count. Repeat rejections for the same flaw would also be a reason to rework T5's spec before its third attempt.

**Reply to you:** "No takeover yet. Takeover comes after 3 rejections (`max_rejections`). T2 is going back for attempt 2 and T5 for attempt 3, both with the review notes. If T5 is rejected again, a Claude subagent takes it over, starting at sonnet."