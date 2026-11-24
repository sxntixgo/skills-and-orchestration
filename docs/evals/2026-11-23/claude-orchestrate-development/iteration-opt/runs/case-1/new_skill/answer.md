Plan found at `docs/plans/csv-export.md`, so the plan gate passes. Below is what I would do in order: set up the run, run Phase 1 through opencode with subagent specs and reviews, then stop and hand off. I assumed everything I couldn't see; the assumptions are listed first.

**Assumptions**
- The plan is committed. It has two phases:
  - **Phase 1 (backend):** a CSV serializer for jobs, then a `GET /jobs/export.csv` endpoint that respects the list filters and is limited to logged-in users.
  - **Phase 2 (UI):** an "Export CSV" button on the jobs list that carries the current filters.
- Each task in the plan has a test command.
- The repo is `/workspaces/jobs`, a Django app. Its `CLAUDE.md` gives `pytest` for tests and `ruff check .` for lint.
- There is no existing `.orchestra/config.json`.

---

**1. TodoWrite**, one item per step: Plan gate ✅ · Set up run · Task graph · Loop · End of phase · Finish (last phase).

**2. Set up the run**
```bash
cd /workspaces/jobs
git status --porcelain && git rev-parse --abbrev-ref HEAD   # expect: clean, main
git log --oneline -1 -- docs/plans/csv-export.md            # confirm the plan is committed
mkdir -p .orchestra/2026-11-23-csv-export/tasks
printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
pytest -q                                                   # baseline must pass
```
I read the plan, `CLAUDE.md` and `AGENTS.md`. If the tree isn't clean, the branch isn't `main`, or the baseline tests fail, I stop and tell you.

`.orchestra/config.json`:
```json
{ "concurrency": 2, "max_rejections": 3, "task_timeout_min": 30, "base_branch": "main",
  "spec_model": "sonnet", "review_model": "sonnet",
  "test_cmd": "pytest -q", "lint_cmd": "ruff check ." }
```

**3. Task graph.** I don't ask you to approve it; I plan it and proceed. `.orchestra/2026-11-23-csv-export/board.md`:
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/csv-export.md

| id | phase | goal | implementer | depends_on | files | status |
|----|-------|------|-------------|------------|-------|--------|
| T1 | 1 | CSV serializer: job rows → CSV (columns per plan, UTF-8, formula-injection escaping of =+-@). review: opus | opencode | – | jobs/export/__init__.py, jobs/export/csv.py, tests/test_export_csv.py | todo |
| T2 | 1 | GET /jobs/export.csv: StreamingHttpResponse, reuses list filters, login required, Content-Disposition filename. review: opus | opencode | T1 | jobs/views/export.py, jobs/urls.py, tests/test_export_view.py | todo |
| T3 | 2 | "Export CSV" button on jobs list, passes current query string | opencode | T2 | jobs/templates/jobs/list.html, tests/test_jobs_list.py | todo |

Test cmds: T1 `pytest tests/test_export_csv.py` · T2 `pytest tests/test_export_view.py` · T3 `pytest tests/test_jobs_list.py`

## Log
```
- I folded the plan's separate "column constants" step into T1 because a spec for it would be as long as the code.
- Self-check: every plan requirement maps to a task, no two concurrent tasks share a file (the chain is serial anyway), and every task has a test command.

**4. Loop (Phase 1)**

T1 is the only ready task.

- **Spec subagent** (Agent, `model: sonnet`): "Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: <T1 row> + plan section `docs/plans/csv-export.md#Phase 1 — CSV serializer`. Reply with one line: the path, or `BLOCKED: <reason>`."
- **Dispatch:** on the returned path, I run the `claude-dispatch` skill for T1 here, using the dispatch script with an opencode worktree at `.worktrees/T1` on branch `orchestra/T1`.
  - Board: T1 `dispatched`.
  - Log: `HH:MM T1 dispatched (attempt 1)`.
- **Review subagent** when the run finishes (Agent, `model: opus` because T1 is marked `review: opus`): "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-csv-export`, task `T1` in repo `/workspaces/jobs`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`."
- **Outcomes:**
  - `MERGED`: T1 `merged`, plus a Log line.
  - `REJECTED`: send it back to dispatch with `--continue`, attempt + 1.
  - After 3 rejections: takeover with a `sonnet` subagent, moving up to `opus` if that is rejected too. Its prompt has the full task, the review notes and TDD/YAGNI/DRY. The result is reviewed again and marked `taken-over (sonnet)`.
- **T2:** once T1 is merged, T2 goes through the same cycle with an `opus` review. I never read diffs, source or logs in this thread.

**5. End of Phase 1**
- **Phase review subagent** (Agent, `model: opus`): "Using the `code-review` skill if installed, review `git diff <phase-1 start sha>..main` in `/workspaces/jobs` for problems the per-task reviews can't see: duplication across T1/T2, inconsistent patterns, missing integration (e.g. the filter logic copied instead of shared). Reply with at most 5 findings, one line each, or `NONE`."
- Each finding becomes a new task in Phase 2, or a fix task now if it's blocking. Log: `HH:MM Phase 1 review: <n> findings`.

**Final message (end of this session)**
> Phase 1 done: T1 and T2 are merged on `main` and tests pass. Phase review: <n findings → tasks T4…>, or "no findings". Nothing has been pushed.
>
> Phase 2 (the UI button) is next. Start a new session and say: **resume run `2026-11-23-csv-export`**.