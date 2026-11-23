T1 and T3 are dispatched. I changed the graph first because T2 and T3 both edit `api/routes.py`, so they can't run at the same time. I moved T3's `routes.py` change into T2, which now owns that file. T3 only touches the web side and runs alongside T1. T2 needs `export_csv()`, so it waits for T1 to merge.

**Assumptions:**
- The plan is `docs/plans/2026-11-20-csv-export-plan.md`, with sections `#export-function`, `#route` and `#ui`.
- `CLAUDE.md` gives `uv run pytest -q` for tests and `ruff check .` for lint. The web tests use vitest.
- T3's `routes.py` edit adds `export_url` to the `/jobs` response.

## What I'd do, in order

**0. Plan gate.** Check that the plan file is in `docs/plans/` and covers T1–T3. I'm assuming it does, so I proceed. If there were no plan, I'd stop and run `brainstorming` and then `writing-plans` before dispatching anything.

**1. Set up the run** (`run = 2026-11-23-csv-export`):
```bash
cd /workspaces/<repo>
git status --porcelain && git rev-parse --abbrev-ref HEAD        # must be empty / main
mkdir -p .orchestra/2026-11-23-csv-export/{tasks,logs}
grep -qx '.orchestra/' .git/info/exclude || echo '.orchestra/' >> .git/info/exclude
grep -qx '.worktrees/' .git/info/exclude || echo '.worktrees/' >> .git/info/exclude
uv run pytest -q                                                   # baseline must pass
```
`.orchestra/config.json`: the contract defaults, plus `"concurrency": 2`, `"test_cmd": "uv run pytest -q && (cd web && npx vitest run)"` and `"lint_cmd": "ruff check ."`. I'd stop here if the working tree isn't clean, we're not on `main`, or the baseline tests fail.

**2. Write `.orchestra/2026-11-23-csv-export/board.md`:**
```markdown
# Run 2026-11-23-csv-export — plan: docs/plans/2026-11-20-csv-export-plan.md

| id | phase | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|---|
| T1 | 1 | export_csv(jobs) → CSV text, escapes formula-leading cells (review: opus) | opencode | – | api/export.py, tests/test_export.py | dispatched (1) |
| T2 | 1 | GET /export returns text/csv via export_csv; add export_url to /jobs response (review: opus) | opencode | T1 | api/routes.py, tests/test_routes_export.py | todo |
| T3 | 1 | "Export CSV" button in Jobs.tsx linking to /export | opencode | – | web/src/Jobs.tsx, web/src/Jobs.test.tsx | dispatched (1) |

Test cmds: T1 `uv run pytest tests/test_export.py -q` · T2 `uv run pytest tests/test_routes_export.py -q` · T3 `cd web && npx vitest run src/Jobs.test.tsx`

## Log
- 14:02 graph: T3's api/routes.py edit moved to T2 (same file as T2); T2 depends on T1 (needs export_csv)
- 14:02 T1 spec written, dispatched attempt 1
- 14:03 T3 spec written, dispatched attempt 1
```
Graph check: every requirement maps to a task; T1 and T3 share no files; each task has one exact test command. T1 and T2 are marked `review: opus` because CSV output can carry formula injection and the route parses request input.

**3. Write the specs.** Two subagents run in parallel, both on `model: sonnet`:
> Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: `T1 | 1 | export_csv(jobs) → CSV text… | opencode | – | api/export.py, tests/test_export.py` + plan section `docs/plans/2026-11-20-csv-export-plan.md#export-function`. Reply with one line: the path, or `BLOCKED: <reason>`.

The T3 prompt is the same, with the T3 row and `#ui`. It adds this line: "The /export route doesn't exist yet: mock fetch/the link target in the test; do not touch api/."

**4. Dispatch** each task once its spec path comes back. Both run in the background:
```bash
bash <claude-dispatch-dir>/scripts/dispatch.sh 2026-11-23-csv-export T1   # run_in_background
bash <claude-dispatch-dir>/scripts/dispatch.sh 2026-11-23-csv-export T3   # run_in_background
```
I don't poll. When a run ends, I handle it by its `DISPATCH … exit=` line, following `claude-dispatch`.

**5. Review each finished run** (`exit=0 result=yes`) in one subagent at a time. T1 runs on `opus`, T3 on `sonnet`:
> Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-23-csv-export`, task `T1` in repo `/workspaces/<repo>`. Reply with one line: `MERGED <id> <commit> tests=<n passed>` | `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <reason>`.

- **MERGED T1:** spec T2 and dispatch it.
- **REJECTED:** redispatch with `--continue`.
- **After 3 rejections:** take the task over.

Every change updates the table and adds one Log line.

**6. End of phase.** Once all three tasks are merged, an `opus` subagent runs `code-review` on `git diff <phase-start>..main`. Then I clean up worktrees and branches, run the full suite and report.

## Reply to the user
> Dispatched T1 (`export_csv`) and T3 (Jobs button). I made one change to the table: T2 and T3 both edited `api/routes.py`, so T3's part of that file now belongs to T2. T2 starts after T1 merges because it needs `export_csv()`. T1 and T2 get an Opus review (CSV formula injection, request input). Progress is in `.orchestra/2026-11-23-csv-export/board.md`. Nothing will be pushed; that stays your call.