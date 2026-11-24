The endpoint takes about 50 lines across 4 files. Four tests (201 / 400 / 409 / 409 when two requests race) go in first and fail. After that I'd run the full suite, lint, typecheck, build and a real curl. This is a dry run, so I didn't run any of it.

**Assumed stack (I can't see the repo):** Express + TypeScript, Postgres through `pg` with the existing `src/db.ts` pool, Jest + supertest, and an existing `users` table with `id uuid` and `email text`. If the code differs, I'd follow the repo's own patterns instead. Auth: I assume this is signup and stays public. If it's admin-only, I'd add the existing auth middleware.

## Steps, in order

**1. TodoWrite:** Understand · Plan slice · TDD loop · DRY/YAGNI/KISS · Run it. Notes go in `./.claude-skills-work/software-development/post-api-users/notes.md`.

**2. Understand.** Input is `{email, name}` as JSON. A valid request returns `201 {id}`. An invalid email or a missing or empty name returns `400`. An email that already exists returns `409`. Assumptions:
- Emails are compared case-insensitively, so I trim and lowercase them before storing.
- `name` is required, gets trimmed, and has a maximum of 200 characters.
- Email validation is a simple pragmatic check (KISS) with a maximum of 254 characters.

**3. Plan the slice.**
- **Contract:** 201 `{id}`, 400 `{error}`, 409 `{error}`.
- **Validation** happens at the boundary in `src/users/validate.ts`.
- **Handler:** a thin handler in `src/users/routes.ts`.
- **Data:** `src/users/repo.ts` does a parameterized `INSERT ... RETURNING id`.
- **Duplicates:** a migration adds a unique index on `lower(email)`. The repo maps Postgres error `23505` to a conflict, so two requests racing can't both create the user.
- **Logging:** nothing logs the email or name.

**4. Red: write the tests first.** `test/users.post.test.ts` runs against the test DB, which is truncated before each test:

```ts
import request from "supertest";
import { app } from "../src/app";
import { db } from "../src/db";

beforeEach(() => db.query("TRUNCATE users"));
const post = (body: unknown) => request(app).post("/api/users").send(body);

test("returns 201 with the new id and stores the user", async () => {
  const res = await post({ email: "Ana@Example.com ", name: "Ana" });
  expect(res.status).toBe(201);
  expect(res.body.id).toEqual(expect.any(String));
  const { rows } = await db.query("SELECT email, name FROM users WHERE id=$1", [res.body.id]);
  expect(rows[0]).toEqual({ email: "ana@example.com", name: "Ana" });
});

test.each([
  ["missing email", { name: "A" }],
  ["no @", { email: "a.example.com", name: "A" }],
  ["no domain dot", { email: "a@example", name: "A" }],
  ["space inside", { email: "a b@x.com", name: "A" }],
  ["email > 254 chars", { email: "a".repeat(245) + "@x.com", name: "A" }],
  ["missing name", { email: "a@x.com" }],
  ["blank name", { email: "a@x.com", name: "   " }],
  ["name > 200 chars", { email: "a@x.com", name: "n".repeat(201) }],
  ["non-string email", { email: 42, name: "A" }],
])("returns 400 for %s and writes nothing", async (_, body) => {
  const res = await post(body);
  expect(res.status).toBe(400);
  expect((await db.query("SELECT count(*)::int c FROM users")).rows[0].c).toBe(0);
});

test("accepts name at exactly 200 chars and unicode", async () => {
  expect((await post({ email: "b@x.com", name: "José " + "n".repeat(195) })).status).toBe(201);
});

test("returns 409 when the email already exists (case-insensitive)", async () => {
  await post({ email: "a@x.com", name: "A" });
  const res = await post({ email: "A@X.com", name: "B" });
  expect(res.status).toBe(409);
});

test("only one of two concurrent duplicates succeeds", async () => {
  const codes = (await Promise.all([1, 2].map(() => post({ email: "c@x.com", name: "C" })))).map(r => r.status);
  expect(codes.sort()).toEqual([201, 409]);
});
```

Run `npx jest test/users.post.test.ts`. Every test should fail with 404 because the route doesn't exist yet, which is the right reason.

**5. Green: write the code.**

`migrations/<ts>_users_email_unique.sql`:
```sql
CREATE UNIQUE INDEX IF NOT EXISTS users_email_lower_uniq ON users (lower(email));
```

`src/users/validate.ts`:
```ts
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export type NewUser = { email: string; name: string };
export function parseNewUser(b: any): NewUser | string {
  if (typeof b?.email !== "string" || typeof b?.name !== "string") return "email and name are required strings";
  const email = b.email.trim().toLowerCase(), name = b.name.trim();
  if (email.length > 254 || !EMAIL.test(email)) return "invalid email";
  if (!name || name.length > 200) return "name must be 1-200 characters";
  return { email, name };
}
```

`src/users/repo.ts`:
```ts
import { db } from "../db";
import type { NewUser } from "./validate";
export class DuplicateEmail extends Error {}
export async function createUser(u: NewUser): Promise<string> {
  try {
    const { rows } = await db.query("INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id", [u.email, u.name]);
    return rows[0].id;
  } catch (e: any) {
    if (e.code === "23505") throw new DuplicateEmail();
    throw e;
  }
}
```

`src/users/routes.ts`, mounted in `src/app.ts` with `app.use("/api/users", usersRouter)`:
```ts
import { Router } from "express";
import { parseNewUser } from "./validate";
import { createUser, DuplicateEmail } from "./repo";
export const usersRouter = Router();
usersRouter.post("/", async (req, res, next) => {
  const parsed = parseNewUser(req.body);
  if (typeof parsed === "string") return res.status(400).json({ error: parsed });
  try { res.status(201).json({ id: await createUser(parsed) }); }
  catch (e) { e instanceof DuplicateEmail ? res.status(409).json({ error: "email already exists" }) : next(e); }
});
```

Run `npm run migrate:test && npx jest test/users.post.test.ts`. Everything should pass.

**6. Refactor, DRY/YAGNI/KISS.** There's no pre-check SELECT because the unique index is the single source of truth for duplicates. There's no validation library, no extra fields, and no "update" path. Rerun the tests.

**7. Run it.**
```
npm test && npm run lint && npm run typecheck && npm run build
npm run dev &   # then:
curl -s -i -X POST localhost:3000/api/users -H 'content-type: application/json' -d '{"email":"demo@x.com","name":"Demo"}'   # expect 201 {id}
curl -s -i -X POST localhost:3000/api/users -H 'content-type: application/json' -d '{"email":"demo@x.com","name":"Demo"}'   # expect 409
curl -s -i -X POST localhost:3000/api/users -H 'content-type: application/json' -d '{"email":"bad","name":"Demo"}'         # expect 400
kill %1
```

**8. Log** to `notes.md`: the assumptions above, files changed, the commands run and their results. I won't commit, because you didn't ask.

## Final reply (in the real session)

> `POST /api/users` creates a user from `{email, name}` and returns `201 {id}`. It rejects an invalid email or name with `400` and a duplicate email with `409`.
>
> - **Duplicates:** emails are trimmed and lowercased, so `A@X.com` and `a@x.com` count as the same user. A unique index on `lower(email)` blocks duplicates even when two requests arrive at once.
> - **Files:** `src/users/{validate,repo,routes}.ts`, `src/app.ts` (route mount), `migrations/<ts>_users_email_unique.sql`, `test/users.post.test.ts`.
> - **Checks:** I wrote the tests first and watched them fail with 404. Now the full suite, lint, typecheck and build pass. Real curls returned 201, then 409 for the same email, and 400 for `"bad"`.
> - **Assumptions:** the endpoint is public (signup), and `name` is limited to 1–200 characters. Tell me if it should require auth.
> - **Before deploying:** the migration will fail if `users` already has emails that differ only by case. Check for those first.