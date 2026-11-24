The check is an auth bypass. `jwt.decode` reads the token without checking its signature, so anyone can make themselves admin.

**What I'd do:**
1. Add TodoWrite items for Context, Dimensions, Rate/order and Report.
2. **Context:** the code was pasted inline, so there are no callers to read. I'm assuming Node with the `jsonwebtoken` library, Express-style `req`, and that `grantAdmin()` gives admin rights for the current request. Line refs are `snippet:1` (the decode) and `snippet:2` (the role check).
3. Check every dimension and write the findings to `./.claude-skills-work/code-review/auth-check/findings.md`. That file holds the report below.

## Code Review: auth check snippet
### 🔴 Must fix
1. **JWT decoded without signature check (auth bypass)** (snippet:1–2) — Exploit: the attacker writes their own token, `base64url({"alg":"none"}).base64url({"role":"admin"}).`, or any token with a made-up signature, and sends it in `Authorization`. `jwt.decode` returns the payload without checking the signature, so `payload.role === 'admin'` is true and `grantAdmin()` runs. · Impact: any unauthenticated user gets full admin access. → Use `jwt.verify(token, key, { algorithms: ['RS256'], issuer, audience })`. Pin the algorithm list so `alg:none` and HS/RS key confusion are rejected. Let `verify` enforce `exp`/`nbf`. Wrap it in try/catch and return 401 on failure.

### 🟡 Should fix
1. **Bearer prefix not stripped, and null payload crashes** (snippet:1–2) — The header normally holds `Bearer <token>`, which `jwt.decode` can't parse, so it returns `null`. A missing header also gives `null`. Either way, `payload.role` throws a TypeError, which means a 500 on every request (or a crashed process if nothing catches it). → Check that the header starts with `Bearer `, take the token after it, return 401 if the header is missing or malformed, and use guard clauses before reading claims.
2. **Role trusted from the token alone** (snippet:2) — Even with a verified token, a demoted or disabled admin stays admin until the token expires. → Keep admin tokens short-lived, or look up the user's current role on the server using `sub`.
3. **No tests for the auth path** — → Add tests for a valid admin token (granted), a non-admin token (not granted), a forged or `alg:none` token (401), an expired token (401), and a missing or malformed header (401, no crash).

### 🟢 Consider
1. **Auth logic inline in the handler** (snippet:1–2) — → Move it into one shared `requireRole('admin')` middleware so every route uses the same verified check.

### ✅ Good
- The role check uses strict `===` against a fixed string, so there's no type-coercion trick.
- It fails closed for non-admins: `grantAdmin()` only runs when the role matches.