The audit query has a **critical second-order SQL injection**. The parameterized insert stores the username safely, but the value is still attacker-controlled when the audit job reads it back. The job then pastes it straight into the SQL string.

**Steps I'd take**

1. Create TodoWrite items: attack surface, trace, check every class, verify controls, report.
2. Map the attack surface. The username comes from the user at signup and is stored as-is. The insert is parameterized, so it's safe at that point. The audit job reads it back from `users`, and that read-back value is still untrusted.
3. Trace it. `user.username` is concatenated into `db.query(...)` in the audit job, so there's an unsanitized path to a SQL sink.
4. Check every class against the snippet. Injection is a finding. I can't assess the other classes from two statements, so I'd mark them "not visible" rather than "pass".
5. Write `./.claude-skills-work/security-review/audit-job/findings.md` with the report below.

No subagents. The scope is two statements.

---

## Security Review: signup + audit job

**Assumptions:** I don't have the files, so locations are described rather than given as `file:line`. I'm assuming signup accepts arbitrary characters in usernames (quotes included), and that the audit job's DB user has more than read access to `logs`.

### 🔴 Critical
1. **SQL injection, second-order** (audit job, `db.query("SELECT * FROM logs WHERE actor = '" + user.username + "'")`)
   - **Exploit:** An attacker registers with a username containing a single quote followed by SQL. The parameterized insert stores it unchanged. When the audit job runs, the quote closes the `actor` string literal and the rest runs as SQL.
   - **Impact:** The attacker's SQL runs with the audit job's DB privileges. Depending on the driver, they could read any table (password hashes, other users' data) or, if stacked queries are allowed, modify or delete data and tamper with the audit logs themselves. Batch jobs often run with high privileges and nobody watches them, so this can be worse than injection in a web request.
   - **Fix:**
     - Parameterize the read too: `db.query("SELECT * FROM logs WHERE actor = ?", [user.username])` (use `$1` etc. for your driver).
     - Treat every value read from the DB as untrusted at every sink.
     - Defense in depth: restrict usernames to an allowlist (e.g. `^[A-Za-z0-9_.-]{3,32}$`) at signup, and give the audit job a read-only DB role.

### 🟢 Low
2. **Data exposure** (same query): `SELECT *` pulls every log column. If the results get printed or exported, they may expose PII or secrets stored in `logs`.
   - **Fix:** Select only the columns the audit needs.

### ✅ Controls verified
- Signup insert is parameterized, so there's no first-order injection at write time.

### Not assessable from the snippet
Authentication, authorization (who can trigger the audit job or read its output), secrets, crypto, SSRF, deserialization, path traversal, XSS, open redirect, CSRF and config all need the surrounding code. If the audit output is rendered in an admin UI, check it for stored XSS from the same username.