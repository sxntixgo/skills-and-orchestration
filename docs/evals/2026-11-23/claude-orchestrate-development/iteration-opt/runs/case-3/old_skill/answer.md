T4 doesn't go to opencode a fourth time. Three rejections means a Claude subagent takes it over. I'd take these steps in this session:

**1. Update `board.md`.** I'm assuming the run is `.orchestra/2026-11-21-<slug>/`. I'd change T4's status to `taken-over` and add one Log line:
```
- 14:32 T4 REJECTED attempt=3 → max_rejections reached; takeover (sonnet)
```

**2. Pick the model.** I'd use only T4's board row and the one-line review verdicts, without opening the diff or logs here. I'm assuming T4 is ordinary feature work (a few files, real logic) and isn't marked `review: opus`, so I'd start on **sonnet**. If it were marked `review: opus`, or the three rejections pointed to a design flaw or a bug nobody has found, I'd start on **opus** instead.

**3. Spawn the takeover subagent** (Agent tool, `model: sonnet`):
> You are taking over task T4 of orchestration run `<run>` in `/workspaces/<repo>`. Work only in the worktree `/workspaces/<repo>/.worktrees/<run>/T4` (branch `orchestra/<run>/T4`); don't commit, push, or switch branches. Read `/workspaces/<repo>/.orchestra/<run>/tasks/T4.task.md` in full: goal, Files (edit only the "may change/create" files), Steps, Done when, Out of scope, and every "Notes from review" entry. Opencode failed 3 times; the review notes list what each attempt got wrong, so fix those first. The worktree holds attempt 3's code: keep what's correct and replace what isn't. Rules: TDD (failing test first, then the simplest code that passes), YAGNI, DRY (reuse existing helpers), follow the repo's style and `CLAUDE.md`/`AGENTS.md`. Run `<exact test command from T4.task.md>` until it passes. Reply with: the files changed, the test command, the last ~20 lines of its output, and anything you couldn't do.

**4. Review it** with one subagent (`model: review_model`, or `opus` if T4 is marked `review: opus`):
> Use the `claude-review-merge` skill (orchestration plugin) for run `<run>`, task `T4` in repo `/workspaces/<repo>`. This is a takeover by a Claude subagent (sonnet), so run steps 2–4 on the worktree as usual. Reply with one line: `MERGED T4 <commit> tests=<n passed>` | `REJECTED T4 attempt=<n> notes=<count>` | `TAKEOVER T4 <reason>`.

**5. Handle the verdict:**
- **Merged:** set T4 to `taken-over` (merged by sonnet) and log `T4 MERGED <commit> (takeover: sonnet)`. Tasks that depend on T4 become ready and the loop continues.
- **Rejected:** move up one model (sonnet → opus) and repeat steps 3–4. No model gets two attempts. Log each try.
- **Opus also rejected:** stop work on T4, log it, and report to you with the reason. The rest of the graph keeps going wherever it doesn't depend on T4.

While this runs, other ready tasks keep dispatching within `concurrency`. I won't patch T4's code in the orchestrator thread.

**Reply to you:**
> T4 is past `max_rejections`, so a sonnet subagent is now implementing it in the existing worktree, using the spec and all three rounds of review notes. A separate review subagent will check it the same way as opencode's work. If sonnet's result is rejected, opus tries next. If opus also fails, I'll stop on T4 and bring it to you. Nothing is needed from you right now.