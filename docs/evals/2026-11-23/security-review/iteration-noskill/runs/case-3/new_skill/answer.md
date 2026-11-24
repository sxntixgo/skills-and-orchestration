## Security Review: `PUT /profile` handler

The handler has a **critical privilege-escalation bug**. It passes the whole `req.body` to `User.update`, so any logged-in user can set their own `role` and `isVerified`.

The snippet has no file path, so locations are `snippet:1`. I'm assuming `requireLogin` checks a cookie session and sets `req.user`, and that `User.update` is a Mongoose/ORM-style update.

### 🔴 Critical
1. **Authorization: mass assignment** (snippet:1, `User.update(req.user.id, req.body)`)
   - Exploit: a normal user sends `PUT /profile` with `{"role":"admin","isVerified":true}`.
   - Impact: the user becomes an admin and can do anything an admin can. They can also skip verification for any feature gated on `isVerified`. Any hidden model fields can be set the same way (`passwordHash`, `_id`, timestamps).
   - Fix: only copy fields users may edit: `const { name, bio, email } = req.body; User.update(req.user.id, { name, bio, email })`. Move `role` and `isVerified` to admin-only or system-only code paths.

### 🟠 High
2. **Authentication: email changes without re-verification** (snippet:1)
   - Exploit: a user changes `email` to an address they don't own, and `isVerified` stays `true`. Someone who has taken over a session can also switch the email to their own address and then reset the password.
   - Impact: users can pose as owners of addresses they don't control, and a short-lived session hijack becomes a permanent account takeover.
   - Fix: require the current password to change the email. Store the new address as pending until a confirmation link sent to it is clicked, and notify the old address.

### 🟡 Medium
3. **Injection: NoSQL operators in the update document** (snippet:1, if the store is MongoDB)
   - Exploit: the body carries update operators such as `$unset` or `$set` on nested or hidden fields, or objects where strings are expected.
   - Impact: fields outside the allowlist can be changed or deleted, and the data can be corrupted.
   - Fix: allowlist the fields and validate them with a schema (zod or Joi): plain strings, maximum lengths, and an email format check. Reject keys that start with `$` or contain `.`.
4. **XSS: stored input** (`bio` and `name` are saved as-is)
   - Exploit: the attacker puts markup in `bio`, and it runs when another user views the profile anywhere it's rendered without escaping.
   - Impact: scripts run in the viewers' sessions.
   - Fix: encode output when rendering (auto-escaping templates, no `innerHTML`). Validate length and type on input.

### 🟢 Low
5. **CSRF** (conditional): the change is authorized by the session cookie alone. HTML forms can't send PUT, but method-override middleware or a permissive body parser would make this reachable. Fix: `SameSite=Lax/Strict` cookies plus an anti-CSRF token or a required custom header.
6. **Config: no error handling or rate limit**: `User.update` isn't awaited, so the handler returns `{ok:true}` even when the update fails. An unhandled rejection can crash the process, depending on the Node version. Fix: `await` the call inside try/catch, return a generic error, and rate-limit the route.

### ✅ Controls verified
- The endpoint requires authentication (`requireLogin`). Assumed correct; I didn't verify its implementation.
- No IDOR: the target id comes from `req.user.id`, not from anything the client sends.

Not applicable to this snippet: secrets, crypto, SSRF, deserialization, path traversal, open redirect.

This same report would go to `./.claude-skills-work/security-review/profile-put/findings.md`.