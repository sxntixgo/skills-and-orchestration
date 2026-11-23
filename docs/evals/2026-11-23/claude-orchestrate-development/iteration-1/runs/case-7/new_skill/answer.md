This is a resume, not a new run. T1 and T2 already came back, so the run directory and `board.md` exist. I'd pick up from the board, review the two results one at a time, finish phase 1, run the phase review, then stop.

**Assumptions:** the repo is `/workspaces/app` and the run is `2026-11-23-export`. Config is at its defaults (`concurrency: 2`, `review_model: sonnet`, `max_rejections: 3`). Phase 1 on the board is T1 (CSV serializer), T2 (export job model and storage, marked `review: opus` because it writes files) and T3 (export endpoint, `depends_on: [T1, T2]`). T1 and T2 are `dispatched`.

### 1. Plan gate and resume
- The plan exists (`docs/plans/2026-11-23-export-plan.md`), so the gate passes.
- TodoWrite: plan gate ✓, resume run, review T1, review T2, dispatch ready phase-1 tasks, phase-1 review, hand off.
- Read only `.orchestra/2026-11-23-export/board.md` and the plan. I wouldn't read source files, diffs, logs or the contents of RESULT.md here.
- Confirm both runs have finished without reading anything:
  ```bash
  cd /workspaces/app
  test -f .worktrees/2026-11-23-export/T1/RESULT.md && echo T1 done
  test -f .worktrees/2026-11-23-export/T2/RESULT.md && echo T2 done
  ```
- Update `board.md`: T1 and T2 → `review`.
  - Log: `HH:MM T1, T2 runs finished → review`

### 2. Reviews (one subagent at a time, because each one may merge into `main`)
- **Subagent A** (`model: sonnet`): "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-export`, task `T1` in repo `/workspaces/app`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`. If the skill isn't loaded, read `plugins/orchestration/skills/claude-review-merge/SKILL.md`."
- When A replies, update `board.md` with the status and one log line, e.g. `HH:MM T1 MERGED a1b2c3d tests=14`.
- **Subagent B** (`model: opus`, because T2 is marked `review: opus`): same prompt for `T2`.
- Depending on the replies:
  - **MERGED:** set status `merged` and log it.
  - **REJECTED:** set `sent-back`. The review skill has already written the notes into the task file and bumped the attempt. Re-dispatch with `--continue` through `claude-dispatch`. I wouldn't fix the code here.
  - **Third rejection, or TAKEOVER:** follow the takeover reference and mark the task `taken-over`.

### 3. Continue the loop
- Once T1 and T2 are merged, T3 is ready. Spec subagent (`model: sonnet`): "Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-export/tasks/T3.task.md` for: `<T3 row from board.md>` + plan section `docs/plans/2026-11-23-export-plan.md#phase-1`. Reply with one line: the path, or `BLOCKED: <reason>`."
- Dispatch T3 with `claude-dispatch`.
  - Board: T3 → `dispatched`.
  - Log: `HH:MM T3 dispatched (attempt 1)`
- When T3 finishes, review it the same way as T1 and T2, then update the board and log.
- No phase-2 task gets dispatched in this session, even if a slot is free.

### 4. End of phase 1
- Once every phase-1 task is merged or dropped, spawn an `opus` subagent: "Run the `code-review` skill over `git diff <phase-1 start commit>..main` in `/workspaces/app` for run `2026-11-23-export` phase 1. Look only for what per-task reviews can't see: duplication across tasks, inconsistent patterns, missing integration. Reply with at most 5 one-line findings, or `NONE`."
- Each finding becomes a phase-2 row in `board.md`, or a phase-1 fix task if it blocks phase 2.
  - Log: `HH:MM phase 1 review: <n> findings → T<x>…`
- Stop the session there.

### Final reply to the user
> Phase 1 done: T1 merged (opencode, first try), T2 merged (opencode, first try), T3 merged. The phase review found `<n>` issues, which I added as phase-2 tasks `<ids>`. Start a new session and say: resume run `2026-11-23-export`.

If a review rejects a task, the reply lists it as "after send-back" (or "taken over") and the session keeps going until phase 1 is fully merged or dropped. Nothing gets pushed; pushing stays your step.