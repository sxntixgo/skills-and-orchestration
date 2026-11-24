## Steps I'd take

1. **TodoWrite:** map the attack surface → trace the data → check the vuln classes → verify controls → report.
2. **Assumptions:** this is Node/Express with the `jsonwebtoken` library. There's no file path, so locations are given as `snippet:L1` and `snippet:L2`. `grantAdmin()` gives the caller admin rights for this request.
3. **Attack surface:** one attacker-controlled input, `req.headers.authorization`. It flows through `jwt.decode`, then `payload.role`, then into a privilege decision at `grantAdmin()`. No signature check sits on that path.
4. **Vuln classes checked:** broken authN and broken authZ apply. Misconfiguration (crash and error leakage) is a side effect. Injection, SSRF, deserialization, path traversal, XSS, CSRF and secrets don't apply to these two lines.
5. **Checkpoint:** write `./.claude-skills-work/security-review/jwt-admin-check/findings.md` containing the report below.
6. **Reply:**

---

## Security Review: JWT admin check

### 🔴 Critical
1. **Broken authentication: JWT signature never verified** (snippet:L1)
   - Exploit: `jwt.decode()` only base64-decodes the token and never checks the signature. An attacker builds a token with `{"role":"admin"}` in the payload and any signature, or none, and sends it in `Authorization`. `decode` accepts it.
   - Impact: Anyone, including unauthenticated users, gets admin.
   - Fix: Use `jwt.verify(token, key, { algorithms: ['RS256'] /* or your one alg */, issuer, audience })`. Pin the algorithms list to block `alg:none` and HS/RS key-confusion. Rely on `exp` being enforced (verify does this by default). Use `jsonwebtoken` ≥ 9. Reject the request if verification throws.

2. **Broken authorization: admin role taken from a client-supplied claim** (snippet:L2)
   - Exploit: The role decision rests on a value the client sends. Finding 1 makes that a direct bypass. Even after you verify signatures, a role baked into a long-lived token stays valid after the user is demoted or disabled.
   - Impact: Privilege escalation, and revoked admins keep their access.
   - Fix: After verifying, use only `sub` to identify the user. Look up the role on the server (database or authz service) at decision time. Or keep token TTLs short and add a revocation check.

### 🟡 Medium
3. **Unvalidated header causes a crash (DoS / error leakage)** (snippet:L1–L2)
   - Exploit: The raw header is passed through as-is. A missing header, `Bearer <token>`, or garbage makes `decode` return `null`, so `payload.role` throws a `TypeError`. Without an error handler this becomes a 500 response, can leak a stack trace if debug is on, or crashes the process if the code is async with no catch.
   - Impact: Information disclosure. Anyone can trigger this unauthenticated, so it may crash the app.
   - Fix: Require the `Bearer ` scheme and remove the prefix. If the header is missing or malformed, return 401. Wrap `verify` in try/catch and return a generic 401. Then check `payload?.role` explicitly.

### ✅ Controls verified
- The role check uses `===` (strict equality), so type-coercion tricks don't work.
- No other controls are present. There's no signature check, `exp`/`iss`/`aud` validation, scheme check or error handling.

**Corrected shape:**
```js
const [scheme, token] = (req.headers.authorization || '').split(' ');
if (scheme !== 'Bearer' || !token) return res.sendStatus(401);
let claims;
try { claims = jwt.verify(token, PUBLIC_KEY, { algorithms: ['RS256'], issuer: ISS, audience: AUD }); }
catch { return res.sendStatus(401); }
const user = await users.findById(claims.sub);
if (user?.role === 'admin') grantAdmin();
```