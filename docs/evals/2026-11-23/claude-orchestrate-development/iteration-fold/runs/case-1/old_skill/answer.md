# Dry run: orchestrating the CSV export from `docs/plans/csv-export.md`

**Assumptions** (nothing here is on disk):
- **Repo:** `/workspaces/jobs`, a Django app. `CLAUDE.md` gives `pytest -q` for tests and `ruff check .` for lint.
- **Plan:** `docs/plans/csv-export.md` exists and is committed. It has one phase with three parts:
  - a CSV serializer for jobs: fixed columns, RFC 4180 quoting, and a guard against formula injection (cells starting with `=`, `+`, `-` or `@`)
  - an authenticated `GET /jobs/export.csv` that applies the same filters as the jobs list and streams the response
  - an "Export CSV" button on the jobs list that keeps the current filters

## TodoWrite
0. Plan gate · 1. Set up run · 2. Task graph · 3. Loop · 4. Phase review · 5. Finish

## 0. Plan gate
The user named a plan that covers the work, so the gate passes and I go on to set-up.

## 1. Set up the run
```bash
cd /workspaces/jobs
git status --porcelain && git rev-parse --abbrev-ref HEAD     # must be empty / "main"
cat docs/plans/csv-export.md CLAUDE.md AGENTS.md 2>/dev/null
mkdir -p .orchestra/2026-11-23-csv-export/tasks
printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
pytest -q                                                       # must pass
```
If the working tree isn't clean, isn't on `main`, or `pytest` fails, I stop and tell the user. Otherwise I write `.orchestra/config.json` (only if it doesn't exist yet):
```json
{ "concurrency": 2, "max_rejections": 3, "task_timeout_min": 30,
  "base_branch": "main", "spec_model": "sonnet", "review_model": "sonnet",
  "test_cmd": "pytest -q", "lint_cmd": "ruff check ." }
```

## 2. Task graph: `.orchestra/2026-11-23-csv-export/board.md`
The button is a few lines of template, so a separate spec for it would be as long as the code. I fold it into T2.
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/csv-export.md

| id | phase | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|---|
| T1 | 1 | Job→CSV row serializer: columns, quoting, formula-injection guard (review: opus) | opencode | – | jobs/export/__init__.py, jobs/export/csv.py, tests/test_export_csv.py | todo |
| T2 | 1 | GET /jobs/export.csv: auth required, list filters, streaming; "Export CSV" button with current query string (review: opus) | opencode | T1 | jobs/views/export.py, jobs/urls.py, templates/jobs/list.html, tests/test_export_view.py | todo |

Test commands: T1 `pytest tests/test_export_csv.py -q`; T2 `pytest tests/test_export_view.py -q`

## Log
```
Self-check:
- Every plan requirement maps to a task: serializer → T1; endpoint, filters, auth and button → T2.
- No files are shared between the tasks.
- Each task has an exact test command.
- T2 really does need T1's code, so the two run one after the other. Concurrency 2 isn't used, which is fine.

## 3. Loop

**T1**
1. **Spec subagent** (`sonnet`): "Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: <T1 row> + plan section `docs/plans/csv-export.md#csv-serializer`. Reply with one line: the path, or `BLOCKED: <reason>`."
2. **Dispatch:** the `claude-dispatch` skill on T1 in this thread. T1 → `dispatched`. Log: `HH:MM T1 dispatched (opencode, attempt 1)`.
3. **When it finishes, review subagent** (`opus`, because T1 is marked `review: opus`): "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-csv-export`, task `T1` in repo `/workspaces/jobs`. Reply with one line: `MERGED T1 <commit> tests=<n passed>` | `REJECTED T1 attempt=<n> notes=<count>` | `TAKEOVER T1 <reason>`."
4. **Handle the verdict:**
   - `MERGED` → T1 `merged`. Log: `HH:MM T1 merged <commit> tests=N`.
   - `REJECTED` → T1 `sent-back`. Dispatch again with `--continue` and the review notes (attempt + 1).
   - After 3 rejections → takeover. A `sonnet` subagent gets the full task, the review notes and the TDD/YAGNI/DRY rules and implements T1 in a worktree. The result is reviewed again and marked `taken-over (sonnet)`.

**T2:** it becomes ready once T1 is merged. Same sequence: spec subagent (plan section `#export-endpoint` and `#export-button`), dispatch, `opus` review, update the board and log.

I never read diffs, source files or opencode logs in this thread. The board only gets one-line outcomes.

## 4. Phase review (subagent, `opus`)
"Review `git diff <phase-start-sha>..main` in `/workspaces/jobs` for the CSV export phase. Use the `code-review` skill if it's installed. Look for what per-task reviews miss: duplicated filter logic between the list view and the export view, inconsistent patterns, missing integration (route wired, button URL correct, auth on the export). Reply with up to 5 one-line findings or `CLEAN`."

Each finding becomes a fix task (T3…) that goes through the same loop. Log: `HH:MM phase 1 review: <CLEAN | n findings → T3..>`.

## 5. Finish (this is the only phase)
```bash
pytest -q && ruff check .
git worktree list                       # remove any .worktrees/* left
git branch --list 'orchestra/*'         # delete merged orchestra/* branches
```

## Final reply to the user
> CSV export is built and merged to `main`; all tests pass.
> - **T1** (CSV serializer): <opencode first try | after N send-backs | taken over (model)>, `<commit>`
> - **T2** (export endpoint + button): <outcome>, `<commit>`
> - **Phase review:** <clean | fixes merged as T3…>
> - **Tests:** `pytest -q` <n> passed; `ruff check .` clean. No worktrees or `orchestra/*` branches are left.
>
> **Left for you:** push `main` (or open a PR) and deploy. Nothing has been pushed.