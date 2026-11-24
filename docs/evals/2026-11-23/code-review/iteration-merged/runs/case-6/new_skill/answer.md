The audit query has a second-order SQL injection, rated 🔴. Using a parameterized insert at signup keeps the insert safe, but the username is still stored exactly as the user typed it. When the audit job puts that stored value into its own SQL string, the injection happens there.

**What I'd do, in order:**
1. Add TodoWrite items: context, check every dimension, rate and order, report.
2. **Context:** read the audit job, where `user` is loaded from the users table, the signup insert, and the `db.query` wrapper to see whether it supports parameters. I can't see these files, so I'm assuming the following:
   - The audit job is in `jobs/audit.js`, with the query at line 42.
   - Signup is in `routes/signup.js` and uses `db.query("INSERT INTO users (username, …) VALUES ($1, …)", [username, …])`.
   - `db.query(sql, params)` accepts placeholders, which is the node-postgres style.
   - Signup has no username format check.
   - Neither file has tests.
3. Check every dimension. Trace each untrusted value from where it comes in (the signup body) to where it's used: signup body → `users.username` stored unchanged → read back → string-built into the `logs` query.
4. Write the report below to `./.claude-skills-work/code-review/audit-job/findings.md` and reply with it.

## Code Review: audit job logs query (jobs/audit.js)
### 🔴 Must fix
1. **Second-order SQL injection** (jobs/audit.js:42)
   - **Exploit:** an attacker signs up with the username `x' OR '1'='1`. The parameterized insert stores it unchanged. When the audit job runs, the query becomes `… WHERE actor = 'x' OR '1'='1'`, which returns every user's logs. A username like `x'; DROP TABLE logs; --` would also work if the driver allows stacked queries. With a `UNION SELECT`, the attacker could pull data from other tables into whatever the job outputs.
   - **Impact:** the audit job usually runs with high-privilege credentials. The attacker could read data across tenants, change or delete the audit trail and so hide their own actions, or exfiltrate data.
   - **Fix:** `db.query("SELECT * FROM logs WHERE actor = $1", [user.username])`. Data read back from the DB is still untrusted, so parameterize every query that uses it.
2. **Wrong results for valid usernames** (jobs/audit.js:42) — even without an attack, any username with an apostrophe (`o'brien`) causes a syntax error, and that user's audit run fails. Usernames that contain SQL text silently return the wrong set of rows, so the audit itself becomes unreliable. → The parameterized query from finding 1 fixes this too.
### 🟡 Should fix
1. **Other queries may have the same problem** (jobs/, repo-wide) — if one job builds SQL by string concatenation, others probably do too. → Search for `query(".*" +` and template-literal SQL, and parameterize every match. Consider adding a lint rule such as `no-restricted-syntax` on string-built SQL.
2. **No regression test** (jobs/audit.test.js, missing) → Add a test that creates the users `o'brien` and `x' OR '1'='1`. Assert that the audit returns only the matching user's log rows and doesn't throw.
3. **No username format check at signup** (routes/signup.js:~15) → Allowlist usernames, e.g. `^[A-Za-z0-9_.-]{3,32}$`. This is defense in depth only; it doesn't replace finding 🔴1.
### 🟢 Consider
1. **`SELECT *`** (jobs/audit.js:42) → List the columns the job uses. This keeps payloads small and stops schema changes from quietly changing what the job reads.
2. **Least privilege** → Run the audit job with a DB role that can only read `logs` and `users`. A future injection would then do much less damage.
### ✅ Good
- Signup already uses a parameterized insert. Applying the same pattern to the audit query fixes the vulnerability.

The file paths and line numbers above are assumptions. Send me the real files and I'll anchor the findings to the actual lines.