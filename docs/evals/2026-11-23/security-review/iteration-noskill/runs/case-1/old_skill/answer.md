**Critical: anyone can make themselves admin.** `jwt.decode()` only base64-decodes the token. It never checks the signature, so an attacker can write `{"role":"admin"}` into a token, sign it with anything or leave it unsigned, and get admin access.

I'm assuming this is Node's `jsonwebtoken` library. I didn't run any commands or open any files; this review covers only the snippet you pasted.

## Findings

| # | Severity | Issue |
|---|----------|-------|
| 1 | **Critical** | **No signature check.** `decode()` trusts any token. Use `jwt.verify()` with your secret or public key. |
| 2 | **High** | **Algorithm not pinned.** Without an `algorithms` allowlist, you risk algorithm-confusion attacks (RS256 tokens re-signed as HS256 with the public key) and older versions or other libraries may accept `alg: none`. |
| 3 | **High** | **Expiry, issuer and audience are never checked.** `decode()` ignores `exp`, `nbf`, `iss` and `aud`, so expired tokens and tokens issued for other services still work. `verify()` checks `exp` and `nbf` by default; you also need to pass `issuer` and `audience`. |
| 4 | Medium | **Crash on bad input.** The header is usually `Bearer <token>`. Passing it whole, a malformed token, or a missing header makes `decode()` return `null`, and then `payload.role` throws a TypeError. That gives an unhandled 500, and any user can trigger it. |
| 5 | Medium | **Role comes only from the token.** Admin rights last until the token expires even if the user is demoted or the token is revoked. For admin actions, check the role against the server-side user record, or keep token lifetimes short and add a revocation check. |
| 6 | Low | **No handling for failure.** There's no `else` branch or error path. Make sure missing or invalid tokens get an explicit 401 and that non-admins get a 403. |

## Fix

```js
const auth = req.headers.authorization || '';
const [scheme, token] = auth.split(' ');
if (scheme !== 'Bearer' || !token) return res.status(401).end();

let payload;
try {
  payload = jwt.verify(token, PUBLIC_KEY_OR_SECRET, {
    algorithms: ['RS256'],          // pin exactly what you issue
    issuer: 'https://auth.example.com',
    audience: 'my-api',
  });
} catch {
  return res.status(401).end();
}

// Prefer an authoritative check for privileged actions:
const user = await Users.findById(payload.sub);
if (user?.role !== 'admin') return res.status(403).end();
grantAdmin();
```

Also check that the signing secret is strong: at least 256 bits of randomness for HS256. Keep it out of the source code and logs.