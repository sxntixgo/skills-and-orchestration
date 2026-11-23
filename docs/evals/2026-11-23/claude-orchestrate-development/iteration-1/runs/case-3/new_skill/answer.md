**T4 isn't dispatched to opencode again. A Claude subagent now implements it in the existing worktree, and it gets the normal review.** Three rejections uses up `max_rejections`, so the next step is a takeover.

**Assumptions:** the run is `2026-11-22-csv-export` in `/workspaces/app`. The config uses the defaults (`review_model: sonnet`). T4 is normal feature work ("CSV export endpoint + tests"), not marked `review: opus`. Its worktree `.worktrees/2026-11-22-csv-export/T4` still holds the third attempt. `tasks/T4.task.md` holds the review notes from all three attempts.

### 1. Update `board.md`
- T4 status: `sent-back` → `taken-over`.
- Log line: `2026-11-23 10:42 T4 rejected (attempt 3/3) → takeover: sonnet`

### 2. Pick the model (from `takeover.md`)
- **sonnet:** I'm choosing this because it's normal feature work across a few files, and opencode got close but kept missing things.
- **haiku:** I'd use this only if the notes spelled out an exact mechanical fix in 2 files or fewer.
- **opus:** I'd go straight to this if the goal cell said `review: opus` (auth, input parsing, files or network), or if the notes pointed to a spec or design flaw.

I don't open the diff or the notes in this thread. The subagent reads them.

### 3. Spawn the takeover subagent (Agent tool, `model: sonnet`)
> You are implementing orchestration task T4 yourself. Work only in `/workspaces/app/.worktrees/2026-11-22-csv-export/T4`. Don't commit, push or switch branches. Don't touch `.git/` or `.orchestra/`.
> Read `/workspaces/app/.orchestra/2026-11-22-csv-export/tasks/T4.task.md`. It covers the goal, allowed files, steps, Done when, Out of scope, and the **Notes from review** for attempts 1–3. Fix every note. The worktree holds opencode's third attempt. Keep what's correct and replace what the notes reject.
> Summary of earlier failures: across 3 attempts opencode kept failing the same review notes (details are in the task file).
> Rules: TDD (a failing test first, then the simplest code that passes), YAGNI, DRY (reuse existing helpers) and the repo's style (`CLAUDE.md`). Change only the files the task allows.
> Run `<exact test command from Done when>` until it passes. Reply with: files changed, the test command, the last ~20 lines of its output, and anything you could not do.

### 4. Review it (Agent tool, `model: sonnet`, or `opus` if T4 is marked `review: opus`)
> Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-22-csv-export`, task `T4` in repo `/workspaces/app`. This is a takeover by **sonnet**: run steps 2–4 on the worktree as usual and mark the task `taken-over (sonnet)`. If the skill isn't loaded, read `plugins/orchestration/skills/claude-review-merge/SKILL.md`. Reply with one line: `MERGED T4 <commit> tests=<n passed>` | `REJECTED T4 attempt=4 notes=<count>`.

### 5. Act on the verdict
- **`MERGED`:** T4 becomes `taken-over (sonnet)` with its commit. Log: `T4 merged via takeover (sonnet) <commit> tests=…`. Tasks that depend on T4 become ready.
- **`REJECTED`:** go up one model. A new `opus` subagent gets the same prompt plus the new notes, then the same review. One model never gets two attempts.
- **opus also rejected:** stop work on T4, set it to `blocked` and log it. I tell you what failed, and T4 plus its dependents wait for your decision.

While this runs, the loop keeps dispatching other ready tasks whose files don't overlap with T4's, within `concurrency`.

### Reply to user
> T4 used up its 3 opencode attempts, so it's now a takeover. A Sonnet subagent is reworking it in T4's worktree using all the review notes, and it gets the same review before merging. If Sonnet's version is rejected, Opus takes one try. If Opus fails too, I'll stop and bring T4 to you. Independent tasks keep running in the meantime.