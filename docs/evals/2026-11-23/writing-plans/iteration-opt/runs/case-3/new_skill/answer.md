I'm planning only the core URL shortener now. Analytics, teams, custom domains and billing go under Out of scope, each with one line on how the design leaves room for it. The core behaviour is clear enough to plan without asking first.

**What I'd do, in order**

1. **TodoWrite:** Ground · Phases · Tasks · Gates/risks/scope · Write plan.
2. **Ground it.** Read `README.md`, the package manifest (`pyproject.toml` / `package.json`), and any existing `app/` or `src/`, `migrations/` and `tests/` directories.
   - **Assumed:** a greenfield Python 3.12 + FastAPI + Postgres + pytest repo with no shortener code yet. If the stack turns out to be different, the task locations change but the phases stay the same.
   - **Goal:** turn a long URL into a short code that redirects to it.
   - **Success:** `POST /links` returns a short URL, `GET /{code}` returns a 301/302 to the original, and unknown codes return 404.
3. **Write** `docs/plans/2026-11-23-url-shortener-plan.md` one section at a time:

```markdown
# URL shortener plan
Goal: shorten long URLs and redirect short codes to them · Success: POST /links → short URL; GET /{code} → 302 to target; unknown → 404; invalid URL → 422 · Context: greenfield FastAPI + Postgres (assumed); files: app/main.py, app/links/, migrations/, tests/

### Phase 1 — Create + redirect (in-memory)
- [ ] Code generator (base62, 7 chars, random) in `app/links/codes.py` — Verify: unit test makes 10k codes, all match ^[0-9A-Za-z]{7}$, no duplicates
- [ ] URL validation (http/https only, max 2048 chars) in `app/links/validate.py` — Verify: tests reject `javascript:`, `ftp:`, an empty string and an oversize URL; accept https URL
- [ ] POST /links → 201 {code, short_url}; GET /{code} → 302, 404 if unknown, in `app/links/routes.py` with an in-memory repo behind a `LinkRepo` interface in `app/links/repo.py` — Verify: API test creates a link, GETs it, asserts 302 + Location; GET /nope asserts 404
Gate: pytest green; demo create→redirect with curl. Unblocks persistence.

### Phase 2 — Postgres persistence
- [ ] Migration `migrations/001_links.sql`: links(id bigserial PK, code text UNIQUE, target_url text, created_at timestamptz) — Verify: migrate up/down on a fresh DB
- [ ] `PgLinkRepo` in `app/links/repo_pg.py`, retry on unique-code collision (max 3) — Verify: integration test forces a collision via a stubbed generator and asserts the retry succeeds; links survive app restart
Gate: review the migration before applying it to any shared DB; integration tests green.

### Phase 3 — Abuse and hardening
- [ ] Rate-limit POST /links per IP (e.g. 30/min) in `app/middleware/ratelimit.py` — Verify: test sends 31 requests and asserts the 31st returns 429
- [ ] Block self-referential/shortener-domain targets in `validate.py` — Verify: test that shortening our own short URL returns 422
- [ ] Redirect cache headers + DB index check — Verify: EXPLAIN shows index scan on code; response has Cache-Control
Gate: full suite green; manual check before exposing publicly (outward-facing).

## Risks
- Open redirect / phishing abuse → scheme allowlist, rate limit, ability to disable a link (Open questions)
- Code collisions under concurrency → UNIQUE constraint + retry
- Enumeration of links → random (non-sequential) codes
- Data loss on migration → migrations are add-only and reversible; take a backup before applying to prod

## Assumptions
FastAPI/Postgres/pytest stack; anonymous creation; 302 (not 301) so we can change or disable targets later; links never expire.

## Out of scope (YAGNI) — and how the design leaves room
- Analytics: not built; the redirect goes through one handler where a click event can be emitted later without changing the schema.
- Teams/ownership: no users; adding a nullable `owner_id` column to links later is a simple additive migration.
- Custom domains: one domain from config; `LinkRepo` lookups go through a single function that can later take (domain, code).
- Billing: none; rate limiting is a single middleware where plan-based quotas could go later.

## Open questions
- Should anyone be able to create links, or only authenticated users?
- Do users need custom aliases (vanity codes)?
- Do links need to expire or be deletable?
- 301 or 302 for redirects?
```

4. **Hand off** to `software-development`, starting with Phase 1.

---

**Reply to user:**

The plan is in `docs/plans/2026-11-23-url-shortener-plan.md` and has three phases, each with a gate:

1. **Create and redirect, in memory.**
2. **Postgres persistence.** I'll review the migration before it touches any shared database.
3. **Abuse hardening.** Includes rate limiting, plus a manual check before the service goes public.

I left analytics, teams, custom domains and billing out of the build on purpose; building them now is speculative. The design leaves room for each one without rework:
- **Analytics:** a single redirect handler that can emit click events later.
- **Teams:** an owner column can be added with a simple additive migration.
- **Custom domains:** links are looked up in one place that can later take the domain as well as the code.
- **Billing:** rate limiting is one middleware where plan-based quotas could go.

I assumed a FastAPI + Postgres stack and anonymous link creation. Four questions are open:
- Should anyone be able to create links, or only signed-in users?
- Do you want custom aliases?
- Do links expire or get deleted?
- Should redirects be 301 or 302?

Next step is to hand Phase 1 to `software-development`.