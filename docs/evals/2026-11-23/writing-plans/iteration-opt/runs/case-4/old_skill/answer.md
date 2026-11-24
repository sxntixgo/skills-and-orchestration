**What I'd do, in order:**

1. **TodoWrite**, one item per skill step: Ground (⛔ stop if the spec is unclear) → Decompose → Detail tasks → Gates/risks/out-of-scope → Write and hand off.

2. **Ground (Step 1).** I'd read the code before planning. Assumed findings, since nothing is on disk:
   - `src/routes/auth.js`: an Express `POST /login` handler that calls `authService.login(email, password)` and returns 200 or 401.
   - `src/app.js`: the middleware chain, with no rate limiting.
   - `package.json`: Express 4, Jest and supertest, no rate-limit library. Also check for a Redis client.
   - Deployment config (Dockerfile or compose): check whether more than one app instance runs.
   - No spec or design doc exists for this feature.

3. **⛔ STOP.** The request says nothing about the limits, the key, where counts are stored, or what the client sees when blocked. Each of those changes the phases and the tests, and the skill says not to invent requirements. I would not write the plan file yet. I'd send the reply below and wait.

---

**Reply to user:**

I've read the login route and app setup. Before I write the plan I need these decisions. Each one changes its shape, so I've suggested a default for each:

1. **What's the limit, and what is it counted against?** Per IP, per account (email), or both? Suggested: 5 failed attempts per email per 15 min, plus 20 requests per IP per 15 min.
2. **Do all attempts count, or only failed ones?** Suggested: only failed ones, so a user who mistypes once and then logs in isn't penalized.
3. **Where are the counts stored?** In-process memory only works if there's a single app instance. With several instances behind a load balancer you need a shared store like Redis. How many instances run in production, and is Redis available?
4. **What does a blocked request get?** Suggested: `429` with a `Retry-After` header and the same generic error body for every case, so it doesn't reveal whether the account exists.
5. **Is the app behind a proxy or load balancer?** If so, I need to know which `X-Forwarded-For` hop to trust. Otherwise every request looks like it comes from the proxy's IP.
6. **Should anything be exempt?** For example internal IPs or health checks. Suggested: none.

Once you answer or accept the defaults, I'll write the plan to `docs/plans/2026-11-23-login-rate-limit-plan.md`. Phases would likely be:
- per-IP limit with in-memory storage, tested with supertest
- per-account limit on failed attempts
- shared store, if needed
- logging and config

Account lockout, CAPTCHA and rate limits on other endpoints would be listed as out of scope.