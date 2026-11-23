I won't dispatch it as its own task. It still goes to opencode, folded into the task that uses `MAX_ROWS`. The skill says a task whose spec would be as long as its code, like a single constant, gets merged into a neighbouring task instead of being dispatched alone. The spec for a one-line change would cost more than the change itself.

**Assumptions** (I can't see the state): a run `2026-11-23-csv-export` already exists with `board.md`. The constant is task **T2** (`add MAX_ROWS = 500 to config.py`, files `config.py`, status `todo`). **T4**, "cap CSV export at MAX_ROWS rows", depends on T2, owns `export.py` and `tests/test_export.py`, and is still `todo`. Nothing currently dispatched lists `config.py`.

**Steps, in order:**

1. Read `.orchestra/2026-11-23-csv-export/board.md` and the plan. I don't open any source files in this thread.
2. Edit `board.md`:
   - T2 row: status → `dropped`, goal cell gets "(merged into T4: one-line constant, not worth a spec)".
   - T4 row: goal → "add `MAX_ROWS = 500` to config.py and cap CSV export at MAX_ROWS rows". Files → `config.py, export.py, tests/test_export.py`. Remove T2 from `depends_on`.
   - Self-check: no other task that could run alongside T4 lists `config.py`. If one did, I'd add a dependency so they run one after the other.
   - Log: `2026-11-23 HH:MM  T2 dropped → merged into T4 (constant too small to dispatch alone)`.
3. If T4's other dependencies are merged and a slot is free (`concurrency` 2), spawn the spec subagent:
   - **model:** `sonnet` (`spec_model`)
   - **prompt:** "Use the `claude-write-task` skill (orchestration plugin) to write `.orchestra/2026-11-23-csv-export/tasks/T4.task.md` for: `T4 | 1 | add MAX_ROWS = 500 to config.py and cap CSV export at MAX_ROWS rows | opencode | [] | config.py, export.py, tests/test_export.py | todo` + plan section `docs/plans/2026-11-23-csv-export-plan.md#export-limits`. Reply with one line: the path, or `BLOCKED: <reason>`. If the skill isn't loaded, read `plugins/orchestration/skills/claude-write-task/SKILL.md`."
4. Use `claude-dispatch` on `T4.task.md` (attempt 1, worktree `.worktrees/2026-11-23-csv-export/T4`). Set T4 → `dispatched` and log `T4 dispatched (attempt 1)`.
5. When the run finishes, spawn the review subagent (`sonnet`, using the standard `claude-review-merge` prompt that replies with one verdict line). Update the board and log from that line.

**Other cases:**
- **No task uses `MAX_ROWS`:** I'd drop T2 under YAGNI and log it.
- **The task using it is already dispatched or merged:** I'd fold the constant into the next `todo` task that owns `config.py`. If there isn't one, I'd have a cheap `haiku` subagent make it a takeover-style Claude task, then review it as usual.

**Reply to you:**
> I didn't dispatch T2 by itself: a spec for a one-line constant costs more than the change. I merged it into T4, so opencode adds `MAX_ROWS = 500` to `config.py` along with the export cap and its tests. T2 is marked dropped (merged into T4) on the board. T4's spec is written and it's dispatched as attempt 1. I'll review and merge it when the run finishes.