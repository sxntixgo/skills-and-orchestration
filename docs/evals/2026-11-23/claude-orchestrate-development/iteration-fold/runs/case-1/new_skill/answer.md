I'm going ahead without asking you to approve the task graph. The plan is at `docs/plans/csv-export.md`, so the plan gate passes. This session runs Phase 1 and then stops at the phase boundary.

**Assumptions** (I can't see these files):
- **Repo:** `/workspaces/jobs`, a Django app.
- **`CLAUDE.md`:** test command `pytest -q`, lint command `ruff check .`.
- **The plan, Phase 1 (core export):** a CSV row serializer (fixed columns, escaping, a guard against spreadsheet formula injection), and `GET /jobs/export.csv` that uses the same filters as the jobs list, is limited to owners, and has an "Export CSV" button on the list.
- **The plan, Phase 2 (large exports):** a streaming response above 10k rows, and an audit-log entry for each export.

## What I'd do, in order

**TodoWrite:** one item for each step: 0 plan gate, 1 set up the run, 2 task graph, 3 loop, 4 phase review, 5 finish.

**Step 1: set up the run** (run `2026-11-23-csv-export`)
```bash
cd /workspaces/jobs
git status --porcelain && git rev-parse --abbrev-ref HEAD   # must be clean and on main
mkdir -p .orchestra/2026-11-23-csv-export/tasks
printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
pytest -q                                                  # baseline must pass, else ⛔ STOP and report
git rev-parse HEAD > .orchestra/2026-11-23-csv-export/phase1.start
```
I'd read only `docs/plans/csv-export.md` and `CLAUDE.md`/`AGENTS.md`, then write `.orchestra/config.json` because it doesn't exist yet:
```json
{ "concurrency": 2, "max_rejections": 3, "task_timeout_min": 30, "base_branch": "main",
  "spec_model": "sonnet", "review_model": "sonnet",
  "test_cmd": "pytest -q", "lint_cmd": "ruff check ." }
```

**Step 2: write `.orchestra/2026-11-23-csv-export/board.md`**
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/csv-export.md

| id | phase | goal | implementer | depends_on | files | status |
|----|-------|------|-------------|------------|-------|--------|
| T1 | 1 | CSV row serializer: columns, escaping, formula-injection guard (review: opus) | opencode | – | jobs/export/csv_writer.py, jobs/export/__init__.py, tests/test_csv_writer.py | todo |
| T2 | 1 | Move list filters into reusable `filter_jobs(qs, params)`; list view uses it | opencode | – | jobs/filters.py, jobs/views/list.py, tests/test_filters.py | todo |
| T3 | 1 | GET /jobs/export.csv: owner-only, applies filter_jobs + serializer; "Export CSV" button on list (review: opus) | opencode | T1, T2 | jobs/views/export.py, jobs/urls.py, templates/jobs/list.html, tests/test_export_view.py | todo |
| T4 | 2 | Stream the export (StreamingHttpResponse) above 10k rows | opencode | T3 | jobs/views/export.py, tests/test_export_streaming.py | todo |
| T5 | 2 | ExportAudit model + migration; export view writes one entry per export (review: opus) | opencode | T4 | jobs/models/audit.py, jobs/migrations/00xx_exportaudit.py, jobs/views/export.py, tests/test_export_audit.py | todo |

Test commands: T1 `pytest -q tests/test_csv_writer.py` · T2 `pytest -q tests/test_filters.py tests/test_views_list.py` · T3 `pytest -q tests/test_export_view.py` · T4 `pytest -q tests/test_export_streaming.py` · T5 `pytest -q tests/test_export_audit.py`

## Log
```
Graph decisions:
- **T2 is separate:** the shared filter code comes first so the export reuses it (DRY).
- **Button merged into T3:** on its own, the button's spec would be about as long as its code.
- **T4 and T5 run one after the other:** both change `jobs/views/export.py`.

Self-check: every plan requirement maps to a task, T1 and T2 share no files, and every task has an exact test command.

**Step 3: loop (Phase 1)**
1. **T1 and T2 are ready and don't overlap**, so I'd spawn two spec subagents (model `sonnet`), one per task. The prompt for T1:
   > Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: `<T1 row>` + plan section `docs/plans/csv-export.md#Phase 1 — Core export`. Reply with one line: the path, or `BLOCKED: <reason>`.

   T2 gets the same prompt with its own row.
2. **Dispatch:** run `claude-dispatch` for T1 and T2 here (opencode, one worktree each under `.worktrees/`). Set both to `dispatched` and add one Log line each.
3. **Review each finished run**, one review subagent at a time:
   - T1 uses `opus` because the task is marked `review: opus`. T2 uses `sonnet`.
   - Prompt: "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-csv-export`, task `T1` in repo `/workspaces/jobs`. Reply with one line: `MERGED T1 <commit> tests=<n>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`."
   - `REJECTED` sends the task back to dispatch with `--continue` and notes.
   - After 3 rejections the task goes to a takeover subagent: `sonnet` first, `opus` after another rejection. That task then gets reviewed again.
4. **When T1 and T2 are merged**, T3 follows the same path (spec, dispatch, then an `opus` review).
5. **After every state change** I'd update the table and add a Log line, e.g. `14:20 T1 MERGED a1b2c3d tests=12`.

I never read diffs, source files or opencode logs in this thread.

**Step 4: Phase 1 review.** One subagent on `opus`:
> Review `git diff $(cat .orchestra/2026-11-23-csv-export/phase1.start)..main` in `/workspaces/jobs` (use the `code-review` skill if installed) for what per-task reviews miss: duplication across T1–T3, inconsistent patterns, missing integration (button → URL → filters → serializer). Reply with at most 5 one-line findings, or `NONE`.

Any findings become fix tasks added to Phase 2 in `board.md`. Then I'd log `phase 1 review: <n> findings` and stop the session. Phase 2 (T4, T5) and the finish step (full suite on `main`, removing worktrees and `orchestra/*` branches, the final report) happen in the next session.

## Final message
Phase 1 of the CSV export is done. T1 (serializer), T2 (shared filters) and T3 (the export endpoint and button) are merged to `main`, and `pytest -q` passes. The phase review's findings were added to Phase 2 in `.orchestra/2026-11-23-csv-export/board.md`. Phase 2 (streaming and the audit log) is still to do.

Start a new session and say: **resume run `2026-11-23-csv-export`**.

Nothing has been pushed; pushing and opening a PR are up to you.