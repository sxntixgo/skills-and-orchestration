**What I'd do, in order**

1. TodoWrite: (1) get context, (2) review each dimension, (3) rate and locate findings, (4) report.
2. Get context. There's no file or diff, only a pasted one-liner, so I review it as `snippet:1`. Assumptions: it's Python, `db` is a module-level DB handle, `db.q(u)` runs a query keyed by a user id `u` and returns a list of rows (possibly empty), and callers expect one row back. I can't check project conventions or tests, so I say so in the report.
3. Write the checkpoint file `./.claude-skills-work/code-review/get-snippet/findings.md` (contents are the report below).
4. No subagents. One line of code doesn't need any.
5. Reply:

---

## Code Review: `get(u)` (pasted snippet, `snippet:1`)

The main bug is that `d[0]` crashes with an unhelpful error when the query finds no rows.

### 🔴 Must fix
1. **No-match case crashes** (snippet:1) — `d[0]` raises `IndexError` when `db.q(u)` returns no rows (an unknown id, or a row that was deleted). The caller gets a bare `IndexError` with no context. → Check for empty results and either return `None` (make the return type `Optional[...]`) or raise a domain error with the id: `if not rows: raise UserNotFound(f"user {u!r} not found")`.
2. **Extra matching rows are silently dropped** (snippet:1) — if more than one row matches, the function returns whichever row comes first with no warning. That hides bad data or a query that's too broad. → If the id should be unique, assert it (`if len(rows) > 1: raise ...`) or use a single-row helper like `db.one(...)` / `fetchone`, if the project has one.

### 🟡 Should fix
1. **Names don't say what they hold** (snippet:1) — `get`, `u`, `d` and `q` don't tell the reader what is fetched, by what key, or what comes back. → For example `def get_user(user_id: int) -> User | None: rows = db.q(user_id) ...`.
2. **Several statements on one line** (snippet:1) — putting the `def` and its statements on one line with `;` hurts readability and makes tracebacks less useful. → Put one statement on each line.
3. **Behaviour isn't documented** (snippet:1) — nothing says what happens when there are zero rows or several. → Add type hints and a one-line docstring that states the not-found behaviour.

### 🟢 Consider
1. **Global `db` dependency** (snippet:1) — it's hard to swap out in tests. Consider passing the handle in or using the project's repository/session pattern, if it has one.
2. **Tests** — I couldn't see any. At minimum, cover: id found, id not found, and (if uniqueness isn't enforced) several rows.

### ✅ Good
- It's small and does one thing, so the fixes above are cheap to make.

**Assumptions:** Python, `db.q` returns a list, and `u` is a lookup key. I couldn't check project conventions or existing tests. This is a quality review, not a security audit. Whether `db.q(u)` builds SQL from `u` unsafely (injection) needs a separate security review.