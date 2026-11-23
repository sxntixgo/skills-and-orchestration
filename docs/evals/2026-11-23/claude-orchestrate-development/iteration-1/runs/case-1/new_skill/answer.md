The plan is at `docs/plans/csv-export.md`, so it passes the plan gate (step 0). I'd orchestrate phase 1, run the phase review, then stop and hand off to a new session.

**Assumptions** (nothing on disk):
- The repo is `/workspaces/jobs`: Python/FastAPI with pytest via `uv`.
- `CLAUDE.md` gives `test_cmd = uv run pytest -q` and `lint_cmd = uv run ruff check .`.
- The plan has two phases:
  - **Phase 1, backend:** turn jobs into CSV rows, then a `GET /jobs/export.csv` endpoint that uses the list's existing filters, requires login and streams the file.
  - **Phase 2, UI:** an "Export CSV" button on the jobs list that keeps the current filters.
- No `.orchestra/config.json` exists yet.

### 1. TodoWrite
Six items: 0 plan gate ✅, 1 set up the run, 2 task graph, 3 loop, 4 end-of-phase review, 5 finish.

### 2. Set up the run
```bash
cd /workspaces/jobs
cat docs/plans/csv-export.md CLAUDE.md AGENTS.md 2>/dev/null
mkdir -p .orchestra/2026-11-23-csv-export/{tasks,logs}
grep -qx '.orchestra/' .git/info/exclude || echo '.orchestra/' >> .git/info/exclude
grep -qx '.worktrees/' .git/info/exclude || echo '.worktrees/' >> .git/info/exclude
git status --porcelain && git branch --show-current   # must be empty + main
uv run pytest -q                                       # must pass
```
⛔ I stop and tell the user if the tree isn't clean, the branch isn't `main`, or the tests fail.

`.orchestra/config.json` (the contract defaults, plus the commands from `CLAUDE.md`):
```json
{ "implementer": "opencode", "model": "atlas/qwen3.8-flash-next", "concurrency": 2,
  "task_timeout_min": 30, "max_rejections": 3, "base_branch": "main",
  "stall_empty_s": 180, "stall_s": 600, "stall_retries": 1,
  "test_cmd": "uv run pytest -q", "lint_cmd": "uv run ruff check .",
  "spec_model": "sonnet", "review_model": "sonnet" }
```

### 3. Task graph
I write `.orchestra/2026-11-23-csv-export/board.md` without asking the user to approve it:
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/csv-export.md
Phase 1 start: <sha of main>

| id | phase | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|---|
| T1 | 1 | `jobs_to_csv(jobs)` → CSV rows: plan's columns/order, ISO dates, escape cells starting with = + - @ (CSV injection). **review: opus** | opencode | – | app/jobs/csv_export.py, tests/jobs/test_csv_export.py | todo |
| T2 | 1 | `GET /jobs/export.csv`: auth required, reuses list filters, streams T1 output with Content-Disposition. **review: opus** | opencode | T1 | app/jobs/routes.py, tests/jobs/test_export_route.py | todo |
| T3 | 2 | "Export CSV" button on jobs list keeps current query string, + template test | opencode | T2 | app/templates/jobs/list.html, tests/jobs/test_list_page.py | todo |

Test commands: T1 `uv run pytest tests/jobs/test_csv_export.py -q`; T2 `uv run pytest tests/jobs/test_export_route.py -q`; T3 `uv run pytest tests/jobs/test_list_page.py -q`.

## Log
- 2026-11-23 HH:MM run set up; graph: 3 tasks, 2 phases
```
**Self-check:**
- Every requirement in the plan maps to one of the three tasks.
- T1 is the shared code, so T2 reuses it.
- No two tasks overlap in files.
- Each task has an exact test command.
- The work is a dependency chain, so only one task runs at a time. Splitting it further would only add specs that are about as long as the code.
- T1 is `review: opus` because it handles file output and CSV injection. T2 is `review: opus` because it handles auth.

### 4. Loop (phase 1)
**T1 spec:** subagent, `model: "sonnet"`:
> Use the `claude-write-task` skill (orchestration plugin; if not loaded, read `plugins/orchestration/skills/claude-write-task/SKILL.md`) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: `T1 | 1 | jobs_to_csv(jobs) … review: opus | opencode | – | app/jobs/csv_export.py, tests/jobs/test_csv_export.py` + plan section `docs/plans/csv-export.md#Phase 1: CSV serialization`. Reply with one line: the path, or `BLOCKED: <reason>`.

If the reply is the path, I run the `claude-dispatch` skill for T1. It creates the worktree `.worktrees/2026-11-23-csv-export/T1` on branch `orchestra/2026-11-23-csv-export/T1` and runs opencode in the background, logging to `logs/T1.1.jsonl`. On the board, T1 → `dispatched`, and I add a Log line.

**When the run finishes:** review subagent, `model: "opus"` (T1 is `review: opus`):
> Use the `claude-review-merge` skill (orchestration plugin; else read `plugins/orchestration/skills/claude-review-merge/SKILL.md`) for run `2026-11-23-csv-export`, task `T1` in repo `/workspaces/jobs`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`.

- **`MERGED`:** T1 → `merged` and I log `HH:MM T1 merged <commit> tests=N (opencode, attempt 1)`.
- **`REJECTED`:** T1 → `sent-back`, then I dispatch it again with `--continue` (attempt + 1).
- **After 3 rejections:** takeover. A `sonnet` subagent implements T1 in the worktree using the prompt in `takeover.md`, then it gets the same review. T1 → `taken-over`.

I don't read diffs, source files or logs in this thread. The board gets one Log line after every change of state.

**T2:** becomes ready once T1 is merged, and goes through the same cycle: spec subagent (sonnet), dispatch, review subagent (`opus`, because of auth).

### 5. End of phase 1
Subagent, `model: "opus"`:
> Use the `code-review` skill on `git diff <phase-1-start>..main` in `/workspaces/jobs` (CSV export phase 1: T1, T2). Look for what per-task reviews miss: duplication across tasks, inconsistent patterns, missing integration (e.g. filters the endpoint ignores, unescaped columns). Reply with up to 5 one-line findings, or `NONE`.

Any findings become fix tasks: phase 2 tasks, or a T2a now if one is blocking. I log `HH:MM phase 1 review: <n findings>` and update the board.

### Reply to the user (end of this session)
> Phase 1 of the CSV export is merged into `main` (T1 `jobs_to_csv`, T2 `GET /jobs/export.csv`; outcomes and test counts are in `.orchestra/2026-11-23-csv-export/board.md`). The phase review found <n> issues, which are now tasks in phase 2.
>
> Phase 1 done. Start a new session and say: resume run `2026-11-23-csv-export`.

### Next session (phase 2), then finish
1. I read only `board.md` and the plan, then run T3 through the same loop, followed by the phase review.
2. I check that `uv run pytest -q` and the lint pass on `main`.
3. I remove the worktrees and branches with `git worktree remove .worktrees/2026-11-23-csv-export/*` and `git branch -D orchestra/2026-11-23-csv-export/*`.
4. **Final report:**
   - each task's outcome: opencode first try, after a send-back, or taken over
   - commits and the full test result
   - what's left for the user: pushing and opening a PR, which I don't do