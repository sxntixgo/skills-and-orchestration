Spec is clear enough to plan: the three-step flow is defined. Token lifetime, session handling, and enumeration behavior aren't specified, so I'd use standard secure defaults, record them as assumptions, and list them as open questions rather than stopping.

**1. TodoWrite items**
1. Ground the plan (read the spec and relevant code)
2. Decompose into phases
3. Detail tasks with verification
4. Mark gates, risks, out-of-scope and open questions
5. Write the plan and hand off

**2. Ground the plan (read-only)**
I'd use Glob and Read to find the user model, auth routes, password hashing, any mailer, the migrations folder and the test setup.

Since I can't see the project, I'm assuming:
- Node/TypeScript with Express and Postgres, with migrations in `db/migrations/`.
- A `User` model in `src/models/user.ts` with `passwordHash`.
- Password hashing (`hashPassword`) in `src/auth/password.ts`.
- Auth routes in `src/routes/auth.ts`.
- Jest and supertest for tests.
- No mailer yet.
- Server-side sessions in a `sessions` table.

**3. Write the plan to `docs/plans/2026-11-23-password-reset-plan.md`**
I'd write it in pieces, one section at a time. Contents:

```markdown
# Password reset via email — plan

## Goal
A user who forgot their password requests a reset link by email, opens the tokenized link, and sets a new password.
Done = they can log in with the new password, the old one fails, and the link can't be used again.

## Success criteria
- `POST /auth/password-reset` returns 202 for any email. A mail is sent only if the account exists.
- `GET /reset?token=…` shows the form if the token is valid, and an "invalid or expired" page otherwise.
- `POST /auth/password-reset/confirm` with a valid token and an acceptable password returns 200.
  The token is used up, the password changes, and existing sessions are revoked.
- Expired, reused, or tampered tokens return 400.

## Context / constraints
- Spec: the user's message (request → tokenized link → set new password).
- Key files: src/models/user.ts, src/auth/password.ts, src/routes/auth.ts, db/migrations/.
- Reuse the existing hashing and password-strength rules.

### Phase 1 — Token storage and service (no HTTP, no email)
- [ ] Task: Migration for `password_reset_tokens` (id, user_id FK, token_hash, expires_at, used_at, created_at) in `db/migrations/`.
      Verify: migrate up and down on the test DB; the table exists with an index on token_hash.
- [ ] Task: `createResetToken(userId)` in `src/auth/resetTokens.ts`.
      It makes a 32-byte random token, stores only its SHA-256 hash with a 1h expiry, and returns the raw token.
      Verify: a unit test asserts the stored hash ≠ raw token and expiry ≈ now+1h.
- [ ] Task: `consumeResetToken(raw)` in the same file. It looks up by hash, rejects expired or used tokens, and sets used_at atomically (a conditional UPDATE).
      Verify: tests for valid → userId, expired → error, second use → error, unknown → error.
Gate: show the migration and passing unit tests. The user approves the schema before it lands anywhere shared.

### Phase 2 — Set new password (confirm endpoint)
- [ ] Task: `POST /auth/password-reset/confirm {token, password}` in `src/routes/auth.ts`.
      It consumes the token, validates strength, hashes with `hashPassword`, and updates the user in one transaction.
      Verify: supertest valid → 200 and login with the new password works; reused token → 400; weak password → 400 and the token is not consumed.
- [ ] Task: Revoke the user's sessions in the same transaction.
      Verify: a test where a session cookie made before the reset gets 401 afterwards.
Gate: run the full auth test suite to confirm login and signup have no regressions.

### Phase 3 — Request a link (email)
- [ ] Task: Mailer interface in `src/mail/mailer.ts`, with an SMTP/provider implementation and an in-memory fake for tests.
      Verify: a unit test with the fake captures to, subject, and body.
- [ ] Task: `POST /auth/password-reset {email}` in `src/routes/auth.ts`.
      It always returns 202. If the user exists, it creates a token and emails `${APP_URL}/reset?token=…`.
      Verify: tests for known email → 202 with one mail containing the token; unknown email → 202 and no mail.
- [ ] Task: Throttle by email and IP (e.g. 5/hour) using the existing rate limiter.
      Verify: the 6th request in a test returns 429.
Gate: send a real test email in staging. The user confirms the sender, wording, and link host.

### Phase 4 — Reset page (UI)
- [ ] Task: "Forgot password?" link on the login page and a `/reset` form page in `src/views/`.
      Verify: an e2e or manual test of the full flow from request → mail (fake inbox) → form → login with the new password.
Gate: the user walks through the flow once before merge.

## Risks
- Account enumeration → identical 202 response and timing for any email.
- Token leakage via logs or Referer → store only the hash, add `Referrer-Policy: no-referrer` on /reset, and never log the token.
- Race on double submit → a conditional UPDATE consumes the token exactly once.
- Email deliverability → the Phase 3 staging gate.

## Assumptions (change the plan if wrong)
- Stack: Express + Postgres + server-side sessions.
- No mailer exists yet.
- Token lifetime is 1h and tokens are single-use.
- Issuing a new link does not invalidate older unexpired ones. All tokens die on a successful reset.

## Out of scope (YAGNI)
- Magic-link login
- SMS or 2FA reset
- Admin-initiated resets
- A password history check
- A "your password was changed" notification email
- Localized templates

## Open questions
1. Which email provider / SMTP credentials should we use?
2. Is a 1h token lifetime OK?
3. Should a reset log out all sessions, or keep the current one?
4. Should the user be logged in automatically after a reset, or sent to the login page?
```

**4. Final message to the user**

> I've written the plan to `docs/plans/2026-11-23-password-reset-plan.md`. It has four phases, each with a gate:
> 1. Token storage
> 2. Confirm endpoint
> 3. Request endpoint and email
> 4. UI
>
> The spec didn't cover token lifetime, session handling, or enumeration, so the plan uses standard secure defaults: 1h single-use hashed tokens, all sessions revoked, and the same response for any email.
>
> Before executing I need:
> - **Email provider.** Required before Phase 3.
> - **Confirm or change two defaults:** the 1h token lifetime and revoking all sessions.
>
> After that, run the plan phase by phase with `software-development`.