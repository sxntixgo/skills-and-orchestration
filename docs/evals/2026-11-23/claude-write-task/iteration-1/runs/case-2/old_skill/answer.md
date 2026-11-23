I haven't written a task yet. "Clean up and improve" doesn't say what to change, and the skill says to replace wording like that with a concrete change. I'd read the code first, then ask you to pick one change.

**What I'd do**

1. Read the backend. Nothing exists on disk, so I'm assuming `/workspaces/books` is a FastAPI + SQLAlchemy app tested with `uv run pytest`:
   ```
   cd /workspaces/books && git status && ls -R app tests | head -100
   cat app/routers/books.py app/models.py app/schemas.py app/importer.py
   ls tests/ && uv run pytest -q
   ls .orchestra/ 2>/dev/null
   ```
2. List concrete problems with `file:line`. These are made-up but plausible findings:
   - **A.** `app/routers/books.py:22,41,63,85`: the same "query the book by id, raise 404 if it's missing" block is copied into four handlers, while `app/routers/authors.py:14` already has a `get_author_or_404` helper.
   - **B.** `GET /books` (`app/routers/books.py:15`) returns every row and has no paging.
   - **C.** `app/importer.py:48`: a bare `except:` hides parse errors, and the row is silently skipped.
3. I wouldn't write anything yet. There's no run to save into, and doing all of A–C is more than one roughly 5-file task. That would need splitting into several tasks with `claude-orchestrate-development`.

**Reply to you**

> "Clean up and improve" is too wide for one task, and the local model will guess at anything that isn't spelled out. Here's what I found in the books backend:
>
> - **A. Remove the duplicated 404 lookups:** add a `get_book_or_404(db, book_id)` helper that copies `get_author_or_404` (`app/routers/authors.py:14`) and use it in the 4 handlers. Files: `app/routers/books.py`, `tests/test_books.py`. Check: `uv run pytest tests/test_books.py -q`.
> - **B. Paginate `GET /books`:** add `limit` (default 50, max 200) and `offset` query params. This changes the API, so clients that expect the full list will break.
> - **C. Stop the importer swallowing errors:** catch `ValueError` and `KeyError` only, log the row number and the error, and count skipped rows in the import summary. Add tests for a bad row and a missing column.
>
> I recommend **A** first. It's small, behaves the same as before, and makes B and C easier. Tell me which ones you want, or name a different change, and whether they should go into an existing `.orchestra/<run>/` or a new run such as `2026-11-23-books-cleanup`. If you want more than one, I'll plan them as separate tasks with `claude-orchestrate-development`.

**Once you choose (example for A, new run)**

I'd first run `uv run pytest tests/test_books.py -q` to check it passes now and that nothing unrelated is already failing. Then I'd write `.orchestra/2026-11-23-books-cleanup/tasks/T1.task.md`:

```markdown
---
id: T1
run: 2026-11-23-books-cleanup
depends_on: []
attempt: 1
---
# Replace the 4 duplicated book lookups with a get_book_or_404 helper

## Context
app/routers/books.py repeats "query Book by id, raise HTTPException(404)" in get/update/delete/cover
(lines 22, 41, 63, 85). Copy the existing pattern in app/routers/authors.py:14 (get_author_or_404).

## Files
- may change: app/routers/books.py, tests/test_books.py
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In tests/test_books.py add `test_update_missing_book_returns_404` and `test_delete_missing_book_returns_404`
   (PUT/DELETE /books/999999 → 404, body `{"detail": "Book not found"}`). Run them; they should pass already (behavior lock).
2. In app/routers/books.py add `def get_book_or_404(db: Session, book_id: int) -> Book:` mirroring authors.py:14,
   raising `HTTPException(status_code=404, detail="Book not found")`.
3. Replace the 4 inline lookups with `book = get_book_or_404(db, book_id)`.
4. Run the test command.

## Done when
- `uv run pytest tests/test_books.py -q` passes
- No inline `HTTPException(status_code=404` remains in app/routers/books.py except inside get_book_or_404

## Out of scope
- Moving helpers to a shared module, touching authors.py, pagination, importer changes, renames, reformatting other code
```

Last, I'd add the row `T1 | pending | tasks/T1.task.md` to `.orchestra/2026-11-23-books-cleanup/board.md`.