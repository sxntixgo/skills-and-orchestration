**This is a second-order SQL injection, and it's high severity.** The parameterized insert stops injection at signup. It doesn't make the stored value safe. Parameterization makes the database treat the input as data, so a username like `x' OR '1'='1` gets stored word for word. When the audit job later pastes that value into a SQL string, it runs as SQL.

**Exploit:** sign up with a username such as:
- `' OR '1'='1`: the audit query returns every log row.
- `' UNION SELECT ... --`: pulls data from other tables into the audit output.
- `'; DROP TABLE logs; --`: if the driver allows multiple statements in one call, this deletes the audit trail.

Background jobs usually run with broader DB privileges than request handlers, so the impact can be worse than injection in a normal request.

**Fix:** parameterize the read too:
```js
db.query("SELECT * FROM logs WHERE actor = $1", [user.username]);
```
(Use `?` instead of `$1` if that's your driver's placeholder.) Every value goes into a query as a bound parameter, wherever it came from: your own DB, a queue, config or another service. Data that has passed through storage is still untrusted.

**Hardening (optional, doesn't replace the fix):**
- Run the audit job's DB user with read-only access to `logs`.
- Restrict usernames to a pattern such as `^[A-Za-z0-9_.-]{3,32}$` at signup. This limits the damage but isn't a defense against injection.
- Turn off multi-statement execution in the driver.
- Better still, key logs on `user.id` rather than `username`. That avoids the string comparison and also survives username changes.
- Search the codebase for other string-built queries, e.g. `grep -rnE "query\(.*['\"]\s*\+" .` and template literals inside `query(`.