The original test passes as long as `cache.get` gets called. That stays true even if `getUser` returns the wrong user, returns nothing, or throws asynchronously. The new tests check what `getUser` returns, and they use an in-memory cache and a stubbed repo so they don't depend on how it's built.

**Assumed (I can't see the source):** Jest, TypeScript. The signature is `getUser(id, { cache, repo })`, async. It checks the cache, falls back to `repo.findById` on a miss, stores the result in the cache, and rejects with `NotFoundError` when the repo returns `null`. The test lives in `src/users/getUser.test.ts`. If the real code imports `cache` as a module singleton, use `jest.mock` on that module with the same in-memory `Map` instead of passing it in.

**Steps, in order:**

1. TodoWrite: identify contract → enumerate cases → write tests → run and confirm.
2. Write the case list to `./.claude-skills-work/writing-tests/getUser/cases.md`:
   - Happy: a cache miss returns the user from the repo.
   - Happy: a cache hit returns the cached user without touching the repo. Here the skipped fetch is the behavior being tested, so asserting on it is fine.
   - Happy: after a miss, the next call is served from the cache.
   - Error: an unknown id rejects with `NotFoundError`, and nothing is cached.
   - Error: a repo failure rejects with that error, and nothing is cached.
   - Boundary/edge: `id = 0` is a valid id, so it isn't treated as missing.
3. Replace the test in `src/users/getUser.test.ts`:

```ts
import { getUser, NotFoundError } from './getUser';

const alice = { id: 1, name: 'Alice' };

function setup(rows: Record<number, any> = { 1: alice }) {
  const cache = new Map<number, any>();
  const repo = { findById: jest.fn(async (id: number) => rows[id] ?? null) };
  return { cache, repo, deps: { cache, repo } };
}

describe('getUser', () => {
  test('returns the user from the repo on a cache miss', async () => {
    const { deps } = setup();
    await expect(getUser(1, deps)).resolves.toEqual(alice);
  });

  test('returns the cached user without fetching from the repo', async () => {
    const { cache, repo, deps } = setup({});
    cache.set(1, alice);
    await expect(getUser(1, deps)).resolves.toEqual(alice);
    expect(repo.findById).not.toHaveBeenCalled();
  });

  test('serves a second call from the cache', async () => {
    const { repo, deps } = setup();
    await getUser(1, deps);
    await expect(getUser(1, deps)).resolves.toEqual(alice);
    expect(repo.findById).toHaveBeenCalledTimes(1);
  });

  test('rejects with NotFoundError and caches nothing for an unknown id', async () => {
    const { cache, deps } = setup({});
    await expect(getUser(99, deps)).rejects.toBeInstanceOf(NotFoundError);
    expect(cache.has(99)).toBe(false);
  });

  test('propagates repo failures and caches nothing', async () => {
    const { cache, repo, deps } = setup();
    repo.findById.mockRejectedValueOnce(new Error('db down'));
    await expect(getUser(1, deps)).rejects.toThrow('db down');
    expect(cache.has(1)).toBe(false);
  });

  test('treats id 0 as a valid id', async () => {
    const { deps } = setup({ 0: { id: 0, name: 'Root' } });
    await expect(getUser(0, deps)).resolves.toEqual({ id: 0, name: 'Root' });
  });
});
```

4. Run `npx jest src/users/getUser.test.ts`. If a test passes on the first run, I'd break `getUser` on purpose (for example, have it return `undefined`) to confirm the test fails for the right reason.

**Final reply to the user:**

> Replaced the test. The old one passed as long as `cache.get` was called, even if `getUser` returned the wrong thing. The new tests check what it returns: cache miss, cache hit, a second call served from the cache, not-found, repo failure, and `id = 0`. They use an in-memory cache and a stubbed repo. The only call assertions are on the repo, because skipping the fetch is what caching is for. I assumed `getUser` is async and takes its cache and repo as arguments; if it imports them, I'll switch to `jest.mock`.