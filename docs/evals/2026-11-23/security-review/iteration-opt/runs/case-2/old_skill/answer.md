Write down of what I'd do, in order:

1. **TodoWrite:** map attack surface → trace data → check vuln classes → verify controls → report.
2. **Assumptions:** No file paths were given, so I treat the snippet as `audit job: logs query`. I assume the audit job runs with the app's normal DB credentials, that its output reaches a report or dashboard, and that signup puts no character restriction on usernames.
3. **Write** `./.claude-skills-work/security-review/audit-job-logs-query/findings.md` with the report below, updating it as each step finishes.
4. **Reply:**

---

## Security Review: audit job `logs` query

The audit query has a second-order SQL injection. The parameterized insert at signup only keeps the username from breaking the INSERT. It stores the attacker's text exactly as typed, and the audit job then concatenates it into SQL. Data read back from your own database is still untrusted if a user originally supplied it.

### 🔴 Critical
1. **Second-order SQL injection** (audit job, `db.query("SELECT * FROM logs WHERE actor = '" + user.username + "'")`)
   - **Source → sink:** signup form → `users.username` (stored unchanged by the safe insert) → read back as `user.username` → concatenated into a SQL string → `db.query`.
   - **Exploit:** An attacker signs up with a username that contains a single quote followed by SQL. That username saves without error. When the audit job runs, the quote closes the `actor = '...'` string and the rest runs as SQL. Two cases:
     - The attacker could add a `UNION SELECT` against `users` or other tables, or a condition that's always true.
     - Some drivers allow several statements in one call with no parameters, for example node-postgres's simple query protocol or MySQL with `multipleStatements`. Then the attacker can also run `UPDATE` or `DELETE` statements.
     
     If the attacker never sees the output, they can still pull data out through timing tricks or by writing changes they can see later.
   - **Impact:**
     - Read access to anything the audit job's DB user can reach: credentials, password hashes, PII.
     - If stacked statements work, writes too: raising their own role, or tampering with or deleting audit logs, which defeats the purpose of the audit job.
     - It's delayed and indirect, so it's hard to link back to the attacker's signup.
     - Anyone who can sign up can do this, and it needs no special access.
   - **Fix:**
     - Parameterize this query: `db.query("SELECT * FROM logs WHERE actor = $1", [user.username])` (or `?`, depending on your driver).
     - Better still, store and query logs by the immutable `user.id` instead of the username.
     - Grep the codebase for other queries built from stored values. Second-order bugs usually come in groups, so check other batch jobs, reports and admin tools too.
     - Add a regression test using a username that contains `'`.

### 🟢 Low (defense in depth)
2. **No username validation at signup** (assumed)
   - **Exploit:** Usernames can contain quotes and SQL text, which is how the finding above gets its payload into the database. The same values could also reach other sinks, such as HTML in an audit dashboard (stored XSS) or shell commands in scripts. I haven't checked where audit output is rendered.
   - **Impact:** Leaves more room for injection anywhere stored usernames are used.
   - **Fix:** Limit usernames to an allowlist (e.g., `^[A-Za-z0-9_.-]{3,32}$`). This adds a layer but doesn't replace finding #1's fix. Also give the audit job a read-only DB role limited to `logs`, so a future injection can't read `users` or write anything.

### ✅ Controls verified
- The signup insert is parameterized (as you described), so there's no first-order SQL injection at signup. That doesn't protect the audit job's query.
- Not verified: the audit job's DB privileges, whether its driver allows several statements per call, and where its output is shown. All three affect how bad finding #1 is, but none of them changes the fix.