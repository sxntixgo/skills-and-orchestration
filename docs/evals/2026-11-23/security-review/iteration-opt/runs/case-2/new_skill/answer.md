**What I'd do:** make a TodoWrite list of the 5 skill steps (attack surface, trace, check every class, verify controls, report). Write the findings to `./.claude-skills-work/security-review/audit-job-username/findings.md`. I wouldn't run any commands. I'm assuming two files I can't see: the signup handler is in `signup.js` and the audit query is in `jobs/audit.js`. Line numbers are unknown, so the report says "line TBD".

**Contents of findings.md (also my reply):**

## Security Review: audit job `logs` query (second-order SQL injection)

The query is injectable even though signup uses a parameterized insert. Parameterizing the insert stops injection at signup, but the raw username is still what gets stored. When the audit job reads it back and concatenates it into a new query, the attacker's text runs as SQL.

### 🔴 Critical
1. **Injection: second-order SQL** (`jobs/audit.js:TBD`, the `db.query("SELECT * FROM logs WHERE actor = '" + user.username + "'")` line)
   - **Exploit:** An attacker signs up with a username containing a single quote and SQL syntax. The parameterized insert stores it unchanged. When the audit job runs, the quote ends the `actor` string literal, and everything after it becomes part of the query. That could be an always-true condition, a `UNION` that reads other tables, or stacked statements if the driver allows multiple statements. Source: `users.username`, which the user controls at signup. Sink: the concatenated `db.query`.
   - **Impact:**
     - Read any data the job's DB role can see, such as other users' logs, the `users` table and password hashes.
     - Tamper with or delete audit logs, which destroys the audit trail. That matters because the job exists to establish accountability.
     - If stacked queries are enabled or the role has write or admin rights, change data or escalate privileges.
     - Audit jobs often run with elevated privileges, which increases the damage.
   - **Fix:**
     - Parameterize this query: `db.query("SELECT * FROM logs WHERE actor = $1", [user.username])`, or the `?` placeholder form your driver uses.
     - Search the codebase for every other place where a value from the DB or a request is concatenated into SQL.
     - Run the audit job under a least-privilege, read-only DB role.
     - Optional defense in depth: restrict usernames to a character allowlist at signup. This doesn't replace parameterizing.

### 🟢 Low / notes
2. **Data exposure** (`jobs/audit.js:TBD`): `SELECT *` pulls every column from `logs`. If logs contain PII or secrets, an injection exposes more of them, and so does any output the job writes. Select only the columns you need.

### Other checks
- Other vulnerability classes (auth, authz, secrets, crypto, SSRF, deserialization, path traversal, XSS, redirect, CSRF, config): I can't assess them from this snippet.
- **To confirm:** where the audit output goes. If it's rendered in an HTML admin view, usernames also need output encoding to prevent stored XSS.
- **To confirm:** whether the DB driver allows multiple statements per query. If it does, raise impact to arbitrary write.

### ✅ Controls verified
- The signup insert is parameterized (as you described). It prevents first-order injection at signup and nothing more.