No run state is visible from here, so this is the resume sequence for an assumed state. **Assumed:** repo `/workspaces/shop-api`, one unfinished run `.orchestra/2026-11-22-csv-export/`, base `main`, default config (`concurrency` 2, `max_rejections` 3). The board when the crash happened:

| id | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|
| T1 | shared CSV writer helper | opencode | – | `app/csv_util.py`, `tests/test_csv_util.py` | merged |
| T2 | `/orders/export.csv` endpoint | opencode | T1 | `app/routes/orders.py`, `tests/test_orders_export.py` | dispatched (attempt 2) |
| T3 | `/customers/export.csv` endpoint | opencode | T1 | `app/routes/customers.py`, `tests/test_customers_export.py` | review |
| T4 | export link in admin UI | opencode | T2, T3 | `app/templates/admin.html`, `tests/test_admin.py` | todo |

The plan gate is already met: a board exists, and it was built from `docs/plans/2026-11-22-csv-export-plan.md`. I would not run the setup or task-graph steps again; the loop just picks up where it stopped.

### 1. Find the run and check the repo
```bash
cd /workspaces/shop-api
ls -t .orchestra/                         # pick the most recent run that isn't finished
cat .orchestra/config.json
cat .orchestra/2026-11-22-csv-export/board.md
git status --porcelain && git branch --show-current     # must be clean, on main
git log --oneline -15 main | grep orchestra             # which tasks actually got merged
git worktree list && git branch --list 'orchestra/*'
```
If two runs both look unfinished, I'd ask which one to resume.

**Compare the board with git.** The crash could have happened between a merge and the board update. If `main` has a `(orchestra 2026-11-22-csv-export/T3)` commit, T3 is merged even though the board says `review`. In that case I'd finish the cleanup (`git worktree remove`, `git branch -d`) and set the board to `merged`.

If `main` has uncommitted changes, a merge stopped partway. I'd stop there and look before touching anything.

TodoWrite: resume run · settle T2 · review T3 · loop (T4) · finish.

### 2. Settle the `dispatched` task (T2)
```bash
pgrep -af 'dispatch.sh 2026-11-22-csv-export T2'; pgrep -af opencode
ls -l --time-style=+%T .orchestra/2026-11-22-csv-export/logs/T2.2.jsonl; sleep 30; ls -l ...T2.2.jsonl   # still growing?
tail -20 .orchestra/2026-11-22-csv-export/logs/T2.2.jsonl
test -f .worktrees/2026-11-22-csv-export/T2/RESULT.md && echo result=yes
```
- **Still running** (process alive, log growing): don't touch the worktree. The new session wasn't the one that started the run, so it won't get the exit notice. I'd check the process and `RESULT.md` while doing other work, without dumping the log into context.
- **Finished** (`RESULT.md` present): run `claude-review-merge` on T2.
- **Died with the session** (no process, no `RESULT.md`): a crash isn't a rejection, so `attempt` stays at 2. I'd restart it in the background on the same worktree and session with `bash <claude-dispatch>/scripts/dispatch.sh 2026-11-22-csv-export T2 --continue`.

### 3. Review the `review` task (T3)
`claude-review-merge` on T3, run from the start:
- copy `RESULT.md` into `tasks/T3.result.md`
- scope check with `git status` and `git diff` in the worktree
- run `uv run pytest tests/test_customers_export.py -q` myself, then the full suite
- read the diff against TDD, YAGNI and DRY

Then accept (commit, merge to `main`, rerun the tests, remove the worktree and branch), send it back with file:line notes (`dispatch.sh … T3 --continue`, attempt + 1), or take it over on the third rejection.

### 4. Continue the loop
- T4 is ready once T2 and T3 are both merged.
- Then `claude-write-task` for T4 and dispatch it in the background (`dispatch.sh 2026-11-22-csv-export T4`).
- When it exits, `claude-review-merge`.
- Never more than 2 runs at once.

### 5. Log every change in `board.md`
```
- 2026-11-23 10:04 resumed after session crash; main clean; T1 merged (a1b2c3d)
- 2026-11-23 10:05 T2 attempt 2: run dead, no RESULT.md → redispatched --continue (same attempt)
- 2026-11-23 10:12 T3 accepted: 6 passed task / 48 passed full; merged d4e5f6a
```

### 6. Finish
- Full test suite passes on `main`.
- `git worktree list` and `git branch --list 'orchestra/*'` both show nothing left.

### Reply to the user
> Resumed run `2026-11-22-csv-export`. Before the crash: T1 was merged, T2 was in its second opencode attempt, and T3 was waiting for review.
>
> - **T2:** the opencode run died with the session and left no `RESULT.md`, so I restarted it in the same worktree and session (still attempt 2). It then passed review and is merged.
> - **T3:** reviewed and merged on the first try.
> - **T4:** dispatched once T2 and T3 were merged; it passed review on the first try.
>
> Outcomes: first try T1, T3, T4; after a send-back T2; taken over: none. `main` has 4 new commits, and the full suite passes with 52 tests. No worktrees or `orchestra/*` branches are left.
>
> Left for you: push `main` (I didn't push).