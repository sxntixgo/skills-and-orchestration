T4 is now a takeover. A fourth opencode dispatch is not allowed, so a Claude subagent implements T4 instead, then it gets the normal review.

**1. Read state (orchestrator thread: `board.md` only)**
- `cat .orchestra/<run>/board.md` to get T4's row: goal, files, test command, phase, and whether it's marked `review: opus`.
- **Assumption:** the run is `2026-11-23-<slug>`, and T4 is normal feature work (one endpoint plus tests, about 3 files) with no `review: opus` mark. I don't open the diff, the review notes or opencode's logs here. The subagent reads them.

**2. Update `board.md`**
- T4 status: `rejected` → `taken-over (pending)`. Implementer: `claude:sonnet`.
- Log line: `HH:MM T4 REJECTED attempt=3 (max_rejections) → takeover, model=sonnet`

**3. Pick the model**
Sonnet, the default for normal feature work. If T4 touches auth, secrets, input parsing, concurrency, or three rejections point to a design flaw in the spec, I'd use opus instead. Haiku doesn't fit: work that failed three times isn't mechanical.

**4. Spawn the takeover subagent** (Agent tool, `model: sonnet`)
> You are taking over task T4 of orchestration run `<run>` in repo `/workspaces/<repo>`. opencode's attempts were rejected 3 times.
> - Task spec: `.orchestra/<run>/tasks/T4.task.md`. Read it in full; it is the contract.
> - Review notes from all 3 rejections: `.orchestra/<run>/tasks/T4.review-*.md`. Every point must be addressed.
> - opencode's last branch `orchestra/T4` is reference only. Don't build on it blindly.
> - Work in a fresh worktree: `git worktree add .worktrees/T4-takeover -b orchestra/T4-takeover <base_branch>`.
> - Rules: TDD (failing test first, then code). YAGNI (only what the spec asks). DRY (reuse shared code from earlier tasks, no copies). Change only the files the spec lists.
> - Run the task's test command and `lint_cmd` until they pass. Commit on the branch. Don't merge or push.
> - Write `RESULT.md` in the worktree (what changed, test output summary).
> - Reply with one line: `DONE T4 <commit> tests=<n passed>` or `BLOCKED T4 <reason>`.

**5. Review subagent** (Agent tool, `model: sonnet` from `review_model`; opus if T4 is `review: opus`)
> Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `T4` (takeover, branch `orchestra/T4-takeover`) in repo `/workspaces/<repo>`. Reply with one line: `MERGED T4 <commit> tests=<n passed>` | `REJECTED T4 attempt=<n> notes=<count>` | `TAKEOVER T4 <reason>`.

**6. Act on the verdict and log it**
- **MERGED:** status becomes `taken-over (sonnet)`. Log `HH:MM T4 MERGED <commit> via takeover (sonnet)`. Remove the `.worktrees/T4` and `T4-takeover` worktrees and the `orchestra/T4*` branches. Continue the loop: tasks that depend on T4 are now ready.
- **REJECTED:** move up one model (sonnet → opus) and run the takeover again with the new notes. Log it.
- **BLOCKED** (e.g. the spec contradicts the plan): log it, keep T4 out of the merged set, and ask you whether to change that part of the plan or drop T4. Changing the design is your call.

**Reply to you:**
> T4 hit max_rejections, so a Claude subagent (sonnet) has taken it over with the full spec and all 3 rounds of review notes. It goes through the same review before merging, and other ready tasks keep running meanwhile. I'll report the verdict; you only need to step in if it comes back BLOCKED.