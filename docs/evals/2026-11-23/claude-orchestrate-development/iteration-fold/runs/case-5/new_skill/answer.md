**Neither yet.** Takeover happens only after `max_rejections` rejections, which defaults to 3. T2 has 1 and T5 has 2, so both go back to opencode with the review notes.

What I'd do, in order:

1. **Read `.orchestra/config.json` and `board.md`.** This confirms the limit, since the config could set it lower. I'm assuming the default of 3 and that both tasks are `sent-back`.
2. **Re-dispatch both with `claude-dispatch --continue`** and the latest review notes, as attempt 2 for T2 and attempt 3 for T5. They run in parallel only if their files don't overlap and `concurrency` (default 2) allows. I won't fix anything in this thread.
3. **Update `board.md`.** Set both rows to `dispatched` and add these log lines:
   - `<time> T2 re-dispatched (attempt 2) with review notes`
   - `<time> T5 re-dispatched (attempt 3, last before takeover) with review notes`
4. **When each run finishes, spawn one review subagent** (`review_model`, or `opus` if the task is marked `review: opus`) with the usual `claude-review-merge` prompt. It replies with one line.
5. **If T5 is rejected a third time, it's taken over** (it doesn't get a fourth dispatch):
   - A subagent implements it from the full task, every round of review notes, and the TDD/YAGNI/DRY rules.
   - It starts on `sonnet`, or `opus` if the failures point to a judgment, security or design problem. After one rejection it moves up one model.
   - The result is reviewed again and marked `taken-over (<model>)`.

   T2 still has two attempts left.

One exception: if a reviewer replies `TAKEOVER <id> <reason>` before the limit (for example, the task is beyond the local model), I'd take that task over right away instead of sending it back again.