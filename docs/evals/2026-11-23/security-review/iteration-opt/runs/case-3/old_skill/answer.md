**Plan (in order):**

1. TodoWrite: map attack surface → trace data → check vuln classes → verify controls → report.
2. Create `./.claude-skills-work/security-review/put-profile/findings.md` and append each finding there as it's confirmed. It ends up holding the same content as the report below.
3. No subagents and no commands, because the whole target is the snippet in the message.

**Assumptions:** `requireLogin` checks the session properly and sets `req.user` on the server. `User.update(id, obj)` writes every key in `obj` to the record, as Sequelize/Mongoose-style updates do. Cookie-based sessions. `bio` is shown to other users somewhere.

---

## Security Review: `PUT /profile`

**Attack surface:** the whole of `req.body` (attacker-controlled, any shape) goes straight into `User.update`. The only entry check is that the caller is logged in.

### 🔴 Critical
1. **Mass assignment → privilege escalation** (`app.put('/profile', …)`, `User.update(req.user.id, req.body)`)
   - Exploit: any logged-in user sends `PUT /profile` with `{"role":"admin"}`. The handler writes `role` to the user's own record without checking it.
   - Impact: anyone with an account becomes an admin and can reach every admin-only feature and all data.
   - Fix: only allow the fields a user may edit, and derive `role` on the server only:
     ```js
     const { name, email, bio } = req.body;
     const update = {};
     if (name !== undefined) update.name = name;
     if (email !== undefined) update.email = email;
     if (bio !== undefined) update.bio = bio;
     ```
     Change roles through a separate admin-only endpoint. Add a model-level guard as well (e.g. Sequelize `fields:` option, Mongoose `strict` plus a field allowlist).

### 🟠 High
2. **Mass assignment → verification bypass** (same line)
   - Exploit: the user sends `{"isVerified":true}`, or `{"email":"ceo@victim-corp.com","isVerified":true}`.
   - Impact: email or identity verification is skipped. The attacker can claim an address they don't own, which breaks any trust or access built on verified status (domain-based org access, "verified" badges, anti-spam gates).
   - Fix: leave `isVerified` out of the allowlist. Only the verification-token flow may set it.

3. **Email change without re-verification or re-authentication** (same line)
   - Exploit: someone who briefly holds a victim's session (stolen cookie, an unattended machine, XSS) changes the email to their own and then uses "forgot password".
   - Impact: a short session compromise becomes a permanent account takeover. Uniqueness also isn't enforced here, so two accounts could share an email (or the write fails, which leads to finding 5).
   - Fix: store a new email as `pendingEmail`. Send a confirmation link to the new address and notify the old one. Require the current password or a fresh login to change it. Enforce a unique constraint.

### 🟡 Medium
4. **Unvalidated input / operator & field injection** (`req.body` passed through as-is)
   - Exploit: depending on the ORM, the body can carry fields outside the listed five (`passwordHash`, `id`/`_id`, timestamps). With Mongo-style updates it can also carry operators like `{"$unset":{…}}`. Values with the wrong type, or very long strings, reach the database unchecked.
   - Impact: corrupted or overwritten internal fields, broken invariants, storage abuse.
   - Fix: validate against a schema (zod/Joi/express-validator) with types, length limits (`bio` ≤ N chars), email format and `additionalProperties: false`, then apply the allowlisted object from finding 1.

5. **Unawaited promise → unhandled rejection crash / false success** (`User.update(...); res.json({ok:true})`)
   - Exploit: the attacker sends input that makes the DB write fail (bad type, duplicate email). On Node ≥15 an unhandled rejection kills the process by default.
   - Impact: anyone with an account can crash the server repeatedly (DoS). Failed writes are also reported as successful.
   - Fix: `await User.update(...)` inside `try/catch`, return a generic 4xx/5xx on failure, and add an async error handler.

6. **Stored XSS via `bio` / `name`** (sink is outside this snippet)
   - Exploit: `bio` is saved as raw HTML/script. If any page renders it without encoding (e.g. `dangerouslySetInnerHTML`, unescaped templates), the script runs in viewers' browsers.
   - Impact: session theft. Combined with finding 3, that means account takeover of anyone who views the profile.
   - Fix: encode output at every place these fields are rendered, sanitize if rich text is allowed, set a strict CSP. The render sites still need checking because they aren't in the snippet.

### 🟢 Low
7. **CSRF on a state-changing endpoint** (`app.put('/profile', …)`)
   - Exploit: with cookie auth, a cross-site request could change the victim's profile. HTML forms can't send `PUT`, so the attack needs permissive CORS or a body parser that accepts non-JSON content types.
   - Impact: the victim's name, bio or email gets changed. An email change is high-impact (see finding 3).
   - Fix: `SameSite=Lax/Strict` cookies, require `Content-Type: application/json` or a custom header, or use an anti-CSRF token.

8. **No rate limit** on the endpoint: it can be used to flood the database with writes and to amplify finding 5. Add per-user rate limiting.

### ✅ Controls verified
- Authentication is present (`requireLogin`) on the route.
- The target record comes from server-side `req.user.id`, not from a URL parameter or the body, so there's no IDOR on *which* user gets updated. The problem is *which fields* get written.