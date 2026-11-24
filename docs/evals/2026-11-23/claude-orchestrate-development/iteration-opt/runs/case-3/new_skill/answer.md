T4 now goes to takeover: no fourth opencode dispatch. A Claude subagent implements T4 using the model ladder, then T4 goes through `claude-review-merge` like any other task.

**What I'd do, in order**

1. **Read `board.md` and the plan only.** I'm assuming run `2026-11-23-<slug>`, and that T4's row says `sent-back`, attempt 3, with normal feature work (an endpoint plus its tests, about 3 files) and no `review: opus` mark. I won't open the diff, logs or review notes in this thread.

2. **Update `board.md`.** Set T4's status to `taken-over (pending)` and add this Log line:
   `HH:MM T4 REJECTED attempt=3 → max_rejections reached; takeover on sonnet`

3. **Pick the model.** Under these assumptions, `sonnet` fits because this is normal feature work. If T4 were marked `review: opus`, or the three sets of review notes pointed to the same design flaw rather than ordinary bugs, I'd use `opus` instead.

4. **Spawn the takeover subagent** (Agent tool, `model: sonnet`):
   > You are taking over task T4 of orchestration run `<run>` in repo `/workspaces/<repo>`. opencode was rejected 3 times. Read the full task at `.orchestra/<run>/tasks/T4.task.md` and all review notes for T4 under `.orchestra/<run>/`. Work in worktree `.worktrees/T4` (branch `orchestra/T4`). Keep opencode's work where it is sound. If the notes show the approach itself is wrong, reset the branch to `<base_branch>` and start over. Rules: TDD (write a failing test first, then make it pass), YAGNI (only what the task asks), DRY (reuse shared code from earlier tasks). Touch only the files listed in the task. Run the task's test command and `lint_cmd` until both pass, then commit on `orchestra/T4` and write `RESULT.md`. Don't merge, push or edit other files. Reply with one line: `DONE T4 <commit> tests=<n passed>` or `BLOCKED: <reason>`.

5. **Review it again** with a subagent (`model: sonnet` from `review_model`; `opus` if T4 is marked `review: opus`):
   > Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `T4` in repo `/workspaces/<repo>`. This is a Claude takeover (sonnet) after 3 opencode rejections. Reply with one line: `MERGED T4 <commit> tests=<n passed>` | `REJECTED T4 attempt=<n> notes=<count>` | `TAKEOVER T4 <reason>`.

6. **Handle the outcome:**
   - **`MERGED`:** set T4 to `taken-over (sonnet)`, log `HH:MM T4 MERGED <commit> tests=<n> (takeover, sonnet)`, then continue the loop. Tasks that depend on T4 become ready.
   - **`REJECTED`:** go up one rung to `opus`, re-run step 4 with the new notes, and review again. If `opus` is also rejected, stop and ask you, because a task that fails at the top rung usually means the plan section is wrong.
   - **`BLOCKED`:** log the reason and ask you only if it's a question about the design or goal.

7. **Keep the other work moving.** Tasks that don't depend on T4 keep running within `concurrency` while the takeover happens.

**Reply to you**

> T4 hit 3 rejections, so a Claude subagent on sonnet is taking it over with the full task and all the review notes. Its result gets the same review and tests before anything is merged, and it's marked `taken-over` in `board.md`. If sonnet is also rejected, I'll move to opus; if that fails too, I'll ask you about the plan. Other ready tasks keep running.