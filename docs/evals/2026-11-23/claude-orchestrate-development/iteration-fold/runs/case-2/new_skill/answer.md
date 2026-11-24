T1 and T3 start first. T3 had to change because it and T2 both edited `api/routes.py`, and two tasks running at the same time can't share a file. I moved T3's `api/routes.py` edit into T2, so T3 only touches `web/src/Jobs.tsx`. T2 starts when T1 is merged, because the route calls `export_csv()`.

## What I'd do, in order

**0. Plan gate.** Run `ls docs/plans/`. Assumption: there's no export plan there and you didn't give a path. I go ahead without one because your table already fixes the files and functions for each task. I also assume the CSV columns are the existing Job fields and that `/export` uses the same auth as the other job routes. If either is wrong, that's a design question for you, not something to settle in the board.

**1. Set up the run** (run = `2026-11-23-csv-export`):
```bash
cd /workspaces/<repo>
git status --porcelain && git rev-parse --abbrev-ref HEAD   # must be clean, on main
mkdir -p .orchestra/2026-11-23-csv-export/tasks
printf '.orchestra/\n.worktrees/\n' >> .git/info/exclude
cat CLAUDE.md AGENTS.md 2>/dev/null
```
`.orchestra/config.json`, with `test_cmd` and `lint_cmd` assumed from `CLAUDE.md`:
```json
{"concurrency": 2, "max_rejections": 3, "task_timeout_min": 30, "base_branch": "main",
 "spec_model": "sonnet", "review_model": "sonnet",
 "test_cmd": "pytest -q && (cd web && npm test -- --run)", "lint_cmd": "ruff check api && (cd web && npm run lint)"}
```
Then I run `test_cmd` once. If the tree isn't clean or the tests fail, I stop here.

**2. Write `.orchestra/2026-11-23-csv-export/board.md`:**
```markdown
| id | phase | goal | implementer | depends_on | files | status |
|----|-------|------|-------------|------------|-------|--------|
| T1 | 1 | export_csv(jobs) -> CSV text; escape cells starting with = + - @ (review: opus) | opencode | – | api/export.py, tests/test_export.py | todo |
| T2 | 1 | GET /export returns text/csv via export_csv, same auth as job routes; includes T3's routes.py change (review: opus) | opencode | T1 | api/routes.py, tests/test_routes_export.py | todo |
| T3 | 1 | "Export CSV" button in Jobs.tsx downloads /export | opencode | – | web/src/Jobs.tsx, web/src/Jobs.test.tsx | todo |

## Log
- 2026-11-23 HH:MM graph: T3's routes.py edit moved into T2 (shared file); T2 depends on T1.
```
Checks: every item you listed is in a task, the tasks running at the same time (T1, T3) share no files, and each task has its own test command (`pytest tests/test_export.py`, `pytest tests/test_routes_export.py`, `cd web && npm test -- --run Jobs`).

**3. Dispatch wave 1 (T1 and T3, which uses concurrency 2).** I spawn two spec subagents in parallel (Agent, `model: sonnet`). Prompt for T1:
> Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T1.task.md` for: `| T1 | 1 | export_csv(jobs) -> CSV text; escape cells starting with = + - @ (review: opus) | opencode | – | api/export.py, tests/test_export.py | todo |` + plan section: user's approved task table (no plan file). Reply with one line: the path, or `BLOCKED: <reason>`.

The T3 prompt is the same with T3's row. When each path comes back, I run `claude-dispatch` for T1 and T3, set both to `dispatched`, and add a Log line.

**4. Loop.** When a run finishes, one review subagent runs at a time, with the prompt from the skill and a one-line verdict:
- T1 uses `model: opus` (it's marked review: opus).
- T3 uses `model: sonnet`.
- Rejected: dispatch again with `--continue` and the notes (attempt + 1).
- After 3 rejections: takeover on the model ladder.

When T1 is `MERGED`, I spec and dispatch T2, then review it on `opus`. I update `board.md` and add a Log line after every state change.

**5. End of phase.** One `opus` subagent reviews `git diff <start>..main` for integration gaps, for example the button's URL and query parameters not matching the route. Then I clean up the worktrees and `orchestra/*` branches and report.

## Reply to you
> Dispatching T1 (`export_csv`) and T3 (Jobs.tsx button) now. I moved T3's `api/routes.py` edit into T2 because both tasks changed that file. T2 (the `/export` route) starts once T1 is merged. T1 and T2 get an Opus review for CSV formula injection and endpoint auth. I'll report when all three are merged; pushing is left to you.