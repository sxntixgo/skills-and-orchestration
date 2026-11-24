T4 now gets a takeover: no fourth opencode dispatch. A Claude subagent implements it on the model ladder, then it goes through the normal review.

**Assumptions:** the run is `2026-11-23-<slug>` and comes from `board.md`. T4 is ordinary feature work with no `review: opus` mark. It lives in worktree `.worktrees/T4` on branch `orchestra/T4`. The three rejection notes are under `.orchestra/<run>/reviews/T4-*.md`. I don't read those notes or the diff in this thread; the subagent does.

**1. Update `board.md`.** Set T4's status to `sent-back` and add this Log line:
```
- HH:MM T4 REJECTED attempt=3 → max_rejections reached; takeover (sonnet)
```

**2. Takeover subagent** (Agent tool, `model: sonnet`). Sonnet is the default rung for normal feature work. If T4 were marked `review: opus` or the notes pointed to a design flaw, I'd use `opus`.
> You are taking over task T4 of orchestration run `<run>` in repo `/workspaces/<repo>`. opencode failed it 3 times.
> Task spec: `.orchestra/<run>/tasks/T4.task.md`. Review notes from all 3 rejections: `.orchestra/<run>/reviews/T4-*.md`. Read both first.
> Work in `.worktrees/T4` (branch `orchestra/T4`). Keep opencode's commits only where they're sound; otherwise reset to `base_branch` and start over.
> Rules: TDD (write the failing test first, then the code), YAGNI (only what the spec asks for), DRY (reuse existing shared code, don't duplicate it). Touch only the files the spec lists. Fix every point in the review notes. Run the task's test command and the repo's `lint_cmd` until both pass, then commit. Don't merge, push, or edit `board.md`.
> Reply with one line: `DONE T4 <commit> tests=<n passed>` or `BLOCKED T4: <reason>`.

**3. On `DONE`, run a review subagent** (`model: review_model`, or `opus` if T4 is marked `review: opus`):
> Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `T4` in repo `/workspaces/<repo>`. This is a Claude takeover (sonnet), so review it like any other result. Reply with one line: `MERGED T4 <commit> tests=<n passed>` | `REJECTED T4 attempt=<n> notes=<count>` | `TAKEOVER T4 <reason>`.

**4. Record the outcome:**
- `MERGED`: status becomes `taken-over (sonnet)`, with Log line `HH:MM T4 taken over by sonnet, merged <commit>, tests=<n>`. Tasks that depend on T4 become ready and the loop continues.
- `REJECTED`: run the takeover again one rung up the ladder (`opus`) with the new notes, then review again.
- `BLOCKED`: log the reason. If it's a plan or design issue, ask you about it, because the design is your call.

**Reply to you:** "T4 hit 3 rejections, so a sonnet subagent is taking it over with the full spec and all the review notes. Its work gets the normal review before merging. If that review rejects it too, I'll move the takeover up to opus. The other tasks keep running in the meantime."