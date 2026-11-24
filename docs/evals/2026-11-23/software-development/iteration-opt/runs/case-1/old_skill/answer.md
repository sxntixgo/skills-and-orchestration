I'm going ahead without asking first. The request is specific enough, and the remaining details can follow the codebase's existing conventions. Those choices are listed below so you can override them.

**Assumptions (stack and repo state):** Node/TypeScript with Express, Postgres through the existing `db` module, and Jest with supertest. Routes live in `src/routes/`, services in `src/services/`, and tests in `test/`. There's already a `users` table with `id`, `email`, `name` and `created_at`. Other `/api/*` routes share an auth middleware and an error format of `{ error: { code, message } }`.

## Steps, in order

**1. TodoWrite:** one item for each stage: Understand, Plan, TDD, Refactor, Verify.

**2. Stage 1: Understand.** I'd write this to `./.claude-skills-work/software-development/post-api-users/plan.md`:
```md
# POST /api/users
Input: JSON {email, name}. Output: 201 {id}.
Done = valid request creates a row and returns 201 + id; duplicate email → 409;
invalid/missing email → 400; nothing written on rejection.
Decisions (codebase conventions, not invented requirements):
- Duplicate = same email, case-insensitive (normalize: trim + lowercase before store/compare).
- 400 for validation (matches existing error middleware), 409 for conflict.
- name: required non-empty string (trimmed); no other rules (YAGNI).
- Email check: pragmatic regex/validator already in deps, not full RFC 5322.
- Auth: same middleware as sibling /api routes; no new auth model.
- Race on duplicates: rely on UNIQUE index on lower(email); map 23505 → 409.
Out of scope: password, roles, email verification, GET/PUT.
```

**3. Stage 2: Plan.** I'd read `references/backend.md` (done) and add this to `plan.md`:
- Contract: `POST /api/users` with body `{email: string, name: string}`. It returns `201 {id}`, `400 {error}` or `409 {error}`.
- Files to touch:
  - `src/routes/users.ts`: the handler. It only parses input and maps errors.
  - `src/services/users.ts`: `createUser({email, name})`, which validates, normalizes and inserts with a parameterized query.
  - Mount the route in `src/app.ts`.
  - Add a migration `NNNN_users_email_unique.sql` only if no unique index on `lower(email)` exists yet. It must be reversible.
- Security points to test: the input size limit (the existing `express.json` limit), a parameterized SQL query, and no PII in logs (log the user id only).

**4. Stage 3: TDD loop.** I'd invoke the `writing-tests` skill with the backend list: the happy path, validation failures, conflict, and boundary cases. Expected cases in `test/users.post.test.ts`:
1. A valid body returns 201 with a numeric or uuid `id`, and the row exists.
2. A duplicate email returns 409, including when only the case differs (`A@x.com` vs `a@x.com`).
3. A missing, empty or malformed email (`"foo"`, `"a@"`) returns 400 and writes no row.
4. A missing or blank name returns 400.
5. A non-JSON or non-object body returns 400.
6. An unauthenticated request returns 401, if the sibling routes require auth.

For each case: write the test, run `npm test -- users.post`, and confirm it fails for the right reason (404 before the route exists, then the wrong status). Then write the simplest code that passes and rerun. Order: 1 → 3 → 4 → 2 → 5 → 6. After each green, I'd add a line to `progress.md`.

The core of the service, roughly:
```ts
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export async function createUser(input: unknown) {
  const { email, name } = (input ?? {}) as Record<string, unknown>;
  if (typeof email !== 'string' || !EMAIL.test(email.trim()))
    throw new ValidationError('invalid email');
  if (typeof name !== 'string' || !name.trim())
    throw new ValidationError('name required');
  try {
    const { rows } = await db.query(
      'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id',
      [email.trim().toLowerCase(), name.trim()]);
    return rows[0].id;
  } catch (e: any) {
    if (e.code === '23505') throw new ConflictError('email already exists');
    throw e;
  }
}
```
The route just calls `res.status(201).json({ id: await createUser(req.body) })`. The existing error middleware maps `ValidationError` to 400 and `ConflictError` to 409. If those error classes already exist, I'd reuse them.

**5. Stage 4: Refactor.** If the codebase already has a shared email validator, I'd use it instead of the regex (DRY). There's no pre-check SELECT for duplicates, because the unique index handles both the normal case and the race (KISS). I'd remove anything not needed. Rerun the tests and log the decisions to `decisions.md`.

**6. Stage 5: Verify.** I'd run the full suite (`npm test`) and lint/typecheck, then start the dev server and send real requests:
```sh
npm run dev &
curl -si -XPOST localhost:3000/api/users -H 'content-type: application/json' -d '{"email":"a@x.com","name":"A"}'   # expect 201 {"id":...}
curl -si -XPOST ... -d '{"email":"A@x.com","name":"B"}'   # expect 409
curl -si -XPOST ... -d '{"email":"nope","name":"A"}'      # expect 400
```
I'd add the observed status lines to `progress.md`, then stop the server.

## Final reply to the user

> `POST /api/users` is in place: `{email, name}` → `201 {id}`; invalid/missing email or blank name → `400`; duplicate email (case-insensitive) → `409`, enforced by a unique index on `lower(email)` so concurrent duplicates also get 409. Six new tests in `test/users.post.test.ts` were written first and all pass; the full suite passes; curl against the dev server returned 201 / 409 / 400 as expected. Choices I made that you may want to change: emails are stored lowercased, validation uses a simple pattern rather than full RFC rules, and the route uses the same auth middleware as the other `/api` routes.