**Plan (dry run):**
1. TodoWrite: Context → Check dimensions → Rate & order → Report.
2. Context: no file path was given, so I review the inline snippet as `profile.js:1` (one line). I assume Express, a cookie/session-based `requireLogin` that sets `req.user`, and that `User.update(id, fields)` returns a Promise.
3. Write the findings to `./.claude-skills-work/code-review/profile-put/findings.md`. The content is the report below.

**Reply:**

## Code Review: `PUT /profile` handler

### 🔴 Must fix
1. **Mass assignment → privilege escalation** (profile.js:1, `User.update(req.user.id, req.body)`)
   - **Exploit:** any logged-in user sends `PUT /profile {"role":"admin","isVerified":true}`. The whole body goes straight to the model.
   - **Impact:** the user becomes an admin and marks their own account as verified, so role-based authorization and email verification both stop working.
   - **Fix:** allowlist the editable fields, for example `const { name, bio } = req.body; User.update(req.user.id, { name, bio })`. Never accept `role` or `isVerified` from the client. Only admin endpoints and the verification flow should change them.
2. **The update result is ignored, so the client gets a false success** (profile.js:1)
   - **Problem:** `User.update` isn't awaited. The handler sends `{ok:true}` before the write finishes, even if it fails (validation error, duplicate email, DB down). A rejection becomes an unhandled promise rejection, and the client thinks it saved.
   - **Fix:** make the handler `async`, `await User.update(...)`, and send failures to `next(err)` or return a 4xx/5xx. Map a unique-email conflict to 409.

### 🟡 Should fix
3. **Email can change without re-verification** (profile.js:1)
   - **Exploit:** someone with a hijacked session changes the email to one they control, then uses password reset to take over the account permanently. A user could also set an email address they don't own.
   - **Impact:** persistent account takeover and identity spoofing.
   - **Fix:** take `email` out of this endpoint. Use a separate email-change flow that sends a confirmation link to the new address, sets `isVerified=false` until it's confirmed, and notifies the old address.
4. **No input validation** (profile.js:1)
   - **Problem:** there are no type or length checks. `name` can be empty or an object, and `bio` can be megabytes long. Script in `bio` gets stored and becomes XSS on any page that renders it unescaped.
   - **Fix:** validate the payload with a schema (zod/joi/express-validator): strings only, length limits, trimmed, unknown keys rejected. Make sure `bio` is escaped wherever it's rendered.
5. **CSRF** (profile.js:1)
   - **Exploit:** if `requireLogin` uses cookie sessions, a malicious site can submit a cross-site PUT that changes the victim's profile. With finding 1 still unfixed, that includes the victim's `role`.
   - **Fix:** use `SameSite=Lax` or `Strict` cookies plus a CSRF token, or check the Origin header.
6. **No tests** (profile.js:1)
   - **Fix:** add tests that check:
     - a valid `name`/`bio` update persists
     - `role` and `isVerified` in the body are ignored or rejected
     - invalid input returns 400
     - a DB failure returns 5xx, not `{ok:true}`

### 🟢 Consider
7. **PUT with partial-update semantics** (profile.js:1): the handler applies a partial body, which is PATCH behaviour. Use `PATCH`, or require the full editable set of fields.
8. **Return the updated profile instead of `{ok:true}`** (profile.js:1): return the allowlisted fields so the client can sync its state. Never include `role` or `isVerified` derived from input.

### ✅ Good
- `requireLogin` protects the route.
- The target id comes from `req.user.id`, not from a client-supplied id, so users can't update other users' records (no IDOR).