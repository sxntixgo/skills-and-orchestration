**What I'd do:**

1. TodoWrite: Context → Check dimensions → Rate/order → Report.
2. Context: no file path, callers or `db.q` source were given, so I'd anchor findings as `snippet:1`. Assumptions: `u` is a user identifier from a request, and `db.q(u)` runs a query and returns a list of rows.
3. Write the report below to `./.claude-skills-work/code-review/snippet/findings.md` and reply with it.

---

## Code Review: `get(u)` (pasted snippet)

### 🔴 Must fix
1. **Crashes when nothing matches** (snippet:1): `d[0]` raises `IndexError` when the query returns no rows, which is the normal "not found" case. If `db.q` returns `None`, it raises `TypeError` instead. Either way, callers get a raw exception with no context. → Return `None` (or raise a domain `NotFoundError(f"user {u} not found")`) when `d` is empty, and document which one callers should expect.

### 🟡 Should fix
1. **Returns an arbitrary row when several match** (snippet:1): if `u` isn't a unique key, or the query has no `ORDER BY`, `d[0]` returns whichever row the DB gives first. That's a silently wrong result. → Query on a unique key. If more than one row means bad data, check for it and raise.
2. **Possible SQL injection: check `db.q`** (snippet:1): I can't see how `db.q` builds its SQL. If it puts `u` into the string with formatting, an attacker can send `u = "x' OR '1'='1"` and get the first row of the whole table. Worse inputs could use UNION to read other tables. Impact: data disclosure. → Make sure `db.q` uses bound parameters (`cursor.execute("... WHERE id = %s", (u,))`). If it does, drop this finding.
3. **No authorization check visible** (snippet:1): if `u` comes from the request, any caller can fetch any user's record by changing the id (IDOR). → Check that the requester may access `u`, either here or in the one caller that can see the session. Confirm where that check lives.
4. **Names don't say what anything is** (snippet:1): `get`, `u`, `d` and `q` hide what is fetched and what comes back. → For example, `get_user(user_id)`, `rows = db.query(...)`, with a return type hint (`-> User | None`).

### 🟢 Consider
1. **Tests** (snippet:1): no tests shown. → Add three: one row found, no rows (expect `None` or `NotFoundError`), and several rows (the edge case).

### ✅ Good
- Small, single-purpose function with no side effects, so it's easy to fix and test.

---

I didn't see `db.q` or any callers, so findings 🟡2 and 🟡3 depend on code I couldn't check. Paste `db.q` and the call site and I can confirm or drop them.