**I wouldn't write this task yet.** "Clean up and improve" is a red flag in the skill: a small model would guess what it means, and a reviewer would have nothing concrete to check. A whole-backend cleanup would also touch far more than ~5 files. So I'd read the code first, turn it into specific candidate tasks, and ask you to pick one.

### What I'd do, in order

1. **Find the backend and how it's tested (read-only):**
   ```bash
   cd /workspaces/<repo>
   git ls-files | grep -i book
   cat CLAUDE.md
   cat .orchestra/config.json 2>/dev/null
   ls .orchestra/ 2>/dev/null
   ```
   *Assumed result:* a FastAPI app in `backend/books/` with `routes.py` (~400 lines), `models.py`, `db.py` and `schemas.py`. Tests are in `tests/books/` and run with `uv run pytest tests/books -q`. Linting is `uv run ruff check`. There's no active `.orchestra/` run.

2. **Look for concrete problems:**
   ```bash
   uv run pytest tests/books -q
   uv run ruff check backend/books
   grep -rn "TODO\|FIXME\|except Exception\|print(" backend/books
   git log --oneline -15 -- backend/books
   ```
   I'd also read `routes.py` and `models.py` end to end.
   *Assumed findings:*
   - `routes.py:40-95` and `:210-260`: `list_books` and `search_books` copy the same pagination and filter code.
   - `routes.py:130`: `get_book` catches `except Exception` and returns 500 for a missing book instead of 404.
   - `routes.py:300-340`: `create_book` checks ISBNs by hand. `schemas.BookIn` has no validator, and there's no test for invalid ISBNs.
   - 12 ruff warnings: unused imports and leftover `print()` calls.
   - `list_books` has no tests.

3. **Write nothing yet.** I wouldn't create `.orchestra/<run>/` or a task file until you choose. I'd log nothing, because there's no run or `board.md` yet.

### My reply to you

> "Clean up and improve" is too broad for one implementer task. In `backend/books/` I found these specific problems, each a separate task of 1–3 files:
>
> 1. **`get_book` returns 500 instead of 404 for a missing book** (`routes.py:130`). Add a test for the missing case and catch `NoResultFound` only. *(I recommend this one: it's a real bug.)*
> 2. **Pull the duplicated pagination and filter code** in `list_books` and `search_books` into a single `_apply_filters(query, params)` in `routes.py`. Add tests for `list_books` first.
> 3. **Move ISBN validation** into a `BookIn` field validator in `schemas.py`. Add tests for valid, invalid-checksum and wrong-length ISBNs, and make the endpoint return 422.
> 4. **Fix the ruff warnings** in `backend/books` (unused imports, `print()` calls).
>
> Which one or ones? If you want several, I'd set up an orchestration run (`claude-orchestrate-development`), with 2 depending on 1 because both edit `routes.py`. If you pick 1, here's the spec I'd save as `.orchestra/2026-11-23-books-cleanup/tasks/T1.task.md`:
>
> ```markdown
> ---
> id: T1
> run: 2026-11-23-books-cleanup
> depends_on: []
> attempt: 1
> ---
> # GET /books/{id} returns 404 (not 500) for a missing book
>
> ## Context
> `get_book` (backend/books/routes.py:130) wraps the query in `except Exception` and returns 500,
> so a missing id looks like a server error. Copy the 404 pattern in `get_author`
> (backend/books/routes.py:175): catch `NoResultFound`, raise `HTTPException(404, "Book not found")`.
>
> ## Files
> - may change: backend/books/routes.py, tests/books/test_routes.py
> - must NOT touch: everything else (and never .orchestra/, .git/)
>
> ## Steps
> 1. In tests/books/test_routes.py add `test_get_book_missing_returns_404`: GET /books/999999 → 404,
>    body `{"detail": "Book not found"}`. Reuse the `client` fixture. Run it and see it fail (500).
> 2. In `get_book`, replace `except Exception` with `except NoResultFound`
>    (from sqlalchemy.exc) and raise `HTTPException(status_code=404, detail="Book not found")`.
> 3. Run the test command; all tests in the file pass.
>
> ## Done when
> - `uv run pytest tests/books/test_routes.py -q` passes
> - GET /books/<missing id> returns 404; other errors are no longer swallowed as 500
>
> ## Out of scope
> - Other endpoints' error handling, the pagination duplication, ISBN validation, lint fixes
> - Renames, reformatting, new dependencies
> ```

Once you choose, I'd run the test command once to confirm it fails for the right reason (500, not an import error). Then I'd save the file, note its path in `board.md`, and hand it to `claude-dispatch`.