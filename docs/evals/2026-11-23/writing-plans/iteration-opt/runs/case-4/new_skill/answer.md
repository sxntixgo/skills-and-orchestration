Plan written to `docs/plans/2026-11-23-login-rate-limit-plan.md`; the next step is handing it to `software-development`. I didn't run any commands or open any files (dry run), so every file name and the stack below are assumptions.

**Steps, in order**
1. TodoWrite: Ground → Phases → Tasks → Gates/risks → Write plan.
2. Read the code (assumed Node/Express + TypeScript, Redis already used for sessions): `src/routes/auth.ts` (POST /login handler), `src/app.ts` (middleware order, `trust proxy`), `src/config.ts`, `src/lib/redis.ts`, `test/auth.test.ts`. There's no spec, but the core behaviour is clear enough to plan without asking.
3. Goal: limit POST /login attempts per IP and per account, and return 429 with `Retry-After` when over the limit. Success: the 6th failed attempt for the same account within 15 minutes returns 429, and normal logins are unaffected.
4. Write the plan file:

```markdown
# Login rate limiting plan
Goal: throttle brute-force/credential-stuffing on POST /login · Success: over-limit requests get 429 + Retry-After; normal logins unaffected · Context: `src/routes/auth.ts`, `src/app.ts`, `src/lib/redis.ts`, `src/config.ts`

### Phase 1 — Per-IP limit, in-memory
- [ ] Add `src/middleware/rateLimit.ts` (fixed window, key = `req.ip`, limits from config) — Verify: unit test that the 21st request in a window returns 429 with a `Retry-After` header
- [ ] Mount it only on POST /login in `src/routes/auth.ts` — Verify: `test/auth.test.ts` hits /login 21× → 429; GET /health stays unaffected
- [ ] Add `LOGIN_RATE_LIMIT_*` settings to `src/config.ts` — Verify: a test overrides the limit to 2, and the 3rd request gets 429
Gate: tests green; check that `app.set('trust proxy', …)` matches the deployment so `req.ip` is the client IP and not the load balancer's

### Phase 2 — Per-account limit on failed attempts
- [ ] In `src/routes/auth.ts`, count failures keyed by the normalized username (lowercased, trimmed); reset the count on success — Verify: 5 bad passwords → 6th attempt gets 429 even with the correct password; a success before the limit resets the count
- [ ] Return the same 429 body whether or not the account exists — Verify: a test compares responses for an existing and a nonexistent user
Gate: tests green; review the lockout numbers against the risk of attackers locking out real users

### Phase 3 — Shared store (Redis)
- [ ] Back the counters with Redis (`INCR` + `EXPIRE`, atomic via MULTI/Lua) in `src/lib/redis.ts` — Verify: integration test with 2 app instances sharing one Redis; the limit applies across both
- [ ] Fail open if Redis is down, and log a warning — Verify: test with Redis stubbed to throw → login still works and the warning is logged
Gate: staging deploy; watch the 429 rate and login success rate for 24h before production

## Risks
- Shared IPs (NAT, corporate networks) get false positives → keep the per-IP limit generous; the per-account limit does the tight work
- Attacker locks a real user out → short window (15 min), no permanent lockout
- Wrong client IP behind a proxy → Phase 1 gate checks `trust proxy`
- Race conditions on counters → atomic Redis operations
- Redis outage → fail open (availability chosen over strictness; confirm)
## Assumptions
Express/TS app; Redis available; limits of 20/IP and 5 failures/account per 15 min; no existing limiter
## Out of scope (YAGNI)
CAPTCHA, rate limits on other endpoints, admin unlock UI, alerting dashboards (the middleware takes a key function and limits, so other routes can reuse it later)
## Open questions
Exact limits? Fail open or closed when Redis is down? Is there a WAF/CDN limit already?
```

5. Hand the plan to `software-development`. No subagents needed.

**Reply to you:**

The plan is in `docs/plans/2026-11-23-login-rate-limit-plan.md`, in three phases:
1. **Per-IP limit, in memory:** returns 429 with `Retry-After` when the limit is hit.
2. **Per-account limit on failed logins:** the count resets on a successful login, and the 429 response is the same whether or not the account exists.
3. **Shared Redis store:** counters work across app instances, and logins keep working if Redis is down.

There's a gate after each phase. I need three decisions before building:
- What limits should we use? The plan assumes 20 requests per IP and 5 failed attempts per account, both per 15 minutes.
- If Redis goes down, should logins still be allowed (fail open) or blocked (fail closed)?
- Is there already a rate limit at the WAF or CDN level?