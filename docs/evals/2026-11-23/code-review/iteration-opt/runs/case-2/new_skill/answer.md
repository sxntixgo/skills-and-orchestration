**What I'd do, in order:**

1. TodoWrite: Context · Check dimensions · Rate/order · Report.
2. Context: the snippet was pasted, so there's no file or callers to read. I'm assuming it's Python, `db.q(u)` runs a lookup keyed by `u` (probably a user id) and returns a list of rows, and callers expect one record. Findings are anchored to `snippet:1`.
3. Write `./.claude-skills-work/code-review/get-snippet/findings.md` with the report below.
4. Reply:

---

## Code Review: `get(u)` (pasted snippet)

Assumes `db.q` returns a list of rows and `u` is a user id. I couldn't see the callers or the `db.q` source, so I may need to re-check findings 1–3 against them.

### 🔴 Must fix
1. **No row found crashes** (snippet:1): when nothing matches, `db.q(u)` returns `[]` and `d[0]` raises a bare `IndexError` with no context. If `q` can return `None`, it raises `TypeError` instead. → Handle the empty case on purpose. Either return `None` (and type it `Optional[...]`), or raise a domain error with context: `raise NotFoundError(f"no record for id={u}")`.
2. **Duplicate rows are silently ignored** (snippet:1): if the lookup can match more than one row, `d[0]` returns whichever the database orders first and hides the data problem. → If `u` should be unique, check `len(d) == 1` and raise if not. Otherwise add an explicit `ORDER BY` / `LIMIT 1` in the query.

### 🟡 Should fix
3. **Possible injection in `db.q(u)`** (snippet:1): I can't see `q`. If it puts `u` into the SQL with string formatting, this is SQL injection. → Make `q` take a parameterized query (`db.q("... WHERE id = %s", (u,))`) and run `security-review` on `db.q`.
4. **Names don't reveal intent** (snippet:1): `get`, `u`, `d` and `q` don't say what is fetched or by what key. → Use something like `def get_user(user_id): rows = db.query(...)`.
5. **One-liner hides the logic** (snippet:1): with `;` on one line there's no room for the guard clause from #1, and it's harder to step through in a debugger. → Split it into separate lines, with a guard clause before the return.
6. **No tests visible**: → Add tests for the found case, the not-found case (expect `None` or `NotFoundError`) and, if relevant, the duplicate-rows case. Stub `db` so the tests don't need a real database.

### 🟢 Consider
7. **Hidden global dependency** (snippet:1): the module-level `db` is hard to swap out in tests. → Pass the connection or repository in as a parameter, or inject it, to match how the rest of the module does it.
8. **No type hints** (snippet:1): → Use `def get_user(user_id: int) -> User | None:` so callers know they have to handle the missing case.

### ✅ Good
- One small function with a single job: fetching one record.

Example shape (a suggestion, your call):
```python
def get_user(user_id: int) -> User | None:
    rows = db.query("SELECT ... WHERE id = %s", (user_id,))
    if not rows:
        return None
    return rows[0]
```