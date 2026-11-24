**What I'd do, in order**

1. TodoWrite: `Map attack surface` · `Trace sources→sinks` · `Check every class` · `Verify controls` · `Write report`.
2. **Attack surface:** the only untrusted source is the `Authorization` header, which the client controls completely. The sink is the authorization decision `grantAdmin()`. I'm assuming this runs in Express/Node with the `jsonwebtoken` library, the header value looks like `Bearer <token>`, and there's no other middleware. I can't see the file, so locations are given as `snippet:1–2`.
3. **Trace:** `req.headers.authorization` → `jwt.decode()` → `payload.role` → `grantAdmin()`. Nothing verifies the token anywhere on that path, so this is a finding.
4. **Check every class:** I'd go through the full table. Authentication, authorization and config apply here. Injection, SSRF, deserialization, path traversal, XSS, open redirect, secrets and crypto don't appear in these two lines (N/A).
5. **Write** `./.claude-skills-work/security-review/jwt-admin-check/findings.md` with the report below.

---

## Security Review: JWT admin check (snippet)

### 🔴 Critical
1. **Authentication: JWT decoded without verifying its signature** (snippet:1)
   - Exploit: `jwt.decode()` only base64-decodes the token and never checks the signature. An attacker can write any token with a payload of `{"role":"admin"}`, using any signature or `alg:none`, and send it in `Authorization`. The check on line 2 passes.
   - Impact: anyone can become admin without credentials. This is a full authentication and authorization bypass.
   - Fix: use `jwt.verify(token, key, { algorithms: ['RS256'] /* or HS256 */, issuer, audience })`. Pin the algorithm so `none` and alg-confusion tokens are rejected. Only read claims after `verify` succeeds. `verify` also enforces `exp` and `nbf`, which `decode` skips, so this fixes the expiry problem too.

### 🟡 Medium
2. **Authentication / Config: malformed or missing header crashes the handler** (snippet:1–2)
   - Exploit: a missing header, or the usual `Bearer <token>` format (which `decode` can't parse), makes `jwt.decode()` return `null`. `payload.role` then throws a `TypeError`. In an async handler with no error handling, that's an unhandled rejection. It could take down the process or leak a stack trace if debug output is on.
   - Impact: denial of service or information disclosure. Every legitimate Bearer request also fails.
   - Fix: strip the `Bearer ` prefix, return 401 when the header is missing or malformed, and wrap `verify` in try/catch so any failure returns 401 (fail closed).

### 🟢 Low
3. **Authorization: role comes only from the token** (snippet:2)
   - Exploit: even after the fix, a signed token keeps its `role:"admin"` claim until it expires. That includes tokens for users who were demoted or disabled.
   - Impact: privilege stays active after it's revoked.
   - Fix: use short token lifetimes, or look up the user's role server-side, or keep a revocation list, before `grantAdmin()`. Also check that the admin action is scoped per resource where that matters.

### ✅ Controls verified
- None. The snippet has no signature verification, algorithm pinning, expiry check, input validation or error handling. I couldn't verify anything outside these two lines, such as upstream auth middleware, TLS, or rate limiting on this endpoint. Check those separately.

**Fixed pattern:**
```js
const [scheme, token] = (req.headers.authorization || '').split(' ');
if (scheme !== 'Bearer' || !token) return res.sendStatus(401);
let payload;
try {
  payload = jwt.verify(token, PUBLIC_KEY, { algorithms: ['RS256'], issuer: ISS, audience: AUD });
} catch { return res.sendStatus(401); }
if (payload.role === 'admin') grantAdmin();
```