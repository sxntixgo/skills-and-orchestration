T6 is rejected and goes back to opencode for attempt 2. The tests pass, but the diff clearly breaks two of the three rules: YAGNI (the unused `options` param) and DRY (a second `parse_date`). The tests also look written to fit the code. It's the first rejection of 3, so no takeover yet.

**Assumptions** (nothing is on disk):
- Run: `2026-11-21-csv-export`. T6 is on attempt 1.
- Allowed files: `src/report/export.py` and `tests/test_export.py`.
- The existing helper is `parse_date` at `src/report/dates.py:12`.
- Test command: `uv run pytest tests/test_export.py -q`. Full suite: `uv run pytest -q`. Lint: `uv run ruff check`.
- `base_branch` is `main`.

## What I'd do

**1. Collect the result**
```bash
cd /workspaces/<repo>
cp .worktrees/2026-11-21-csv-export/T6/RESULT.md .orchestra/2026-11-21-csv-export/tasks/T6.result.md
```
Then read `T6.result.md` and `T6.task.md`.

**2. Scope check**
```bash
git -C .worktrees/2026-11-21-csv-export/T6 status --porcelain
git -C .worktrees/2026-11-21-csv-export/T6 diff
```
Assume only the two allowed files changed. I'd delete `__pycache__/` if present.

**3. Rerun the tests myself**
```bash
cd .worktrees/2026-11-21-csv-export/T6
uv run pytest tests/test_export.py -q    # assume 7 passed
uv run pytest -q && uv run ruff check     # assume 142 passed, ruff clean
```

**4. Check whether the new tests would fail without the change**
I'd run the new test file against the code on `main`:
```bash
git stash push -- src/report/export.py
uv run pytest tests/test_export.py -q    # assume most still pass, or fail only on the missing function
git stash pop
```
Then I'd read the diff:
- `grep -n "options" src/report/export.py` finds the parameter but no use of it.
- `export.py` has a new `_parse_date` that is nearly a copy of `src/report/dates.py:12`.
- The tests compare against hard-coded output captured from the code. None of them covers the edge cases listed in "Done when".

**5. Reject.** I'd append this to `.orchestra/2026-11-21-csv-export/tasks/T6.task.md` and set `attempt: 2` in its frontmatter:
```markdown
## Notes from review
- src/report/export.py:23 — `options` parameter is never used (YAGNI) — remove it from the signature and from every caller/test that passes it.
- src/report/export.py:41-58 — `_parse_date` duplicates `parse_date` in src/report/dates.py:12 (DRY) — delete it, `from report.dates import parse_date`, and use that. If the existing helper truly lacks a needed case, say so in RESULT.md Questions instead of copying it.
- tests/test_export.py:10-48 — tests only snapshot the current output and would not catch the behaviour from "Done when" (TDD) — rewrite them from the spec: one test per "Done when" bullet and per edge case in Steps (e.g. empty input, invalid date → error, timezone handling as specified). Write each test first and confirm it fails before the code change; report that in RESULT.md.
- Keep everything else as is; do not widen scope.
```
Then send it back:
```bash
claude-dispatch --continue 2026-11-21-csv-export T6
```

**6. Log** in `.orchestra/2026-11-21-csv-export/board.md`:
```
| T6 | rejected (1/3) | attempt 2 dispatched |
- 2026-11-23 T6 attempt 1 REJECTED — tests 7/7 task, 142/142 suite, ruff clean; YAGNI: unused `options` param; DRY: copy of parse_date (dates.py:12); TDD: tests snapshot current output, don't encode spec/edge cases. Sent back with 3 notes.
```

## Reply to you
I rejected T6 on attempt 1 and sent it back to opencode as attempt 2. I reran the tests myself: 7/7 for the task and 142/142 for the full suite, with ruff clean. Passing tests don't outweigh the three problems:
- **YAGNI:** remove the unused `options` param.
- **DRY:** use the existing `parse_date` at `src/report/dates.py:12` instead of the copy.
- **TDD:** rewrite the tests from the spec's "Done when" and edge cases, and confirm each fails before the code change.

Each note in the task file has the file:line, the problem and the fix. The board shows rejection 1 of 3; I take the task over only on the 3rd rejection.