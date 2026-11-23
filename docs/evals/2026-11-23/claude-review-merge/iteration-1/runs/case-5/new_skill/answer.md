T6 gets **rejected**: three clear violations of the review rules (YAGNI, DRY, TDD). Passing tests don't change that.

**Assumptions:** the run is `2026-11-23-report-export` and T6 is on attempt 1 (`max_rejections`=3, so no takeover). The task may change `src/reports/export.py` and `tests/test_export.py`. The existing helper is `parse_date` in `src/utils/dates.py:12`.

**1. Collect**
```bash
cp .worktrees/2026-11-23-report-export/T6/RESULT.md .orchestra/2026-11-23-report-export/tasks/T6.result.md
```
Read `T6.result.md` and `tasks/T6.task.md`.

**2. Mechanical checks**
```bash
bash plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh 2026-11-23-report-export T6
```
Assumed output: `scope=clean task=5 passed test_cmd=212 passed lint=ok`. This matches RESULT.md, so the tests don't block anything. The decision rests on the diff.

**3. Read the diff**
```bash
git -C .worktrees/2026-11-23-report-export/T6 diff
git -C .worktrees/2026-11-23-report-export/T6 status --porcelain   # new files
```
What I'd confirm in the diff:
- **YAGNI:** `export_rows(rows, fmt, options=None)` never reads `options`.
- **DRY:** `_parse_date()` in `export.py` duplicates `src/utils/dates.py:12 parse_date`.
- **TDD:** the new tests only snapshot current output (e.g. `assert export_rows(sample) == "<literal copied from a run>"`). None of them covers the spec's edge cases from "Done when", so none would have failed before the change.

No security surface beyond date parsing, so no `security-review`.

**4. Decide: reject.** In `.orchestra/2026-11-23-report-export/tasks/T6.task.md`, I'd change `attempt: 1` to `attempt: 2` and append:

```markdown
## Notes from review
- src/reports/export.py:18 — `options` parameter is never used (YAGNI) — remove it from the signature and from all call sites/tests.
- src/reports/export.py:41-58 — `_parse_date` duplicates `src/utils/dates.py:12 parse_date` (DRY) — delete it and import `parse_date` from `src/utils/dates`; if a format is missing there, say so under Questions in RESULT.md instead of forking it.
- tests/test_export.py:30-62 — tests only assert the current output literal, written after the code (TDD) — replace them with one test per "Done when" behaviour (e.g. empty rows, invalid date → error, the date format the spec names). Each must assert the specified result, not a copied output. Check that each fails if you revert the matching code in export.py.
- Keep `uv run pytest tests/test_export.py -q` green; touch no other files.
```

The orchestrator then sends it back with `claude-dispatch --continue`. I don't commit, merge or push.

**5. Log** (append to `.orchestra/2026-11-23-report-export/board.md`):
```
2026-11-23 T6 attempt 1 REJECTED — tests 5/5 task, 212/212 suite, lint ok; scope clean. YAGNI: unused `options` param; DRY: copy of parse_date; TDD: tests are output snapshots written after code. 3 notes → attempt 2.
```
I'd also set T6's row in the task table to `rejected (attempt 2)`.

**6. Reply**
```
REJECTED T6 attempt=2 notes=4
```