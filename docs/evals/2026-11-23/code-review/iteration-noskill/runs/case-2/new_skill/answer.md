**What I'd do**

1. TodoWrite: context → check dimensions → rate/order → report.
2. Context: there's no file path, so I'd review the snippet inline as `snippet:1`. I can't read callers. I assume `db.q(u)` runs a lookup keyed by `u` (probably a user id) and returns a list of rows, and that callers expect one record.
3. Write `./.claude-skills-work/code-review/get-snippet/findings.md` with the report below.
4. No subagents and no commands.

**Reply**

```markdown
## Code Review: get(u) snippet
### 🔴 Must fix
1. **Crashes when nothing matches** (snippet:1) — If `db.q(u)` returns an empty list (unknown id, deleted row, `u=None`), `d[0]` raises a bare `IndexError` with no context. Callers can't tell "not found" apart from a bug. → Handle the empty case on purpose: `rows = db.q(user_id)`, then `if not rows: return None`, or `raise UserNotFound(f"user {user_id} not found")`. Write down which one callers should expect.

### 🟡 Should fix
1. **Silently picks a row when there are several** (snippet:1) — If more than one row matches, the code returns whichever comes first. Without an ORDER BY, that row can change between runs. → If `u` is a unique key, check for it: `if len(rows) > 1: raise LookupError(f"expected 1 row for {user_id}, got {len(rows)}")`. Otherwise add a deterministic ORDER BY in the query.
2. **Possible injection, depending on `db.q`** (snippet:1) — If `q` builds SQL by putting `u` into the string, this is an injection point. → Make sure `q` uses bound parameters. Run `security-review` to confirm.
3. **Names don't say what they mean** (snippet:1) — `get`, `u`, `d` and `q` don't show what is fetched or what comes back. → Use names like `get_user(user_id)` and `rows`, and add a return type such as `-> User | None`.
4. **No tests in view** (snippet:1) — → Add tests for one match (returns the row), no match (returns `None` or raises `UserNotFound`) and several matches. Use a fake `db` so the tests don't need a real database.

### 🟢 Consider
1. **Push "first or none" into the data layer** (snippet:1) — If other code also calls `db.q(...)[0]`, a single `db.one(...)` / `db.one_or_none(...)` helper would keep the not-found handling in one place.

### ✅ Good
- It's small and does one job, which makes the fixes above cheap.
```

I assumed `db.q` returns a list and that `u` is a unique id. If `q` already raises on no rows, the 🔴 drops to the naming and test issues.