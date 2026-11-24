Resuming the existing run. T1 and T2 go to review one at a time, the rest of phase 1 follows, and the session stops after the phase 1 review. Phases 2–3 run in later sessions.

**Assumptions:** The run is `2026-11-23-export`. `.orchestra/2026-11-23-export/board.md` exists with phase 1 = T1 (export serializer), T2 (CSV writer) and T3 (`/export` endpoint, depends on T1 and T2, marked `review: opus`). T1 and T2 are `dispatched`. Config uses the defaults: `concurrency` 2, `max_rejections` 3, `spec_model`/`review_model` sonnet. The plan was already gated (it's written and committed), so steps 0–2 are done.

### 1. TodoWrite
- Resume: board + plan
- Review T1
- Review T2
- Phase 1 loop (T3 …)
- Phase 1 review (opus)
- Hand off

### 2. Resume (read only `board.md` and the plan)
```bash
cat .orchestra/2026-11-23-export/board.md
cat docs/plans/2026-11-23-export-plan.md
ls .worktrees/T1/RESULT.md .worktrees/T2/RESULT.md   # existence only; RESULT.md is not read here
```
If either `RESULT.md` is missing, that run is still going and it stays `dispatched`.

**Board:** T1 and T2 → `review`.
**Log:** `HH:MM T1, T2 returned from opencode → review`

### 3. Reviews, one subagent at a time (each may merge into main)
**Agent T1** (model `sonnet`):
> Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-export`, task `T1` in repo `/workspaces/<repo>`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`.

After it replies, **Agent T2** gets the same prompt with `T2`.

Per verdict:
- `MERGED` → status `merged`. Log: `HH:MM T1 MERGED <commit> tests=<n>`.
- `REJECTED` (attempt < 3) → status `sent-back`, then `claude-dispatch` with `--continue` and the review notes. Status → `dispatched`, logged.
- `TAKEOVER`, or a third rejection → a Claude subagent one model-ladder step up (sonnet → opus). Its prompt has the full task, the review notes and the rules TDD/YAGNI/DRY. Then a review like above. Status `taken-over (<model>)`.

I don't read diffs, source or logs here, and I don't fix code inline.

### 4. Rest of phase 1
Once T1 and T2 are merged, T3 is ready.

**Spec Agent** (`sonnet`):
> Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-export/tasks/T3.task.md` for: `<T3 row from board.md>` + plan section `docs/plans/2026-11-23-export-plan.md#Phase 1`. Reply with one line: the path, or `BLOCKED: <reason>`.

Then `claude-dispatch` T3 (status `dispatched`, logged). When it returns, the review subagent runs on **`opus`** because T3 is marked `review: opus`. I update `board.md` and the Log after every state change.

### 5. Phase 1 review
**Agent** (`opus`):
> Use the `code-review` skill if installed. Review `git diff <phase-1 start commit>..main` in `/workspaces/<repo>` for run `2026-11-23-export` phase 1. Look for what per-task reviews miss: duplication across T1–T3, inconsistent patterns, missing integration. Reply with at most 5 one-line findings, or `CLEAN`.

Each finding becomes a new phase-2 row in `board.md` (or a fix task now if it blocks).
**Log:** `HH:MM Phase 1 review: <n findings → tasks …>`

### 6. Final reply
> Phase 1 done: T1 and T2 <merged first try / after send-back>, T3 merged; phase review added <n> tasks to phase 2. Start a new session and say: resume run `2026-11-23-export`.