The current test only checks that `cache.get` was called. It never looks at what `getUser` returns, so it would still pass if the function returned the wrong user. My plan is to rewrite it around observable behaviour: the value returned, the errors thrown, and caching measured by how often the data source is hit.

**Assumptions** (I can't see the files): `src/users.js` contains `async getUser(id)`. It reads from `cache`, falls back to `db.findUserById`, stores what it finds in the cache, and throws `NotFoundError` when the user doesn't exist. Tests are Jest, next to the code as `src/users.test.js`. Both dependencies can be injected or module-mocked.

**What I'd do, in order:**

1. Add TodoWrite items: Contract, Enumerate, Write, Run.
2. Read `src/users.js` and `src/users.test.js` to confirm the contract and how dependencies are passed in.
3. Write `./.claude-skills-work/writing-tests/getUser/cases.md`:
   ```md
   # getUser cases
   Contract: getUser(id) -> Promise<User>; throws NotFoundError / TypeError; caches on miss.
   - Happy: returns user from db on cache miss
   - Happy: returns cached user without hitting db (caching IS the behaviour)
   - Happy: second call for same id served from cache (db hit once)
   - Boundary: id 0 / smallest valid id; distinct ids don't share cache entries
   - Edge: undefined / null / "1" (wrong type) -> TypeError
   - Error: unknown id -> NotFoundError, nothing cached
   - Error: db throws -> error propagates, nothing cached
   ```
4. Replace the test in `src/users.test.js`. In-memory fakes take the place of `toHaveBeenCalled` assertions:
   ```js
   const makeDeps = (rows = { 1: { id: 1, name: 'Ada' } }) => {
     const store = new Map();
     const cache = { get: k => store.get(k), set: (k, v) => store.set(k, v), store };
     const db = { calls: 0, async findUserById(id) { this.calls++; return rows[id] ?? null; } };
     return { cache, db, getUser: createGetUser({ cache, db }) };
   };

   describe('getUser', () => {
     test('returns the user from the db on a cache miss', async () => {
       const { getUser } = makeDeps();
       await expect(getUser(1)).resolves.toEqual({ id: 1, name: 'Ada' });
     });

     test('serves repeat lookups from cache, hitting the db once', async () => {
       const { getUser, db } = makeDeps();
       await getUser(1);
       await expect(getUser(1)).resolves.toEqual({ id: 1, name: 'Ada' });
       expect(db.calls).toBe(1);
     });

     test('does not return another id\'s cached user', async () => {
       const { getUser } = makeDeps({ 1: { id: 1, name: 'Ada' }, 2: { id: 2, name: 'Bo' } });
       await getUser(1);
       await expect(getUser(2)).resolves.toEqual({ id: 2, name: 'Bo' });
     });

     test('throws NotFoundError for an unknown id and caches nothing', async () => {
       const { getUser, cache } = makeDeps();
       await expect(getUser(99)).rejects.toBeInstanceOf(NotFoundError);
       expect(cache.store.size).toBe(0);
     });

     test('propagates db failures without caching', async () => {
       const { getUser, cache, db } = makeDeps();
       db.findUserById = async () => { throw new Error('db down'); };
       await expect(getUser(1)).rejects.toThrow('db down');
       expect(cache.store.size).toBe(0);
     });

     test.each([undefined, null, '1'])('rejects invalid id %p with TypeError', async id => {
       const { getUser } = makeDeps();
       await expect(getUser(id)).rejects.toBeInstanceOf(TypeError);
     });
   });
   ```
   If `getUser` imports `cache` and `db` directly instead of using a factory, I'd use `jest.mock` to swap in the same fakes and leave production code alone. Whether to refactor it is a decision for `software-development`, not this skill.
5. Run `npx jest src/users.test.js`. Then I'd temporarily break caching (skip `cache.set`) to check that the "db hit once" test fails. A test that can't fail tests nothing.

**Final reply:**

> I replaced the test that only checked `cache.get` was called. The new tests check what `getUser` returns on a cache miss and a cache hit, that cache entries don't leak between ids, and that not-found errors, db failures and invalid ids raise the right error without caching anything. Caching is tested by how often the db is hit, since that interaction is the behaviour. I didn't aim for 100% line coverage; the tests cover behaviour and failure modes. Case list: `.claude-skills-work/writing-tests/getUser/cases.md`.