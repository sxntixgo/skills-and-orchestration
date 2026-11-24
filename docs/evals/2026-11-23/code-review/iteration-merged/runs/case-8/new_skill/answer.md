## Code Review: internal endpoint (pasted snippet)

The endpoint has two must-fix holes. If `API_KEY` is unset, anyone passes the auth check. Anyone who passes it can redirect to any site.

**Assumptions:** this is Express 4 with the default `qs` query parser. I had no surrounding code, so I couldn't check callers, how the route is mounted, rate-limit middleware or tests. Line references are to the snippet: L1 is the `if`, L2 is the 403.

**What I'd do in the session:**
- Add TodoWrite items for Context, Dimensions, Rate and Report.
- Write the findings to `./.claude-skills-work/code-review/internal-endpoint/findings.md`, containing the report below.
- Spawn no subagents and run no commands.

### 🔴 Must fix
1. **Auth bypass when the key is unconfigured** (snippet:L1)
   - **Exploit:** a deploy has no `API_KEY` set (missing `.env`, new environment, typo in the variable name). A request with no `apiKey` parameter then compares `undefined === undefined`, which is `true`.
   - **Impact:** the check passes for unauthenticated callers.
   - **Fix:** at startup, fail if `API_KEY` is missing or empty. In the handler, reject unless `typeof req.query.apiKey === 'string'` and the key is non-empty.
2. **Open redirect** (snippet:L1)
   - **Exploit:** `next` goes to `res.redirect` without any check. Anyone with the key can send a link like `…?apiKey=K&next=https://evil.example/login`. With finding 1, nobody needs the key. The user lands on a lookalike page served from a trusted internal URL, and the attacker harvests their SSO credentials.
   - **Impact:** phishing and credential theft that looks like it comes from your own domain.
   - **Fix:** only allow relative paths (starts with `/`, not `//` or `/\`), or match `new URL(next, base).origin` against an allowlist. Anything else falls back to a fixed default.

### 🟡 Should fix
3. **Secret sent in the query string** (snippet:L1)
   - **Exploit:** `?apiKey=` ends up in access logs, proxy and CDN logs, APM traces and browser history. Anyone who can read those gets the key.
   - **Impact:** the key leaks and has to be rotated.
   - **Fix:** send it in a header (`Authorization: Bearer …` or `X-API-Key`) and redact that header in logs.
4. **Key compared without constant time** (snippet:L1)
   - **Exploit:** `===` stops at the first differing character. In principle an attacker can recover the key from response timing.
   - **Impact:** the key can be recovered, though network jitter makes this slow.
   - **Fix:** use `crypto.timingSafeEqual` on two Buffers of equal length, checking the lengths first.
5. **No rate limit on key guesses** (snippet:L1–2)
   - **Exploit:** the endpoint answers unlimited guesses.
   - **Impact:** brute force is possible if the key has low entropy.
   - **Fix:** add rate-limit middleware (e.g. `express-rate-limit`) and log failed attempts with the IP, not the submitted value.
6. **`next` that is missing or not a string** (snippet:L1)
   - **Problem:** an absent `next` passes `undefined` to `res.redirect`, which redirects to `undefined` or throws, depending on the Express version. `?next=a&next=b` makes it an array.
   - **Fix:** require `typeof next === 'string'`. Otherwise redirect to a default or return 400. This check can live in the same validator as the fix for finding 2.

### 🟢 Consider
7. **"Internal" isn't enforced in code** (snippet:L1)
   - **Problem:** if the route is reachable from outside, the API key is its only protection.
   - **Fix:** confirm it's bound to an internal interface or behind network ACLs or mTLS, or add a middleware that checks the source.
8. **Tests** (snippet:L1–2)
   - **Fix:** cover a valid key with a relative `next` (302), a wrong key (403), a missing key with `API_KEY` unset (must be 403), an absolute or `//evil` `next` (rejected), and an array or missing `next`.

### ✅ Good
- It fails closed: anything other than a match gets a bare 403 with no body, so it doesn't reveal why.
- The guard-clause shape is flat and easy to read.