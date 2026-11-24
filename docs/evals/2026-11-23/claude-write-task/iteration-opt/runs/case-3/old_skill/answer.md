Here's how I'd revise T2 for attempt 2. Nothing exists on disk, so the run name, file paths and line numbers below are assumptions.

**Assumptions:** there is one active run, `.orchestra/2026-11-23-items-api/`. T2 is "Add `GET /api/lists/:id/items`". It may change `api/src/routes/items.ts` and `api/tests/items.test.ts`. Its test command is `npm --prefix api test -- items.test.ts`.

## Steps

1. **Find the run and the rejection details.**
   - `ls .orchestra/` and `cat .orchestra/*/board.md`, to find the run where T2 is rejected and read the reviewer's log entry.
   - `cat .orchestra/2026-11-23-items-api/tasks/T2.task.md tasks/T2.result.md`
   - `git -C .worktrees/2026-11-23-items-api/T2 diff main --stat`, then `git -C .worktrees/2026-11-23-items-api/T2 diff main -- web/src/App.tsx api/src/routes/items.ts`

2. **Read the code to get exact `file:line` for the notes.**
   - Assumed from the diff: `api/src/routes/items.ts:31` reads `rows[0].listId` before checking that `rows` has anything in it. On an empty list this throws a TypeError, which becomes a 500.
   - Assumed: the `web/src/App.tsx:12` edit added an items fetch on page load.
   - The pattern to copy for the empty case is `api/src/routes/lists.ts:18`, which returns `res.json([])` when there are no rows.

3. **Check the test command on `main`.** Run `npm --prefix api test -- items.test.ts`. It should fail or not exist yet, and not for unrelated reasons.

4. **Edit `.orchestra/2026-11-23-items-api/tasks/T2.task.md`.** Keep everything else as it is.
   - Frontmatter: change `attempt: 1` to `attempt: 2`.
   - `## Steps`: put a new first step before the rest, if the original didn't already have it:
     `1. In api/tests/items.test.ts add "returns 200 and [] for a list with no items" (create a list with no items, GET /api/lists/:id/items, expect status 200 and body []). Run it and see it fail.`
   - `## Done when`: add `- GET /api/lists/<id>/items for an existing list with no items returns 200 and []`
   - `## Files`: make the forbidden file explicit:
     `- must NOT touch: everything else, including web/ (in particular web/src/App.tsx), .orchestra/, .git/`
   - `## Out of scope`: add `- Any frontend wiring (web/src/App.tsx or other web/ files); a later task does it.`
   - Append:
     ```markdown
     ## Notes from review
     - web/src/App.tsx:12 — changed a file outside the task's Files list (added an items fetch) — revert it; touch only api/src/routes/items.ts and api/tests/items.test.ts.
     - api/src/routes/items.ts:31 — reads rows[0].listId before checking rows is non-empty, so an empty list throws and returns 500 — check the list exists first (404 if not), then return res.json(rows) so empty gives 200 []; copy api/src/routes/lists.ts:18.
     - api/tests/items.test.ts — no test for the empty-list case — add the test from Step 1 before changing the handler.
     ```

5. **Update `board.md`.**
   - T2 row: status `ready (attempt 2)`.
   - Log line: `2026-11-23 T2 spec revised for attempt 2 (out-of-scope App.tsx edit; empty-list 500) → tasks/T2.task.md`

## Reply to the user

> T2 is ready for attempt 2: `.orchestra/2026-11-23-items-api/tasks/T2.task.md`. It now has `attempt: 2`, a "Notes from review" section (revert the `web/src/App.tsx` change; `items.ts:31` must return 200 `[]` for an empty list instead of reading `rows[0]`), an empty-list test step, a matching Done-when line, and `web/` explicitly forbidden. To dispatch it, use `claude-dispatch`.