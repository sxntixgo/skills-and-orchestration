## What I'd do

1. **TodoWrite** with these items: map the attack surface, trace sources to sinks, check every class, verify controls, report.
2. **Assumptions:** this is Node/Express using the `jsonwebtoken` library. You pasted a snippet with no file path, so I'd cite it as `snippet:1` and `snippet:2`. There's no surrounding code to read, so I'd run no commands and spawn no subagents.
3. **Attack surface:** the `Authorization` header, which the client fully controls. The sink is the admin authorization decision, `grantAdmin()`.
4. **Write** `./.claude-skills-work/security-review/jwt-admin-check/findings.md` with the report below.
5. **Reply** with the same report.

---

## Security Review: JWT admin check

### 🔴 Critical
1. **Authentication: JWT signature never verified** (snippet:1)
   - Exploit: `jwt.decode()` only base64-decodes the token and never checks its signature or expiry. An attacker writes their own token with `{"role":"admin"}` (unsigned or with any signature), sends it as `Authorization`, and line 2 grants admin.
   - Impact: anyone can become admin without credentials. This is a full auth bypass.
   - Fix: use `jwt.verify(token, key, { algorithms: ['RS256'], issuer, audience })`. Pin the algorithm so `alg:none` and HS/RS key-confusion attacks fail. Rely on the built-in `exp`/`nbf` checks and reject the request on any error.

### 🟠 High
2. **Authorization: privilege taken from a token claim, not checked server-side** (snippet:2)
   - Exploit: even after you add `verify`, a token issued before the user was demoted still says `role: 'admin'` until it expires. If any token issuer or key is ever compromised, it can also mint admin tokens.
   - Impact: users keep admin rights after they've been revoked, and tokens are as powerful as the most powerful role they can claim.
   - Fix: take the subject (`sub`) from the verified token and look up the role in the server-side user store. Alternatively, keep admin tokens short-lived and add a revocation check.

### 🟡 Medium
3. **Input handling: raw header passed in and no null check** (snippet:1–2)
   - Exploit: if the header is missing, malformed, or has the usual `Bearer ` prefix, `jwt.decode` returns `null`. `payload.role` then throws a `TypeError`.
   - Impact: unhandled exceptions cause 500 errors, possibly crash the process (DoS), and may leak stack traces.
   - Fix: parse the header strictly (`/^Bearer (.+)$/`), return 401 when it's missing or malformed, and wrap `verify` in try/catch so every failure returns 401.

### 🟢 Low
4. **Config: no rate limiting on the auth path** (snippet). I can't confirm this from the snippet. Rate-limit token-bearing admin endpoints and log failed admin attempts.

### Not applicable to this snippet
Injection, secrets, crypto, SSRF, deserialization, path traversal, XSS, open redirect and CSRF have no source-to-sink path here. CSRF would matter if the token also came from a cookie.

### ✅ Controls verified
- None. There's no signature check, no expiry check, no algorithm pinning and no error handling.