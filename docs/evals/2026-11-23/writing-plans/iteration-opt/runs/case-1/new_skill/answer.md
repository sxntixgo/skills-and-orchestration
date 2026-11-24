I'd plan this right away rather than ask questions first: the core behaviour (request a link, follow a tokenized link, set a new password) is clear. I've written the open details into the plan as assumptions and questions.

**What I would do, in order:**

1. **TodoWrite:** Ground it → Phases → Tasks → Gates/risks/scope → Write plan → Hand off.
2. **Read the code it touches.** Nothing exists on disk, so I'm assuming a typical Node/Express + Prisma + Postgres app. I'd read:
   - `src/routes/auth.ts`, for the login and signup handlers.
   - `src/services/user.ts`, for password hashing, which I'm assuming is bcrypt.
   - `prisma/schema.prisma`, for the `User` model.
   - `src/lib/mailer.ts`, assuming an email helper exists, for example one used for signup verification.
   - `src/middleware/rateLimit.ts`, if it exists.
   - `tests/auth.test.ts`, to see the test patterns (assuming supertest + jest).
3. **Write `docs/plans/2026-11-23-password-reset-plan.md`** one section at a time, so the file is the checkpoint:

```markdown
# Password reset via email plan
Goal: a user who forgot their password can request a reset email, follow a single-use expiring link, and set a new password.
Success: requesting a reset sends one email; the link works once and only before it expires; after the reset the old password fails and the new one logs in.
Context: spec from the user (chat); `src/routes/auth.ts`, `src/services/user.ts`, `prisma/schema.prisma`, `src/lib/mailer.ts`; hashing with bcrypt.

### Phase 1 — Token model + service (no HTTP, no email)
- [ ] Add a `PasswordResetToken` model (id, userId, tokenHash, expiresAt, usedAt, createdAt) in `prisma/schema.prisma` plus a migration — Verify: `prisma migrate dev` on a fresh DB; the table exists
- [ ] `createResetToken(userId)` in `src/services/passwordReset.ts`: 32 random bytes, store the SHA-256 hash, 30-min expiry, return the raw token — Verify: unit test; only the hash is stored and expiresAt ≈ now+30m
- [ ] `consumeResetToken(raw, newPassword)`: look up by hash; reject if expired or used; hash the password, set usedAt and invalidate the user's other tokens in one transaction — Verify: unit tests for valid, expired, reused and unknown tokens
Gate: unit tests green; migration reviewed (additive only) before it runs on any shared DB.

### Phase 2 — Request endpoint + email
- [ ] `POST /auth/password-reset` {email} in `src/routes/auth.ts`: always returns 202, sends the email only if the user exists — Verify: tests for known and unknown email; both give 202 with the same body, and the mailer is called once and zero times
- [ ] Reset email template in `src/lib/mailer.ts` with `${APP_URL}/reset-password?token=…` — Verify: the test captures the mail and asserts the link contains the token
- [ ] Rate limit: 5/hour per IP and 3/hour per email — Verify: the 4th request for the same email in a test is throttled
Gate: run it manually against a dev SMTP server (Mailpit); the email arrives with a working link. This sends outward-facing email, so confirm sender, domain and copy before enabling outside dev.

### Phase 3 — Confirm endpoint + UI
- [ ] `POST /auth/password-reset/confirm` {token, password}: apply the existing password policy, call consumeResetToken, return 200 or 400 with a generic error — Verify: tests for valid, expired, reused and weak-password cases
- [ ] Revoke the user's existing sessions on success, in `src/services/session.ts` — Verify: test; an old session cookie gets 401 after the reset
- [ ] Pages: "Forgot password" form and `/reset-password` form — Verify: e2e request → follow the link in Mailpit → set password → log in with the new one; the old password fails
Gate: full auth test suite + e2e green; security review of the token handling before merge.

## Risks
- Account enumeration → same response and similar timing for known/unknown emails.
- Token leak (logs, Referer) → store only hashes, don't log tokens, set `Referrer-Policy: no-referrer` on the reset page.
- Brute force / email bombing → rate limits, 256-bit tokens.
- Race from double-submitting a token → conditional update `WHERE usedAt IS NULL` inside the transaction.
- Stolen sessions survive a reset → revoke sessions.

## Assumptions
Node/Express + Prisma + Postgres; a mailer with SMTP already exists; sessions are server-side and revocable; 30-min expiry; a password policy already exists.

## Out of scope (YAGNI)
SMS/2FA reset, magic-link login, admin-initiated resets, "your password was changed" notification email (the design leaves room: a hook after consumeResetToken), localisation of the emails.

## Open questions
- Token expiry: is 30 min OK?
- Should a successful reset log the user in automatically, or send them to the login page?
- Revoke all sessions, or all except the current one?
- Which sender address/domain should the reset emails use?
```

4. **Log:** mark each TodoWrite item done as it's finished. Then hand off to `software-development`, starting with Phase 1.

**Final reply to the user:**

> The plan is in `docs/plans/2026-11-23-password-reset-plan.md`. It has three phases:
> 1. A token model and service, with hashed, single-use, 30-minute tokens.
> 2. A request endpoint that sends the email, with rate limiting and responses that don't reveal whether an account exists.
> 3. A confirm endpoint that also logs out existing sessions, plus the two pages.
>
> Each phase ends with a check: the migration is reviewed before it runs, the email is tested on a dev mail server before real emails go out, and the token handling gets a security review before merge.
>
> I assumed a Node/Express + Prisma app with an existing mailer. Four questions are still open:
> - Is a 30-minute expiry OK?
> - Should a reset log the user in automatically?
> - Should it log out all sessions, or keep the current one?
> - Which sender address should the emails use?
>
> Once you confirm, I'll start on Phase 1.