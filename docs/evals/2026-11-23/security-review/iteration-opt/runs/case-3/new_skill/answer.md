**Steps I'd take**

1. TodoWrite: map attack surface → trace sources to sinks → check every class → verify controls → report.
2. Attack surface: `req.body` is fully attacker-controlled. `req.user.id` comes from the session via `requireLogin`. The sink is `User.update`. The stored `bio`, `name` and `email` values are later read back and rendered or used elsewhere.
3. Assumptions: Express with a JSON body parser. `requireLogin` uses a session cookie and sets `req.user`. `User.update(id, obj)` writes every key in `obj` to the record, in the style of a Mongoose or Sequelize wrapper. The snippet has no file path, so I cite it as `profile handler:1`.
4. Write the report below to `./.claude-skills-work/security-review/profile-handler/findings.md`.

**Final reply:**

## Security Review: `PUT /profile` handler

### 🔴 Critical
1. **Authorization: mass assignment of `role`** (profile handler:1)
   - Exploit: a logged-in user sends `PUT /profile {"role":"admin"}`. The whole body goes straight into `User.update`.
   - Impact: any account can make itself an admin, which means full privilege escalation.
   - Fix: allowlist the writable fields, for example `const { name, bio, email } = req.body; User.update(req.user.id, { name, bio, email })`. Change `role` only through a separate admin-only endpoint with its own authorization check.

2. **Authorization: mass assignment of `isVerified`** (profile handler:1)
   - Exploit: `PUT /profile {"isVerified":true}` skips the verification flow, or the attacker sets a new email and `isVerified:true` in one request.
   - Impact: the user gets the trust of a verified account without proving it, and can claim someone else's email as verified.
   - Fix: leave `isVerified` out of the allowlist. Only the server sets it, in the verification callback.

### 🟠 High
3. **Authentication / account integrity: email changes with no re-verification** (profile handler:1)
   - Exploit: the user changes `email` to an address they don't own, or to one that collides with another account if uniqueness isn't enforced. If the change is CSRF-able or the session is hijacked, the attacker sets their own email and then runs password reset.
   - Impact: account takeover, and email-based trust gets attached to the wrong person.
   - Fix: require the current password or a recent re-auth to change email. Keep the new address pending until it's confirmed, then reset `isVerified`. Enforce uniqueness.

4. **Injection: NoSQL operator / unexpected keys (conditional)** (profile handler:1)
   - Exploit: if `User.update` passes the object to MongoDB as an update document, keys like `$unset`, `$rename` or nested `$set` change fields the user should never touch. Keys like `id`/`_id`/`createdAt` may also be written.
   - Impact: arbitrary field changes on the user's own record, including the ones above.
   - Fix: use the same allowlist, check each field's type (strings only), and reject any key starting with `$` or containing `.`.

### 🟡 Medium
5. **XSS: stored `name`/`bio` (second-order)** (profile handler:1)
   - Exploit: `bio: "<img src=x onerror=…>"` is stored and later rendered with `innerHTML` or an unescaped template on a profile page someone else views.
   - Impact: script runs in other users' sessions.
   - Fix: validate type and length here, encode for the context at render time, and add a CSP.

6. **CSRF: state change authorized only by the session cookie** (profile handler:1)
   - Exploit: if the body parser also accepts urlencoded or `text/plain`, or CORS is permissive with credentials, a cross-site request can change the victim's email (see 3).
   - Impact: profile tampering, which can lead to account takeover.
   - Fix: `SameSite=Lax/Strict` cookies, an anti-CSRF token or a required custom header, and accept `application/json` only.

### 🟢 Low
7. **Config / error handling** (profile handler:1)
   - Exploit: `User.update` isn't awaited, so a failure still returns `{ok:true}`. Depending on the Node setup, an unhandled rejection can also crash the process.
   - Impact: silent failures, and possible DoS through malformed input.
   - Fix: `await` the update in a try/catch, return a generic error (no stack trace), and add size limits and rate limiting on the route.

### ✅ Controls verified
- The route requires authentication (`requireLogin`).
- The target record comes from the session (`req.user.id`), not from the client, so there's no IDOR.
- Not applicable to this snippet: SSRF, deserialization, path traversal and uploads, open redirect, hardcoded secrets, crypto.

**Fix that closes findings 1, 2 and 4 and part of 5:**
```js
app.put('/profile', requireLogin, async (req, res) => {
  const { name, bio } = req.body;
  if (typeof name !== 'string' || name.length > 100 || typeof bio !== 'string' || bio.length > 2000)
    return res.status(400).json({ error: 'invalid input' });
  try { await User.update(req.user.id, { name, bio }); res.json({ ok: true }); }
  catch { res.status(500).json({ error: 'update failed' }); }
});
```
Move email changes to their own endpoint that requires re-auth and confirmation (see 3).