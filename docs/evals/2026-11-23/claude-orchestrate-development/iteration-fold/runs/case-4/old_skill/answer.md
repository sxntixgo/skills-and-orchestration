Assumption: I find exactly one run, `.orchestra/2026-11-21-csv-export/`, working through Phase 2 of `docs/plans/2026-11-20-csv-export-plan.md`. If there were several unfinished runs, I'd ask which one to resume instead of guessing.

## 1. Find the run and load the state (only `board.md` and the plan)

```bash
cd /workspaces/<repo>
ls -t .orchestra/                      # → config.json, 2026-11-21-csv-export/
cat .orchestra/config.json             # concurrency 2, max_rejections 3, base_branch main, spec/review_model sonnet
cat .orchestra/2026-11-21-csv-export/board.md
cat docs/plans/2026-11-20-csv-export-plan.md
```

Assumed `board.md` (Phase 1 done, T1–T4 merged):

| id | phase | goal | implementer | depends_on | files | status |
|---|---|---|---|---|---|---|
| T5 | 2 | CSV serializer + tests | opencode | T2 | src/export/csv.py, tests/test_csv.py | merged |
| T6 | 2 | `/export` endpoint (review: opus) | opencode | T5 | src/api/export.py, tests/test_export_api.py | dispatched |
| T7 | 2 | Export button in UI | opencode | T5 | web/ExportButton.tsx, web/ExportButton.test.tsx | review |
| T8 | 2 | Streaming for large exports | opencode | T6 | src/api/export.py, src/export/stream.py | todo |

TodoWrite: (1) check repo state after crash, (2) check T6 run, (3) re-review T7, (4) finish the Phase 2 loop, (5) Phase 2 review and handoff.

## 2. Check that the crash didn't leave the repo half-merged

```bash
git rev-parse --abbrev-ref HEAD        # expect main
git status --porcelain                 # expect empty
test -f .git/MERGE_HEAD && echo MERGE_IN_PROGRESS
git worktree list                      # expect .worktrees/T6, .worktrees/T7
```

If a merge is in progress or the tree is dirty, I stop and report it. I won't run `git merge --abort` or `git reset` without your OK. This assumes everything is clean.

## 3. Check the `dispatched` task (T6) without reading its log

```bash
pgrep -fl "opencode.*T6"                                   # process alive?
stat -f %z .orchestra/2026-11-21-csv-export/logs/T6.log; sleep 60; stat -f %z .orchestra/2026-11-21-csv-export/logs/T6.log   # log growing?
test -f .worktrees/T6/RESULT.md && echo DONE
```

- **Finished** (RESULT.md exists): it goes to review (step 5).
- **Still running:** I leave it alone and wait.
- **Dead** (no process, log not growing, no RESULT.md): I dispatch it again with `claude-dispatch` using the same attempt number, since a crash isn't a rejection.

Assume it finished.

## 4. Check the task that was `review` at the crash (T7)

The crash may have hit after the merge but before `board.md` was updated.

```bash
git log main --oneline --grep "T7" -n 3
git branch --merged main | grep orchestra/T7
```

- **Already merged:** I mark T7 merged and log the commit.
- **Not merged:** I run the review again (step 5).

Assume it wasn't merged.

## 5. Reviews, one subagent at a time

**T7**, Agent with `model: sonnet`:
> "Use the `claude-review-merge` skill (orchestration plugin) for run `2026-11-21-csv-export`, task `T7` in repo `/workspaces/<repo>`. Reply with one line: `MERGED T7 <commit> tests=<n passed>` | `REJECTED T7 attempt=<n> notes=<count>` | `TAKEOVER T7 <reason>`. If the skill isn't loaded, read `plugins/orchestration/skills/claude-review-merge/SKILL.md`."

**T6**, Agent with `model: opus` because the task is marked `review: opus`. Same prompt with `T6`.

After each reply I update `board.md` and append one Log line, for example:

```
- 2026-11-23 10:42 resumed after crash; T6 finished (RESULT.md), T7 not merged → re-review
- 2026-11-23 10:51 T7 MERGED a1b2c3d tests=48
- 2026-11-23 11:03 T6 MERGED d4e5f6a tests=55
```

## 6. Continue the loop

- **Next task:** T8 becomes ready once T6 merges.
- **Spec:** an Agent with `model: sonnet` writes it. Prompt:
  > "Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-21-csv-export/tasks/T8.task.md` for: `<T8 row>` + plan section `docs/plans/2026-11-20-csv-export-plan.md#phase-2-streaming`. Reply with one line: the path, or `BLOCKED: <reason>`."
- **Dispatch:** `claude-dispatch` here, then review as in step 5.
- **Rejections:** a rejected task goes back to `--continue` with the review notes. After 3 rejections it's taken over on the model ladder.
- **Board:** I update `board.md` after every state change.

## 7. End of Phase 2

An Agent with `model: opus` reviews the whole phase. Prompt:
> "Review `git diff <phase-2 start commit>..main` in `/workspaces/<repo>` (use the `code-review` skill if installed) for duplication across tasks, inconsistent patterns and missing integration. Reply with at most 5 one-line findings, or `CLEAN`."

Any findings become Phase 3 tasks in `board.md`. Then I log it and stop the session.

## Final message to you

> I resumed run `2026-11-21-csv-export` after the crash. The repo was clean with no merge in progress. T6 had finished before the crash and T7 hadn't been merged yet, so both went through review again.
>
> - **T7:** merged (a1b2c3d)
> - **T6:** merged (d4e5f6a)
> - **T8:** merged after one send-back
>
> The Phase 2 review found 1 issue, and it's queued as Phase 3 task T9. Phase 2 is done. Start a new session and say: resume run `2026-11-21-csv-export`.