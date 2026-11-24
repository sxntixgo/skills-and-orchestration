No subagents. I'd make TodoWrite items for the five skill steps and write the report below to `./.claude-skills-work/security-review/internal-redirect-endpoint/findings.md`. There's no file, so I've numbered the pasted snippet: `snippet:1` is the `if` line and `snippet:2` is the 403 line.

**Assumptions:** this is an Express GET handler and it has no middleware in front of it (no network restriction, rate limiting or request logging hidden from me). `API_KEY` is meant to be a long random value.

## Security Review: internal redirect endpoint (snippet)

### 🔴 Critical
1. **Authentication: fails open when `API_KEY` isn't set** (snippet:1)
   - Exploit: if `API_KEY` is missing from the environment (bad deploy, new environment, renamed variable), a request with no `apiKey` parameter compares `undefined === undefined`, which is true. Anyone gets through.
   - Impact: anyone can use the redirect with no key.
   - Fix: check at startup that `API_KEY` is set and long enough, and refuse to start if not. Also make sure the incoming key is a non-empty string before comparing.

### 🟠 High
2. **Secrets: the API key travels in the URL** (snippet:1)
   - Exploit: `?apiKey=...` ends up in access logs, proxy and load-balancer logs, APM traces, browser history and shared links. Anyone who can read those has the key.
   - Impact: the shared key leaks and gets reused on every endpoint it protects.
   - Fix: send it in a header (`Authorization: Bearer …`) or use mTLS. Rotate the current key, since it's probably already in logs.

### 🟡 Medium
3. **Open redirect** (snippet:1, `res.redirect(req.query.next)`)
   - Exploit: anyone holding a key (it leaks easily, see #2), or anyone at all in case #1, can build a link on your trusted domain that sends users to an attacker's site (`?next=https://evil.example/login`). That's useful for phishing or for stealing OAuth codes or tokens.
   - Impact: phishing that borrows your domain's credibility, and possible token theft.
   - Fix: accept only relative paths on the same origin. Reject values starting with `//` or `/\`, or containing a scheme. Or map `next` to an allowlist of known destinations. Return 400 if `next` is missing or not a string; a repeated parameter turns it into an array.
4. **Authentication: secret compared with `===`, not in constant time** (snippet:1)
   - Exploit: the time `===` takes depends on the input, so an attacker can measure response times and recover the key a little at a time.
   - Impact: the key can be recovered. That's hard over a network but realistic from inside the internal network.
   - Fix: hash both values (for example SHA-256) and compare them with `crypto.timingSafeEqual`. Hashing first keeps the lengths equal and doesn't reveal the key's length.
5. **Config: no rate limit or lockout** (whole handler)
   - Exploit: unlimited key guesses, and unlimited timing samples for #4.
   - Impact: makes #4 practical, and brute force too if the key is weak.
   - Fix: rate-limit by source IP and by credential, and alert on bursts of 403s.

### 🟢 Low
6. **Authentication: one static shared key** (snippet:1)
   - Exploit: one leaked key gives full access, and you can't tell which caller used it.
   - Impact: no per-caller audit trail and no way to revoke a single caller.
   - Fix: give each caller its own credential (mTLS or signed service tokens) and rotate them. Enforce the "internal" restriction at the network layer instead of assuming it.

Not applicable here: injection, SSRF (the redirect happens in the browser, not on the server), deserialization, path traversal, XSS (Express URL-encodes `Location`), and CSRF (no cookie-based auth).

### ✅ Controls verified
- A wrong key returns 403 with an empty body, so nothing leaks through error responses.
- The comparison is strict (`===`), so loose-equality type tricks don't work. Arrays and objects from repeated parameters never match.

**Final reply to the user:** the review above, opening with: "Fix #1 and #2 first. If `API_KEY` is unset, any request with no key passes the check, and the key shows up in every log that records URLs. Rotate it."