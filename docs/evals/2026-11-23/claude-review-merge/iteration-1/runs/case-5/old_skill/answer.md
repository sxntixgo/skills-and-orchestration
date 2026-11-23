**T6 is rejected and goes back to opencode as attempt 2.** All three problems break the skill's rules: the unused `options` parameter breaks YAGNI, the second `parse_date` breaks DRY, and tests that only assert the current output break TDD. Passing tests don't change that. I'd still rerun everything myself first, because RESULT.md is a claim, not evidence.

**Assumptions** (nothing is on disk):
- Run `2026-11-21-csv-export`, `base_branch: main`, `max_rejections: 3`.
- T6 is "filter export rows by date range" and this is attempt 1.
- T6 may change `src/export/filters.py` and `tests/test_filters.py`.
- The existing helper is `src/utils/dates.py:12 parse_date`.
- The test command is `uv run pytest tests/test_filters.py -q`.

### 1. Collect
```bash
cd /workspaces/<repo>
cp .worktrees/2026-11-21-csv-export/T6/RESULT.md .orchestra/2026-11-21-csv-export/tasks/T6.result.md
```
I'd then read `T6.result.md` and `T6.task.md`.

### 2. Scope check
```bash
W=.worktrees/2026-11-21-csv-export/T6
git -C $W status --porcelain
git -C $W diff
git -C $W ls-files --others --exclude-standard
```
I assume only the two allowed files changed, plus RESULT.md and maybe `__pycache__/`. Those two don't count as scope violations.

### 3. Run the checks myself
```bash
cd $W
uv run pytest tests/test_filters.py -q   # assume: 7 passed, same as RESULT.md
uv run pytest -q                         # assume: 142 passed
uv run ruff check . && uv run mypy src   # if the repo has them
```

**TDD check.** I'd run T6's new tests against main's code to see whether they fail without T6's change:
```bash
git worktree add /tmp/t6-base main
cp $W/tests/test_filters.py /tmp/t6-base/tests/
(cd /tmp/t6-base && uv run pytest tests/test_filters.py -q)
git worktree remove --force /tmp/t6-base
```
- If they fail only with an ImportError, or they pass, they don't test the behaviour.
- Either way they only assert whatever the code currently returns, not the "Done when" behaviour (an empty range, an inclusive end date, a bad date string).

### 4. Read the diff
This confirms the three problems you saw, with the line numbers I use in the notes below. There's no security angle: the change takes no auth, file or network input beyond the date strings it already parses.

### 5. Decide: reject
This is attempt 1 and the problems are within the implementer's ability, so no takeover. I'd append this to `.orchestra/2026-11-21-csv-export/tasks/T6.task.md` and set `attempt: 2` in its frontmatter:

```markdown
## Notes from review
- src/export/filters.py:18 — `filter_by_date(rows, start, end, options=None)`: `options` is never read (YAGNI) — remove the parameter and any call sites passing it.
- src/export/filters.py:41-58 — `_parse_date` duplicates `src/utils/dates.py:12 parse_date` (DRY) — delete it and `from utils.dates import parse_date`; do not edit utils/dates.py.
- tests/test_filters.py:20-64 — tests assert whatever the code currently returns, not the behaviour in "Done when"; they don't fail on main for the right reason (TDD) — rewrite them from the spec: one test per "Done when" bullet (rows inside the range kept, `end` inclusive, `start > end` → empty list, invalid date string → ValueError), with expected values written from the spec, not copied from output. Run them before touching filters.py and confirm they fail, then make them pass.
- Do not weaken or skip any test to get green; `uv run pytest tests/test_filters.py -q` must pass.
```

Then I'd clean up and send it back:
```bash
rm -rf $W/RESULT.md $W/**/__pycache__
claude-dispatch --continue 2026-11-21-csv-export T6
```

### 6. Log in `board.md`
I'd set T6's status in the task table to `rejected (attempt 1/3) → re-dispatched` and append to the log:
```
2026-11-23 T6 attempt 1 REJECTED — tests 7/7 task, 142/142 suite (rerun by Claude), scope clean.
  Reasons: unused `options` param (YAGNI); _parse_date duplicates utils.dates.parse_date (DRY);
  tests written after the code, assert current output not spec (TDD). Notes in T6.task.md; sent back with --continue (attempt 2).
```

### Reply to you
> T6 was rejected and sent back as attempt 2. Its tests pass, but the diff breaks all three principles:
> - **YAGNI:** the `options` parameter is never used.
> - **DRY:** it adds a second `parse_date` instead of importing `utils.dates.parse_date`.
> - **TDD:** the tests only assert the current output, and they don't fail on main for the right reason.
>
> The notes in `T6.task.md` give file:line and the exact fix for each. They also require tests written from the "Done when" list that fail before the code changes. It's logged in `board.md` (1 of 3 rejections). Nothing was merged or pushed.