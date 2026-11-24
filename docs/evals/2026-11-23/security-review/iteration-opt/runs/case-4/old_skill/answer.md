**What I'd do, in order**

1. **TodoWrite** with these items: map attack surface → trace source→sink → check vuln classes (`references/vuln-classes.md`) → verify controls → report.
2. **Assumptions:** the code is Express (`req.query`, `res.redirect`) using the default query parser. The snippet has no file path, so locations are given as `snippet:1` (the `if`/redirect line) and `snippet:2` (the 403 line). "Internal" is a deployment claim I can't check here, so I treat the route as reachable by anyone who can send it a request.
3. **Attack surface:** `req.query.apiKey` (the credential) and `req.query.next` (the redirect target). Both are attacker-controlled and both arrive in the URL.
4. **Source→sink:** `req.query.next` goes into `res.redirect()` with no checks. `req.query.apiKey` goes into a `===` comparison with `process.env.API_KEY`.
5. **Checkpoint:** I'd write `./.claude-skills-work/security-review/internal-redirect-endpoint/findings.md` as I go. Its content is the report below.
6. **Final reply:**

---

## Security Review: internal redirect endpoint

### 🔴 Critical
1. **Broken authentication: fails open when `API_KEY` is unset or empty** (snippet:1)
   - Exploit: if `API_KEY` is missing in any environment (staging, a new deploy, a bad secret mount), a request with no `apiKey` param compares `undefined === undefined`, which is `true`. If `API_KEY=""`, sending `?apiKey=` passes too. Either way the check is skipped.
   - Impact: anyone can use the endpoint without a key. It also silently disables the only control that limits finding 2.
   - Fix: at startup, refuse to boot if `API_KEY` is missing or too short (e.g. under 32 bytes of entropy). In the handler, reject any `apiKey` that is not a non-empty string before comparing.

### 🟠 High
2. **Open redirect** (snippet:1)
   - Exploit: `next` goes straight to `res.redirect`, so `?apiKey=…&next=https://evil.example/login` sends the user to any site. Anyone who has the key can do this, and so can anyone who learns it from logs (see 3). It is unauthenticated if finding 1 applies.
   - Impact: phishing that starts from a trusted internal domain, and bypass of URL allowlists that trust your domain (e.g. OAuth `redirect_uri` checks). If server-side callers follow redirects automatically, a crafted `next` can also point them at internal hosts or cloud metadata (SSRF through the redirect).
   - Fix: accept only relative paths. Require `next` to be a string starting with a single `/`, and reject `//`, `/\`, and any scheme. Or map `next` to an allowlist of known destinations. Fall back to a fixed default when it doesn't match.
3. **Secret sent in the query string** (snippet:1)
   - Exploit: `?apiKey=` ends up in access logs, reverse-proxy and load-balancer logs, APM traces, browser history, and shared links. Anyone who can read those can reuse the key.
   - Impact: the key leaks, and it is the only auth on this route, so it gives full access to the endpoint.
   - Fix: send the key in a header (`Authorization: Bearer …`) or use mTLS or service identity. Redact it from logs. Treat the current key as exposed and rotate it.

### 🟡 Medium
4. **Single shared static key with no per-caller identity** (snippet:1)
   - Exploit: every caller uses the same key. A leak from any one of them compromises all of them, and nothing shows which caller did what.
   - Impact: no attribution or audit trail, and revoking one caller's access means rotating the key for everyone.
   - Fix: give each caller its own scoped credential (service tokens or mTLS identity), and log the authenticated caller on every request.

### 🟢 Low
5. **Key compared in non-constant time** (snippet:1)
   - Exploit: `===` returns as soon as a character differs. In theory the response time reveals the key one byte at a time. Over a network this is hard to exploit but possible.
   - Fix: hash both values (e.g. SHA-256) and compare the digests with `crypto.timingSafeEqual`. Hashing makes them equal length.
6. **No rate limiting on the key check** (snippet:1–2)
   - Exploit: nothing stops repeated guesses against the key. This only matters if the key is short or guessable.
   - Fix: rate-limit failed attempts per source and alert on spikes of 403s.
7. **Malformed `next` crashes or misroutes** (snippet:1)
   - Exploit: `?next=a&next=b` turns `next` into an array, and a missing `next` redirects to the literal path `undefined`. Both can cause errors (500s) or odd behaviour.
   - Fix: the string and path validation in finding 2 also fixes this.

### ✅ Controls verified
- The secret comes from an environment variable and is not hardcoded in the source.
- A failed check returns a bare 403 with an empty body, so nothing leaks in the response.
- The server makes no outbound request with user input, so there is no direct SSRF. The SSRF risk exists only through clients that follow the redirect (see finding 2).
- An array or object `apiKey` can never `===` a string key, so query-parser type confusion doesn't bypass the check. It only fails open in the undefined/empty case in finding 1.

**Not verified:** that the route really can't be reached from outside. Please confirm what network controls restrict it. Fix findings 1–3 first; finding 1 alone turns the route into an unauthenticated open redirect.