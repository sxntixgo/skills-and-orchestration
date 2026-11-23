**Neither yet.** Takeover happens after `max_rejections` rejected attempts, and the default is 3. T2 has 1 rejection and T5 has 2, so both go back to opencode with the review notes. T5 gets one more try. If attempt 3 is rejected, I take it over.

**What I'd do:**

1. Read `.orchestra/<run>/board.md` and `.orchestra/config.json` only. I'm assuming `max_rejections` is the default 3, that both tasks are `sent-back`, and that `claude-review-merge` already wrote the notes into each `tasks/<id>.task.md` under "Notes from review". I don't read diffs or logs in this thread.
2. Check one exception: `takeover.md` also allows an early takeover "when the task is beyond the local model". From the one-line log entries, I'd look for T5's two rejections hitting the same problem (no progress), or the spec itself being wrong. I'm assuming neither applies, so T5 goes back to opencode. If one did apply, I'd take T5 over now. The worker would be a `sonnet` subagent, or `opus` if the problem is a spec or design flaw. It would get the full task.md, all review notes and a summary of both failed attempts, and would work only in `.worktrees/<run>/T5/`.
3. Re-dispatch both with `claude-dispatch` (continuing the opencode session):
   - T2 at attempt 2.
   - T5 at attempt 3.

   They can run at the same time only if their files don't overlap and `concurrency` is 2. Otherwise T5 runs first.
4. When each run finishes, a review subagent checks it. The model is `review_model`, or `opus` if the task is marked `review: opus`. The prompt is: "Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `<id>` in repo `/workspaces/<repo>`. Reply with one line: `MERGED …` | `REJECTED …` | `TAKEOVER …`."
5. If T5 is rejected a third time: mark it `taken-over` and pick the cheapest model in `takeover.md` that fits:
   - `haiku` if the notes spell out exactly what to change in 2 files or fewer.
   - `sonnet` for normal feature work.
   - `opus` for security work, or a bug nobody has found yet.

   If that model's result is rejected, go up one model, never down.
6. Update `board.md`:
   - T2 → `dispatched (attempt 2)`
   - T5 → `dispatched (attempt 3)`
   - Log: `<time> T2 re-dispatched attempt 2 (1 rejection)`
   - Log: `<time> T5 re-dispatched attempt 3 (2 rejections; takeover if rejected again)`

**Reply to the user:**

> Neither yet: T2 has used 1 of 3 attempts and T5 has used 2. Both are going back to opencode with the review notes. If T5 is rejected once more, I'll take it over with a Claude subagent on the cheapest model that can do it, and it gets reviewed like any other task.