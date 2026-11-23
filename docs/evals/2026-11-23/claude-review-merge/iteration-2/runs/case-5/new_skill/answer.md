Assumptions: run `2026-11-23-dates`, task `T6` (attempt 1 → this is rejection 1 of `max_rejections`=3), implementer worktree `W=.worktrees/2026-11-23-dates/T6`. T6 changes `src/report/export.py` and tests in `tests/test_export.py`. `parse_date` already exists in `src/utils/dates.py`. I haven't seen the code, so the line numbers below are made up.

1. **Collect**
   ```
   cp .worktrees/2026-11-23-dates/T6/RESULT.md .orchestra/2026-11-23-dates/tasks/T6.result.md
   ```
   Read `T6.result.md` and `.orchestra/2026-11-23-dates/tasks/T6.md`.

2. **Check** (tests run by the script, not by hand):
   ```
   bash plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh 2026-11-23-dates T6
   ```
   Assumed last line: `CHECK T6 scope=ok result=yes task=pass suite=pass(212) lint=pass`

3. **Read the diff**
   ```
   git -C .worktrees/2026-11-23-dates/T6 diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'
   git -C .worktrees/2026-11-23-dates/T6 ls-files -o --exclude-standard
   ```
   This confirms the three problems you reported:
   - **YAGNI:** an `options` parameter that nothing uses.
   - **DRY:** a second copy of `parse_date`.
   - **TDD:** the tests only assert the current output, so they wouldn't catch the behaviour being broken.

   Passing tests don't outweigh these. They are design and quality problems, not small style issues, so I reject. It's only the first rejection and the problems are within the implementer's reach, so no takeover.

4. **Reject.** Append to `.orchestra/2026-11-23-dates/tasks/T6.md` and change `attempt: 1` to `attempt: 2` in its header:
   ```markdown
   ## Notes from review
   - src/report/export.py:14 — `options` parameter is never read (YAGNI) — remove it from the signature and all call sites/tests.
   - src/report/export.py:31-48 — `_parse_date` duplicates `parse_date` in src/utils/dates.py (DRY) — delete the copy and import `from utils.dates import parse_date`.
   - tests/test_export.py:22-40 — tests only snapshot current output, not the behaviour in "Done when" (TDD) — write tests from the spec's cases (incl. its edge cases: empty range, invalid date string) that fail on the pre-change code; assert specific values/errors, not the whole dump.
   ```
   The orchestrator then sends T6 back with `claude-dispatch --continue`. I don't touch the code myself.

5. **Log** in `.orchestra/2026-11-23-dates/board.md`:
   ```
   | T6 | REJECTED attempt=2 | task=pass suite=212/212 lint=pass | unused `options` param, duplicate parse_date, tests fitted to output (3 notes) |
   ```

6. **Reply:**

`REJECTED T6 attempt=2 notes=3`