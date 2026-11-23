The plan gate passes because the written plan exists. This is a resume of an existing run, so I would skip setup and graph-building. The next step is to review and merge T1 and T2, then keep the loop going through phase 3.

## 1. Resume the run (read only, no setup)
```bash
cd /workspaces/<repo>
ls .orchestra/                                    # assume: 2026-11-23-export/
cat .orchestra/config.json                        # assume defaults: concurrency 2, max_rejections 3, base_branch main
cat .orchestra/2026-11-23-export/board.md
cat docs/plans/2026-11-23-export-plan.md CLAUDE.md
git status --porcelain && git branch --show-current   # expect clean, on main
git worktree list                                 # expect .worktrees/2026-11-23-export/T1, T2
```
TodoWrite: `0 plan gate ✓` · `1 set up run ✓ (earlier session)` · `2 task graph` · `3 loop` · `4 finish`.

**What I assume board.md contains.** The earlier session graphed all three phases (if it only covered phase 1, I'd add phases 2–3 to the table now, following the same rules, without asking you):

| id | goal | impl | depends_on | files | status |
|---|---|---|---|---|---|
| T1 | `Exporter` core: rows → CSV/JSON (phase 1) | opencode | – | src/export/core.py, tests/export/test_core.py | dispatched |
| T2 | Export query: filtered records iterator (phase 1) | opencode | – | src/export/query.py, tests/export/test_query.py | dispatched |
| T3 | `GET /api/export` endpoint, streaming (phase 2) | opencode | T1,T2 | src/api/export.py, src/api/routes.py, tests/api/test_export.py | todo |
| T4 | `app export` CLI command (phase 2) | opencode | T1,T2 | src/cli/export.py, tests/cli/test_export.py | todo |
| T5 | Auth/permission check on export (phase 3) | Claude | T3 | src/api/export.py, src/auth/perms.py, tests/api/test_export_perms.py | todo |
| T6 | Docs + changelog (phase 3) | opencode | T3,T4 | docs/export.md, CHANGELOG.md | todo |

Self-check of the graph: T3 and T4 can run together because their files don't overlap. T5 runs after T3 because both touch `src/api/export.py`. Every task has an exact test command.

## 2. Confirm T1 and T2 really finished
```bash
for t in T1 T2; do
  test -f .worktrees/2026-11-23-export/$t/RESULT.md && echo "$t RESULT.md present"
  pgrep -af "dispatch.*2026-11-23-export.*$t" || echo "$t: no process"
  ls -l .orchestra/2026-11-23-export/logs/$t.*.jsonl
done
```
If a task has no RESULT.md and its process is gone, I treat it as stalled/blocked (dispatcher exit 125) and re-dispatch it with `claude-dispatch --continue`.

## 3. Review T1, then T2 (`claude-review-merge`, one at a time so each merge goes onto a green `main`)
For each task id:
```bash
W=.worktrees/2026-11-23-export/T1
cp $W/RESULT.md .orchestra/2026-11-23-export/tasks/T1.result.md
git -C $W status --porcelain && git -C $W diff        # every file must be in T1's may-change/create list
cd $W && uv run pytest tests/export/test_core.py -q   # the task's exact test command, run by me
uv run pytest -q && uv run ruff check .               # full suite + lint
```
- **Diff review:** I check correctness and edge cases (empty rows, unicode, delimiter/quote escaping), test-first (no tests that assert nothing), no unused options, and reuse of the existing serializers. RESULT.md is only a claim; my own test results decide.
- **Accept:**
  ```bash
  rm $W/RESULT.md
  git -C $W add -A
  git -C $W commit -m "feat: export core (orchestra 2026-11-23-export/T1)"
  git merge --no-ff orchestra/2026-11-23-export/T1
  uv run pytest -q
  git worktree remove $W
  git branch -d orchestra/2026-11-23-export/T1
  ```
- **Reject:** I add `## Notes from review` to `tasks/T1.task.md` (each note as `file:line — problem — fix`), bump to `attempt: 2`, and run `claude-dispatch --continue`.

Log lines (one per state change):
```
- 14:05 T1 review → merged (12 passed; full suite 148 passed)
- 14:12 T2 review → sent-back, attempt 2 (query.py:41 drops the date filter when end is None — apply it; add test)
```

## 4. Continue the loop
- T3 and T4 become ready once both T1 and T2 are merged.
  - For each: `claude-write-task`, then `claude-dispatch`, with at most 2 running at once.
  - If T2 was sent back, nothing new is ready. Only T2 runs until it comes back.
- When a run finishes, it goes through `claude-review-merge`.
- A task's third rejection means takeover with the cheapest capable model, marked `taken-over`.
- T5 (auth) I implement myself after T3 merges, then review it like any other task.
- After every change: update `board.md` (table plus one Log line).

## 5. Finish
```bash
uv run pytest -q                                  # on main
git worktree list                                 # only the main checkout
git branch --list 'orchestra/*'                   # none
```

## Final reply to you (at the end of the run)
> **2026-11-23-export done: all 6 tasks merged, 172 tests pass on `main`.**
> - opencode, first try: T1, T3, T4, T6
> - opencode, after send-back: T2 (attempt 2: `end=None` dropped the date filter)
> - Claude: T5 (auth check, planned as Claude's task)
> - Commits: 6 merge commits on `main`, `<sha>..<sha>`
> - No worktrees or `orchestra/*` branches remain.
> - **Left for you:** push `main` / open the PR, and deploy.