No task file written yet. "Clean up and improve" doesn't say what to change, and the skill says a vague goal must be turned into a specific change first. The implementer would have to guess, and a guessed task can't be reviewed.

**What I'd do before replying:**

1. Check whether a run exists: `ls /workspaces/<repo>/.orchestra/`. I'm assuming none does, so a task would go in a new run, `.orchestra/2026-11-23-books-cleanup/`.
2. Read the code, without editing anything. I'd look at `git ls-files | grep -i book`, the repo's `CLAUDE.md` for the test command, and the books files. I'm assuming a FastAPI layout: `app/books/routes.py`, `app/books/service.py`, `app/books/models.py`, `tests/test_books.py`, run with `uv run pytest tests/test_books.py -q`.
3. Run that test command once to confirm the suite passes now. A task's check must not fail for unrelated reasons.

**Reply to the user:**

> "Clean up and improve" covers too much for one implementer task. A task should touch about 5 files or fewer, have one specific goal and one test command. Here are possible tasks from the books backend (assuming the usual problems are there). Which ones do you want?
>
> 1. **Remove duplicated validation.** ISBN/title checks are copied in `routes.py` (create and update). Move them into one `validate_book()` in `service.py`. Files: `routes.py`, `service.py`, `tests/test_books.py`.
> 2. **Fix N+1 query** in `list_books()`, where authors load one book at a time. Add `selectinload(Book.authors)` and a test that counts queries.
> 3. **Paginate `GET /books`**: `limit` (default 50, max 200) and `offset`, with tests for the default, the max and a negative value.
> 4. **Proper 404s**: `get_book`/`update_book`/`delete_book` return `None` or a 500 for a missing ID. Change them to `HTTPException(404)`, with a test for each.
> 5. **Dead code and type hints**: delete unused helpers in `service.py` and add return types. No behavior change; the existing tests must still pass.
>
> If you pick more than one, I'll write each as its own task (T1, T2, …) in the run `2026-11-23-books-cleanup`. If you meant something else by "improve" (speed, a feature, an API change), tell me what.

I'd wait for the answer and write no file yet. Once the user picks, I'd write `.orchestra/2026-11-23-books-cleanup/tasks/T1.task.md` following the contract and note its path in `board.md`. Its steps would start with a failing test and name the existing pattern to copy by `file:line`. Its out-of-scope list would rule out renames, new dependencies and reformatting other files.