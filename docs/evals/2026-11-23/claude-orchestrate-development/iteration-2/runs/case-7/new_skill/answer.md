I'm treating this as a resume of the existing run. Phase 1 continues in this session: review T1 and T2, dispatch the rest of phase 1, run the phase review, then stop.

**Assumptions:** run `2026-11-23-export` already exists, and its `board.md` lists phase 1 as:
- T1: shared `export/serializers.py` and its tests
- T2: `export/csv_writer.py`, marked `review: opus` because it writes files
- T3: export endpoint, depends on T1 and T2

T1 and T2 are `dispatched`, phases 2 and 3 are `todo`, and `config.json` uses the defaults (concurrency 2, sonnet for specs and reviews).

### 1. TodoWrite
1. Plan gate: the plan exists and is committed, so it passes.
2. Resume: read the board and the plan.
3. Check that T1 and T2 have finished.
4. Review T1.
5. Review T2.
6. Loop through the rest of phase 1 (T3).
7. Phase 1 review.
8. Update the board and stop.

### 2. Resume (orchestrator thread reads only the board and the plan)
```
cat .orchestra/2026-11-23-export/board.md
cat docs/plans/2026-11-23-export-plan.md
```

### 3. Confirm T1 and T2 finished (I won't read the logs here)
```
for t in T1 T2; do test -f .worktrees/2026-11-23-export/$t/RESULT.md && echo "$t done"; done
pgrep -fl "opencode.*2026-11-23-export/T[12]" || echo "no runs alive"
```
Assumed result: both `RESULT.md` files exist and no process is alive. I set both rows to `review`, then log:
`- 2026-11-23 HH:MM T1, T2 runs finished → review`

### 4. Review T1 (one review subagent at a time, because each may merge into `main`)
Agent, `model: sonnet`:
> Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-export`, task `T1` in repo `/workspaces/<repo>`. If the skill isn't loaded, read `plugins/orchestration/skills/claude-review-merge/SKILL.md`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`.

The next step depends on the reply:
- **MERGED:** set the row to `merged` and log `T1 merged <commit> tests=<n>`.
- **REJECTED:** set the row to `sent-back`, then `claude-dispatch` T1 with `--continue` (attempt 2) and log it.
- **TAKEOVER:** follow `takeover.md` and log the model used.

### 5. Review T2 (after T1's reply)
Same prompt with `T2` and **`model: opus`**, because T2 writes files. Update the board and log the result the same way.

### 6. Rest of phase 1
T3 is ready only when T1 and T2 are both merged. If one was sent back, T3 waits, and I watch that re-dispatch with the same finish check.

Spec subagent, `model: sonnet`:
> Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-export/tasks/T3.task.md` for: `| T3 | 1 | export endpoint GET /export?format=csv (review: opus) | opencode | T1,T2 | api/export.py, tests/test_export_api.py | todo |` + plan section `docs/plans/2026-11-23-export-plan.md#phase-1`. Reply with one line: the path, or `BLOCKED: <reason>`.

Then `claude-dispatch` T3 from this thread. I set it to `dispatched`, log it, and wait for the run to finish. Then step 4 again with `model: opus`, looping until T3 is `merged` (or `taken-over` after 3 rejections).

### 7. End of phase 1
Agent, `model: opus`:
> In `/workspaces/<repo>`, review `git diff <phase-1 start commit>..main` (use the `code-review` skill if installed). Look only for what per-task reviews miss: duplication across T1–T3, inconsistent patterns, missing integration with the plan's phase 1 goals. Reply with ≤5 lines: each finding as a proposed task (goal, files, test command), or `NO FINDINGS`.

Findings become new `todo` rows in phase 2 of `board.md`, or a fix task now if something is broken. Log:
`- 2026-11-23 HH:MM Phase 1 review: <n findings → T9..> | none`

I don't push or open a PR; the user does that.

### 8. Final message
> Phase 1 done: T1 merged (`<sha>`), T2 merged (`<sha>`), T3 merged (`<sha>`), tests passing on `main`. The phase review added <n> tasks to phase 2 (or: no findings). Start a new session and say: resume run `2026-11-23-export`.

If any task is still waiting on a send-back, the message lists it with its attempt number.