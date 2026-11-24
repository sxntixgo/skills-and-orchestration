**Stopping at Stage 1 (Understand) to ask questions before writing any code.** The request doesn't say which fields to show, what the response looks like, or where the component goes. Guessing those would mean inventing requirements, which the skill says not to do.

## What I'd do, in order

1. **TodoWrite:** add 5 items: Understand, Plan smallest slice, TDD loop, Refactor (DRY/YAGNI/KISS), Verify it runs. Mark Understand as in progress.

2. **Read-only look at the codebase** to answer what I can myself (no edits). Assumed results:
   - `package.json`: React 18 + TypeScript, Vitest + React Testing Library, plain `fetch` (no React Query or SWR).
   - Search for `api/users` and `type User`: **not found**. There's no shared `User` type and no client code calling the endpoint, so the response shape is unknown.
   - `src/components/`: existing components are function components with co-located `*.test.tsx`, and data-fetching lives in small `useX` hooks in `src/hooks/`.

3. **Write the checkpoint** to `./.claude-skills-work/software-development/user-list/understand.md`:
   ```markdown
   # UserList — Stage 1 (Understand)
   ## Restatement
   A React component `UserList` that GETs /api/users on mount and renders the
   users as a list. Done = rendered list matches API data, with explicit
   loading / empty / error states, covered by tests written first.

   ## Assumed from codebase
   - React 18 + TS, Vitest + RTL, plain fetch; fetching goes in a hook
     (src/hooks/useUsers.ts), presentation in src/components/UserList.tsx.

   ## Unknowns (asked user, 2026-11-23)
   1. Response shape of /api/users (array vs {users, ...}; paginated?)
   2. Which fields to display per user
   3. Where it mounts (route/page) or component-only
   4. Wording for empty/error states; retry button?

   ## Status
   BLOCKED on user answers. No code written.
   ```

4. **No subagents and no code yet.** Plan, TDD and verify wait for the answers.

## Reply to user

Before I build `UserList`, I need a few answers. Defaults are in brackets, so you can just say "defaults are fine":

1. **Response shape:** What does `GET /api/users` return? [a plain array of `{ id, name, email }`, not paginated]
2. **Fields:** What should each row show? [name and email]
3. **Placement:** Should I mount it on a page or route, or just build the component? [component only]
4. **States:** I'll add loading, empty ("No users found") and error ("Couldn't load users") states. Do you want a Retry button on the error state? [no]

Once you answer, I'll write the plan, then build it test-first: a `useUsers` hook plus a presentational `UserList`, with tests for each state. Then I'll render it against the real endpoint to confirm it works.