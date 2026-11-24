**Dry-run plan** for orchestrating `docs/plans/csv-export.md` in `/workspaces/jobs`. Nothing below was run; every file and result is assumed.

**What I assume**
- The plan exists and is committed. It has two phases:
  - **Phase 1:** CSV export of the jobs list. Status and date filters, every field the plan lists, formula-injection escaping, and an export endpoint.
  - **Phase 2:** an "Export CSV" button in the jobs list UI.
- Each task in the plan has its own test command.
- Stack is Python/FastAPI with pytest. Per `CLAUDE.md`, the tests run with `uv run pytest -q` and lint with `uv run ruff check .`.
- `.orchestra/config.json` doesn't exist yet. The working tree is clean on `main`.

---

### TodoWrite
0 Plan gate · 1 Set up run · 2 Task graph · 3 Dispatch/review loop (Phase 1) · 4 Phase 1 review, then hand off

### 0. Plan gate
**Passed.** The user named a written plan, and I assume it's committed. No design work is needed.

### 1. Set up the run
I'd read only `docs/plans/csv-export.md` and `CLAUDE.md`, then run:
```bash
cd /workspaces/jobs
git status --porcelain && git rev-parse --abbrev-ref HEAD      # expect: empty, main
mkdir -p .orchestra/2026-11-23-csv-export/{tasks,logs}
printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
uv run pytest -q 2>&1 | tail -1                                  # expect: N passed
```
I'd write `.orchestra/config.json` with the contract defaults plus the repo's commands:
```json
{ "implementer": "opencode", "model": "atlas/qwen3.8-flash-next", "concurrency": 2,
  "task_timeout_min": 30, "max_rejections": 3, "base_branch": "main",
  "stall_empty_s": 180, "stall_s": 600, "stall_retries": 1,
  "test_cmd": "uv run pytest -q", "lint_cmd": "uv run ruff check .",
  "spec_model": "sonnet", "review_model": "sonnet" }
```
If the tree is dirty, the branch isn't `main`, or the tests fail, I stop and tell the user.

### 2. Task graph
I'd write `.orchestra/2026-11-23-csv-export/board.md` without asking for approval:
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/csv-export.md

| id | phase | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|---|
| T1 | 1 | Jobs query → CSV rows (columns per plan, formula-injection escaping) + tests. review: opus | opencode | – | app/export/csv_export.py, tests/export/test_csv_export.py | todo |
| T2 | 1 | GET /jobs/export.csv: parse status/date filters, stream T1 output, Content-Disposition + tests. review: opus | opencode | T1 | app/api/jobs_export.py, app/api/__init__.py, tests/api/test_jobs_export.py | todo |
| T3 | 2 | "Export CSV" button on jobs list, passes current filters + component test | opencode | T2 | web/src/jobs/ExportButton.tsx, web/src/jobs/JobsList.tsx, web/src/jobs/ExportButton.test.tsx | todo |

## Log
- 2026-11-23 HH:MM run created; 3 tasks, Phase 1 = T1–T2
```
Self-check:
- Every requirement in the plan maps to a task.
- Each task has its own test command: `uv run pytest tests/export -q`, `uv run pytest tests/api/test_jobs_export.py -q`, and `npm --prefix web test -- ExportButton`.
- No two tasks that run at the same time share a file.
- T2 depends on T1, so Phase 1 runs one task at a time.
- Nothing is small enough to fold into a neighbouring task.
- T1 and T2 are marked `review: opus` because they handle input parsing and file output.

### 3. Loop (Phase 1)
**Spec for T1.** Subagent on `sonnet`:
> Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: `T1 | 1 | Jobs query → CSV rows … | opencode | – | app/export/csv_export.py, tests/export/test_csv_export.py` + plan section `docs/plans/csv-export.md#phase-1-csv-export`. Reply with one line: the path, or `BLOCKED: <reason>`.

**Dispatch T1** in the background:
```bash
bash <plugin>/skills/claude-dispatch/scripts/dispatch.sh 2026-11-23-csv-export T1
```
Then T1 → `dispatched (attempt 1)` on the board, with a log line.

While T1 runs, I'd write T2's spec with the same kind of subagent prompt.

**When the dispatch line reads `exit=0 result=yes`:** a review subagent on `opus`, because T1 is marked `review: opus`:
> Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-csv-export`, task `T1` in repo `/workspaces/jobs`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` | `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`.

**Outcomes:**
- `MERGED`: mark the task `merged` and log it. Then T2 is ready: dispatch it the same way, then an `opus` review.
- `REJECTED`: mark it `sent-back`. Dispatch again with `--continue`. After 3 rejections it becomes a takeover.
- Other exit codes follow the `claude-dispatch` table. Exit 4 or 125 means pausing and telling the user.

After every state change I'd add one log line, for example: `- 14:32 T1 MERGED a1b2c3d tests=8 (opencode, attempt 1)`.

I wouldn't read any source file, diff or opencode log in the orchestrator thread.

### 4. End of Phase 1
A subagent on `opus`:
> Review `git diff <phase-1 start sha>..main` in `/workspaces/jobs` with the `code-review` skill if installed. Look for what per-task reviews can't see: duplication across T1/T2, inconsistent patterns, missing integration with the plan in `docs/plans/csv-export.md#phase-1`. Reply with ≤5 one-line findings, each phrased as a task goal with files, or `NONE`.

Any findings become Phase 2 tasks on the board. I'd log `Phase 1 review: <n findings>`, then stop the session.

### Final message (after Phase 1, assuming the clean path)
> **Phase 1 is done: T1 and T2 are merged into `main`, and the full suite and lint pass.**
>
> | Task | Outcome |
> |---|---|
> | T1 CSV builder | merged, opencode first try |
> | T2 `/jobs/export.csv` endpoint | merged, opencode first try |
>
> The phase review found `<n>` issues; they were added to Phase 2 as `<ids>`.
>
> Start a new session and say: resume run `2026-11-23-csv-export`. Nothing has been pushed; that's your call once Phase 2 is merged.