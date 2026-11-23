I'd rewrite `T2.task.md` for attempt 2 by adding review notes for the two rejection reasons and keeping the rest of the spec. Nothing below has been run; it's what I would do in the session.

**Assumptions** (nothing exists on disk):
- **Run and repo:** the run is `2026-11-21-csv-export` in `/workspaces/app`.
- **What T2 builds:** `GET /api/exports/{id}.csv` in `api/routes/exports.py`, with tests in `tests/test_exports.py`.
- **Why the empty case gives 500:** the attempt-1 code builds the header from `rows[0].keys()`, so an empty list raises `IndexError`.
- **Why App.tsx changed:** the diff added a download button there. The task doesn't need that; it belongs to T3 (frontend).

## 1. Read the current state
```bash
cd /workspaces/app
cat .orchestra/2026-11-21-csv-export/tasks/T2.task.md
cat .orchestra/2026-11-21-csv-export/tasks/T2.result.md
git -C .worktrees/2026-11-21-csv-export/T2 diff main -- web/src/App.tsx api/routes/exports.py
grep -n "rows\[0\]\|def export_csv" .worktrees/2026-11-21-csv-export/T2/api/routes/exports.py
```
I'd use this to get the exact `file:line` for each problem. I assume `api/routes/exports.py:42` (`rows[0].keys()`) and `web/src/App.tsx:18-31` (the added button).

I'd also find the header source to point to: assume `api/models/export.py:12` `EXPORT_COLUMNS`.

## 2. Check that the test command fails for the right reason
```bash
uv run pytest tests/test_exports.py -q
```
On `main` this should fail or have no empty-list test yet, and it must not fail for unrelated reasons.

## 3. Edit `.orchestra/2026-11-21-csv-export/tasks/T2.task.md`
- **Frontmatter:** `attempt: 1` → `attempt: 2`. Everything else stays.
- **Files:** add an explicit line:
  `- must NOT touch: web/ (including web/src/App.tsx), everything else (and never .orchestra/, .git/)`
- **Steps:** insert a new step 1 before the old ones and renumber the rest:
  `1. Add test_export_empty_list in tests/test_exports.py: an export with no rows → 200, body is the header line only (",".join(EXPORT_COLUMNS) + "\r\n"). Run it and see it fail (500).`
  The existing step for building the CSV gets one more sentence:
  `Build the header from EXPORT_COLUMNS (api/models/export.py:12), not from the first row.`
- **Done when:** add this line:
  `- GET /api/exports/{id}.csv on an export with no rows returns 200 with only the header line`
- **Out of scope:** add this line:
  `- Any frontend change (download button, App.tsx wiring) — that is T3`
- **New section at the end:**
```markdown
## Notes from review
- web/src/App.tsx:18-31 — attempt 1 added a download button; this file is not in the task's Files list — revert it entirely; T2 is backend-only, the UI is T3.
- api/routes/exports.py:42 — header built from `rows[0].keys()` raises IndexError on an empty export → 500 — build the header from `EXPORT_COLUMNS` (api/models/export.py:12) so an empty export returns 200 with just the header row; cover it with `test_export_empty_list` first.
```

## 4. Log it in `board.md`
I'd set T2's row to `attempt 2 — task updated, ready to dispatch` and add this log line:
```
2026-11-23 T2 attempt 2 spec: review notes added (App.tsx out of scope; empty-list 500 → header from EXPORT_COLUMNS, new test). tasks/T2.task.md
```

## Reply
> I updated T2 for attempt 2 (`.orchestra/2026-11-21-csv-export/tasks/T2.task.md`):
> - **App.tsx:** the task now says not to touch `web/`. The review note says to revert the `App.tsx` change and that the button belongs to T3.
> - **Empty list:** the spec now starts with a test (`test_export_empty_list`, expecting 200 and only the header line). It also says to build the header from `EXPORT_COLUMNS` instead of `rows[0]`.
>
> T2 is ready to re-dispatch with `claude-dispatch`. It has used 1 of 3 attempts.