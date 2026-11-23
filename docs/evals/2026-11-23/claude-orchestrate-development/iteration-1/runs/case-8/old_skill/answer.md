Dispatching it to opencode as you asked. The skill would normally have me make a one-constant change myself, but your instruction overrides that default.

**Assumptions:** there's an active run `.orchestra/2026-11-23-row-limit/` built from `docs/plans/2026-11-23-row-limit-plan.md`, so the plan gate passes. `board.md` lists this as `T2 | add MAX_ROWS = 500 to config.py | Claude | [] | config.py, tests/test_config.py | todo`, with no task currently dispatched that touches those files. `config.json` uses the defaults (`concurrency` 2, `base_branch` main). Tests run with `uv run pytest`.

**1. Read the code before writing the spec (claude-write-task step 1).** Read `config.py` to see how constants are defined, e.g. the existing `PAGE_SIZE = 50` at `config.py:12`. Then read `tests/test_config.py`, or confirm it doesn't exist.

**2. Check the test command.** Run `uv run pytest tests/test_config.py -q`. It should fail or find no test, and it must not fail for an unrelated reason.

**3. Update `board.md`.** Change T2's implementer from Claude to opencode and add a log line:
`- 2026-11-23 10:02 T2 implementer → opencode (user request)`

**4. Write `.orchestra/2026-11-23-row-limit/tasks/T2.task.md`:**
```markdown
---
id: T2
run: 2026-11-23-row-limit
depends_on: []
attempt: 1
---
# Add the constant MAX_ROWS = 500 to config.py

## Context
The plan needs a single row cap that later tasks import from `config`.
Follow the style of the existing module-level constants (e.g. `PAGE_SIZE = 50`, config.py:12).

## Files
- may change: config.py, tests/test_config.py
- may create: tests/test_config.py (if it does not exist)
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In tests/test_config.py add `test_max_rows`: `from config import MAX_ROWS; assert MAX_ROWS == 500`.
2. Run the test command and confirm it fails (ImportError).
3. In config.py, next to the other constants, add `MAX_ROWS = 500` (int, module level, no comment needed).
4. Run the test command and confirm it passes.

## Done when
- `uv run pytest tests/test_config.py -q` passes
- `from config import MAX_ROWS` gives the int 500

## Out of scope
- Using MAX_ROWS anywhere else (later tasks do that)
- Env-var overrides, settings classes, validation
- Reformatting or reordering config.py
```
Log: `- 10:04 T2 task written (tasks/T2.task.md)`

**5. Dispatch (claude-dispatch).** Preconditions: the task file exists, `depends_on` is empty, and no dispatched task owns `config.py`. Run in the background (Bash `run_in_background: true`):
```
bash plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh 2026-11-23-row-limit T2
```
In `board.md`, set T2 to `dispatched` and log `- 10:05 T2 dispatched (attempt 1)`. I don't poll while it runs. I wait for the exit notification and keep working on any other ready tasks.

**6. When it exits, read the last line** `DISPATCH T2 exit=<rc> result=<yes|no> log=<path>`:
- **`exit=0 result=yes`:** run claude-review-merge. It reads the diff, checks that only `config.py` and `tests/test_config.py` changed, and runs the test command itself. If the review passes, it merges to `main` and T2 becomes `merged`. Otherwise T2 goes back with review notes as attempt 2, re-dispatched with `--continue`.
- **Any other exit code:** handle it with the claude-dispatch outcome table (3 = wait for a slot, 4 = LLM unreachable, 124 = timeout, 125 = stalled).
- Either way, I log the outcome in `board.md`.

**Reply to the user:**
> T2 (`MAX_ROWS = 500` in `config.py`) is with opencode in `.worktrees/2026-11-23-row-limit/T2`. I'll review and merge it when it finishes. Normally I'd make a one-line change like this myself, but I sent it as you asked.