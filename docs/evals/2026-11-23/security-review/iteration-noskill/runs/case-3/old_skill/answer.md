**Critical: mass assignment.** `req.body` goes straight into `User.update`, so any logged-in user can set their own `role` and `isVerified`:

```
PUT /profile  {"role":"admin","isVerified":true}
```

That's privilege escalation to admin plus a bypass of verification.

**Other issues**

1. **Email changes skip verification.** A user can switch to an address they don't own, and `isVerified` stays true. If email is used for login or password reset, this can also let them take over that address's identity. Changing the email should reset `isVerified` and send a confirmation, or go through its own flow.
2. **No input validation.** There are no type, length or format checks. For example, `bio` could be a 10 MB string or an object, and `email` could be malformed. If `bio` is rendered as HTML anywhere, it's a stored XSS vector unless it's escaped on output.
3. **Extra keys reach the data layer.** Depending on the ORM, fields like `id`, `password`, `createdAt` or operator keys such as `$set` may also pass through.
4. **Errors are ignored.** If `User.update` is async, the promise isn't awaited. The handler always returns `{ok:true}`, even when the update fails, and a rejection becomes an unhandled promise rejection.

**Fix**

```js
const { z } = require('zod');

const ProfileUpdate = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  bio:  z.string().max(1000).optional(),
  email: z.string().email().max(254).optional(),
}).strict(); // rejects role, isVerified, and any unknown key

app.put('/profile', requireLogin, async (req, res, next) => {
  const parsed = ProfileUpdate.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const updates = parsed.data;
  try {
    if (updates.email && updates.email !== req.user.email) {
      updates.isVerified = false;              // server-controlled
      await sendVerificationEmail(req.user.id, updates.email);
    }
    await User.update(req.user.id, updates);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});
```

The fix uses an allowlist, so only `name`, `bio` and `email` can come from the client. The server sets `role` and `isVerified`, and `role` should only change through an admin-only endpoint. As a second layer, consider enforcing the allowlist in `User.update` or the model too, so other routes can't reintroduce this bug.