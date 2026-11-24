**What I'd do, in order (dry run; nothing below was actually run):**

**Assumptions.** The project uses React 18, TypeScript, Vitest and React Testing Library, with components in `src/components/`. `GET /api/users` returns `[{ id, name, email }]`. "Shows them" means a list of names with emails. I'd state these and build without asking, since only details are open. Pagination, search and caching wait until something needs them (YAGNI).

1. **TodoWrite:** Understand · Plan slice · TDD loop · DRY/YAGNI/KISS · Run it.
2. **Notes:** write `./.claude-skills-work/software-development/user-list/notes.md` with the restatement: "UserList fetches `/api/users` once on mount. It shows a loading state, then a `<ul>` of users, an empty message for `[]`, or an error message for a non-OK or failed request. Done when all four states render and the tests pass."
3. **Plan the slice:** two files, `src/components/UserList.tsx` and `UserList.test.tsx`. I'd use plain `fetch` with no new data library, and ignore the response if the component unmounts first.
4. **Red:** write `src/components/UserList.test.tsx`, stubbing `fetch` at the seam:
   ```tsx
   import { render, screen } from '@testing-library/react';
   import { afterEach, expect, it, vi } from 'vitest';
   import { UserList } from './UserList';

   const respond = (body: unknown, ok = true) =>
     vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok, json: async () => body }));
   afterEach(() => vi.unstubAllGlobals());

   it('shows a loading state while fetching', () => {
     vi.stubGlobal('fetch', vi.fn(() => new Promise(() => {})));
     render(<UserList />);
     expect(screen.getByText(/loading users/i)).toBeInTheDocument();
   });

   it('lists every user returned by /api/users', async () => {
     respond([{ id: 1, name: 'Ada', email: 'ada@x.io' }, { id: 2, name: 'José Ñúñez', email: 'j@x.io' }]);
     render(<UserList />);
     const items = await screen.findAllByRole('listitem');
     expect(items).toHaveLength(2);
     expect(items[1]).toHaveTextContent('José Ñúñez');
   });

   it('renders a single user', async () => {
     respond([{ id: 1, name: 'Ada', email: 'ada@x.io' }]);
     render(<UserList />);
     expect(await screen.findAllByRole('listitem')).toHaveLength(1);
   });

   it('shows an empty message when there are no users', async () => {
     respond([]);
     render(<UserList />);
     expect(await screen.findByText(/no users/i)).toBeInTheDocument();
   });

   it('shows an error when the server responds non-OK', async () => {
     respond({}, false);
     render(<UserList />);
     expect(await screen.findByRole('alert')).toHaveTextContent(/couldn.t load users/i);
   });

   it('shows an error when the network fails', async () => {
     vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('offline')));
     render(<UserList />);
     expect(await screen.findByRole('alert')).toBeInTheDocument();
   });
   ```
   Then run `npx vitest run src/components/UserList.test.tsx`. All tests should fail because the module `./UserList` doesn't exist yet. That's the right reason.
5. **Green:** write `src/components/UserList.tsx`:
   ```tsx
   import { useEffect, useState } from 'react';

   type User = { id: number; name: string; email: string };
   type State =
     | { status: 'loading' }
     | { status: 'error' }
     | { status: 'success'; users: User[] };

   export function UserList() {
     const [state, setState] = useState<State>({ status: 'loading' });

     useEffect(() => {
       let active = true;
       fetch('/api/users')
         .then((res) => {
           if (!res.ok) throw new Error(`HTTP ${res.status}`);
           return res.json() as Promise<User[]>;
         })
         .then((users) => active && setState({ status: 'success', users }))
         .catch(() => active && setState({ status: 'error' }));
       return () => { active = false; };
     }, []);

     if (state.status === 'loading') return <p aria-busy="true">Loading users…</p>;
     if (state.status === 'error') return <p role="alert">Couldn't load users.</p>;
     if (state.users.length === 0) return <p>No users yet.</p>;
     return (
       <ul aria-label="Users">
         {state.users.map((u) => (
           <li key={u.id}>{u.name} <span>({u.email})</span></li>
         ))}
       </ul>
     );
   }
   ```
   Rerun the same Vitest command and expect 6/6 to pass.
6. **Refactor (DRY/YAGNI/KISS):** use a single state union instead of three booleans. There are no props, no config and no retry button, because nothing asks for them. The `respond` helper in the test is the only shared setup. Rerun to stay green.
7. **Run it:**
   - Run `npm test`, `npm run lint`, `npx tsc --noEmit` and `npm run build`.
   - Render `<UserList />` on an existing page and start `npm run dev` in the background. Load the page against the real or mocked `/api/users` and check the list, then the empty and error states by temporarily pointing at a failing response.
   - Stop the dev server and remove the temporary page wiring if it wasn't wanted.
8. **Log** the commands and their results in `notes.md`. Don't `git commit`, since that wasn't requested.

**Final reply to the user:**

> I've added `UserList` (`src/components/UserList.tsx`). It fetches `/api/users` once on mount and shows "Loading users…", then a `<ul>` of names and emails. It shows "No users yet." for an empty array and an alert, "Couldn't load users.", if the request fails or returns a non-OK status. It ignores the response if it unmounts before the fetch finishes.
>
> **Tests:** I wrote `UserList.test.tsx` first, covering loading, a list with unicode names, a single user, empty, a non-OK response and a network failure. All 6 pass. Lint, typecheck and build are clean, and I checked the list, empty and error states in the dev server.
>
> **Assumptions:** the response is a JSON array of `{ id, name, email }`. If it's wrapped (e.g. `{ users: [...] }`) or has other fields, tell me and I'll adjust. I left out pagination, search and retry until you need them.
>
> Nothing is committed.