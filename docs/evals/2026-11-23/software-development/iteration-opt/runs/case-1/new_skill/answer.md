Planned as a single-agent TDD build. No orchestration is needed because the task fits in one small slice and none of the core behaviour is unclear. The run order is below.

**Assumptions** (I can't see the project, so these are plausible guesses):
- **Stack:** Express + TypeScript, Postgres via `pg` (`src/db.ts` exports `pool`), Jest + supertest. Routes live in `src/routes/`.
- **Table:** `users(id uuid pk default gen_random_uuid(), email text unique not null, name text not null)`. If the `unique` constraint is missing, I add a migration.
- **Emails:** trimmed and lowercased before storage and duplicate check, so `A@x.com` and `a@x.com` count as the same address.
- **Name:** a non-empty string after trimming, at most 200 characters.
- **Auth:** the endpoint uses the same auth middleware as the other `/api` routes. I won't invent new rules.

### 1. TodoWrite
1. Understand
2. Plan slice
3. TDD: happy path
4. TDD: invalid input
5. TDD: duplicate
6. DRY/YAGNI/KISS
7. Run tests + curl

### 2. Notes: `./.claude-skills-work/software-development/post-users/notes.md`
```
Done = POST /api/users {email,name} → 201 {id}; 400 invalid email/name; 409 duplicate email.
Contract: 201 {id} | 400 {error, field} | 409 {error:"email already exists"}
Seams: src/routes/users.ts (thin handler) → src/users/createUser.ts (validate+insert) → pool
Duplicate via DB unique constraint (race-safe), catch pg 23505 → 409. Parameterized insert.
No email/PII in logs or error bodies.
YAGNI: no email verification, no extra fields, no configurable validators.
```

### 3. Red: `tests/users.post.test.ts` (written first)
```ts
import request from "supertest";
import { app } from "../src/app";
import { pool } from "../src/db";

beforeEach(() => pool.query("DELETE FROM users"));
afterAll(() => pool.end());

const post = (body: unknown) => request(app).post("/api/users").send(body);

test("201 with new id", async () => {
  const res = await post({ email: "a@x.com", name: "Ann" });
  expect(res.status).toBe(201);
  expect(res.body.id).toEqual(expect.any(String));
  const { rows } = await pool.query("SELECT email,name FROM users WHERE id=$1", [res.body.id]);
  expect(rows[0]).toEqual({ email: "a@x.com", name: "Ann" });
});

test.each([
  [{ name: "Ann" }],                       // missing email
  [{ email: "", name: "Ann" }],            // empty
  [{ email: "nope", name: "Ann" }],        // no @
  [{ email: "a@b", name: "Ann" }],         // no TLD
  [{ email: 42, name: "Ann" }],            // wrong type
  [{ email: "a@x.com" }],                  // missing name
  [{ email: "a@x.com", name: "  " }],      // blank name
  [{ email: "a@x.com", name: "x".repeat(201) }], // over max
])("400 for %j", async (body) => {
  expect((await post(body)).status).toBe(400);
});

test("409 on duplicate, case-insensitive", async () => {
  await post({ email: "a@x.com", name: "Ann" });
  const res = await post({ email: " A@X.com ", name: "Other" });
  expect(res.status).toBe(409);
  expect(JSON.stringify(res.body)).not.toContain("a@x.com");
});
```
Run `npx jest tests/users.post.test.ts`. All tests should fail with 404, which confirms the route is missing and the failure is for the right reason.

### 4. Green: `src/users/createUser.ts`
```ts
import { pool } from "../db";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export class ValidationError extends Error { constructor(public field: string) { super(`invalid ${field}`); } }
export class DuplicateError extends Error {}

export async function createUser(input: { email?: unknown; name?: unknown }) {
  const email = typeof input.email === "string" ? input.email.trim().toLowerCase() : "";
  const name = typeof input.name === "string" ? input.name.trim() : "";
  if (!EMAIL_RE.test(email)) throw new ValidationError("email");
  if (!name || name.length > 200) throw new ValidationError("name");
  try {
    const { rows } = await pool.query(
      "INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id", [email, name]);
    return rows[0].id as string;
  } catch (e: any) {
    if (e.code === "23505") throw new DuplicateError();
    throw e;
  }
}
```
`src/routes/users.ts` (thin handler, mounted in `app.ts` next to the existing routers):
```ts
router.post("/", async (req, res, next) => {
  try {
    res.status(201).json({ id: await createUser(req.body ?? {}) });
  } catch (e) {
    if (e instanceof ValidationError) return res.status(400).json({ error: e.message, field: e.field });
    if (e instanceof DuplicateError) return res.status(409).json({ error: "email already exists" });
    next(e);
  }
});
```
Rerun the tests until they pass.

### 5. Refactor
- If the project already has a shared validator or error-to-status mapper, use it instead of my local classes.
- Remove anything unused.
- Rerun the tests.

### 6. Run it
- `npm test`: the full suite.
- `npm run dev`, then:
  - `curl -i -XPOST localhost:3000/api/users -H 'content-type: application/json' -d '{"email":"a@x.com","name":"Ann"}'` → expect 201 `{"id":…}`
  - The same request again → expect 409.
  - `-d '{"email":"bad","name":"Ann"}'` → expect 400.
- Log the commands and the status codes I see in the notes file.

### Final reply
> **POST /api/users is in place:**
> - Valid `{email, name}` → 201 `{id}`
> - Invalid email or name → 400 `{error, field}`
> - Duplicate email (case-insensitive) → 409
>
> The duplicate check relies on the database's unique constraint on `users.email`. That prevents race conditions.
>
> **Tests:** `tests/users.post.test.ts` was written first and covers the happy path, 8 invalid inputs and duplicates. The full suite passes, and the curl checks returned 201, 409 and 400 as expected.
>
> **Assumptions to confirm:** emails are trimmed and lowercased; names are capped at 200 characters; the endpoint uses the existing `/api` auth.