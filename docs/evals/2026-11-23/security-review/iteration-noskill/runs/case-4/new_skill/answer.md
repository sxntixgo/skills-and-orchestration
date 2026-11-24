## What I'd do

1. **TodoWrite:** map the attack surface → trace sources to sinks → check every class → verify controls → write the report.
2. **Assumptions:** this is an Express 4.x handler on a `GET` route. The user pasted the snippet and gave no file, so I cite it as `snippet:L1`–`L2`. No middleware runs before it: no rate limiting and no check that `API_KEY` is set. "Internal" means other services or a VPN can reach it, but I don't count network position as a security control.
3. **Attack surface:** the untrusted inputs are `req.query.apiKey` and `req.query.next`. Both are strings, or arrays or objects when qs parses repeated or bracketed keys. The secret is `process.env.API_KEY`.
4. **Sinks:** the key goes into a `===` comparison with the secret. `next` goes to `res.redirect`, which sets the `Location` header.
5. **Write** `./.claude-skills-work/security-review/internal-redirect-endpoint/findings.md` with the report below.
6. **No subagents or commands.** It's a two-line snippet with nothing on disk to run.

---

## Final reply

## Security Review: internal redirect endpoint

### 🔴 Critical
1. **Authentication: bypass when `API_KEY` is unset** (snippet:L1)
   - Exploit: if `API_KEY` isn't set in some environment (a missed deploy variable, a new container, staging), `process.env.API_KEY` is `undefined`. A request with no `apiKey` parameter also gives `undefined`, and `undefined === undefined` is `true`, so it passes.
   - Impact: anyone can use the endpoint without the key.
   - Fix: fail closed. At startup, refuse to boot if the key is missing: `if (!process.env.API_KEY) throw …`. In the handler, also require `typeof req.query.apiKey === 'string'`.

### 🟠 High
2. **Secrets: API key in the query string** (snippet:L1)
   - Exploit: the full URL, key included, gets saved in access logs, proxy and load-balancer logs, APM traces, browser history and anything that copies links around.
   - Impact: the key leaks to anyone who can read those places. It's one static shared key, so a single leak gives anyone full access.
   - Fix: send the key in a header (`Authorization: Bearer …` or `X-API-Key`). Better still, use per-caller credentials or mTLS between services. Rotate the current key, since it's probably already in logs.

3. **Open redirect** (snippet:L1)
   - Exploit: `?apiKey=<key>&next=https://evil.example/login` sends the browser to any site, and the link starts on your trusted internal host. That makes it useful for phishing or for stealing OAuth codes and tokens. Finding 2 makes the key easy to get, so the key check doesn't really limit this.
   - Impact: phishing, and tokens leaking to an attacker's site.
   - Fix: only accept same-origin relative paths. Require a string that starts with `/` but not `//` or `/\`, or parse it with `new URL(next, base)` and check that `.origin === base`. You could also use an allowlist of destinations. If validation fails, redirect to a fixed default.

### 🟡 Medium
4. **Authentication: timing-unsafe secret comparison** (snippet:L1)
   - Exploit: `===` returns as soon as a character differs. Over many requests, an attacker who can reach the endpoint can measure response times and recover the key prefix by prefix.
   - Impact: the key can be recovered.
   - Fix: hash both values with SHA-256, then compare with `crypto.timingSafeEqual`. Hashing first makes the lengths equal and avoids the function throwing.

5. **Authentication: no rate limiting or lockout** (snippet:L1)
   - Exploit: unlimited guesses at the key, which also makes the timing attack in finding 4 practical.
   - Impact: a weak key can be brute-forced.
   - Fix: rate-limit per source (for example with `express-rate-limit`), alert on repeated 403s, and use a key with at least 128 bits from a CSPRNG.

### 🟢 Low
6. **Config: unvalidated `next` type** (snippet:L1)
   - Exploit: with the key but no `next`, or with `next[]=a&next[]=b`, `res.redirect` gets `undefined` or an array. Depending on the version, that produces a broken `Location` header or a 500 error.
   - Impact: error noise, and a stack trace if prod runs with debug on.
   - Fix: check that `next` is a string, as part of the fix for finding 3.

7. **Authorization: one shared static key** (snippet:L1)
   - Impact: you can't tell callers apart, can't revoke one caller, and the audit trail can't show who called.
   - Fix: give each caller its own credential, or authenticate service-to-service with mTLS or signed tokens.

**Not applicable here:** injection, SSRF, deserialization, path traversal, XSS (nothing goes into HTML), data/crypto, and CSRF (a GET that changes no state).

### ✅ Controls verified
- A wrong key fails closed with an empty `403`, so the response leaks no details.
- Express 4's `res.redirect` passes the URL through `encodeurl`, so CRLF characters in `next` can't inject headers. This assumes Express ≥4; check your version.

### Suggested shape
```js
const KEY = process.env.API_KEY;
if (!KEY) throw new Error('API_KEY not set');
const h = s => crypto.createHash('sha256').update(s).digest();

app.get('/internal/go', rateLimit, (req, res) => {
  const k = req.get('x-api-key');
  if (typeof k !== 'string' || !crypto.timingSafeEqual(h(k), h(KEY))) return res.status(403).end();
  const next = req.query.next;
  const safe = typeof next === 'string' && /^\/(?![\/\\])/.test(next) ? next : '/';
  return res.redirect(safe);
});
```

Findings are saved to `.claude-skills-work/security-review/internal-redirect-endpoint/findings.md`.