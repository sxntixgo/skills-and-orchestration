The spec is below; it's for a dry run, so no commands were actually run. The upgrade isn't just a vitest bump. Vitest 5 also needs vite 6 or later, and Node ^20.19 or ≥22.12, so the task moves vite to 7 and Node from 18 to 22 in CI and the Dockerfile.

**1. Read the code first (assumed contents):**
- `cat web/package.json`
  - Assumed: `vite ^5.4`, `vitest ^3.2`, `@vitest/coverage-v8 ^3.2`, `@vitejs/plugin-react ^4.3`.
  - Assumed scripts: `"test": "vitest"`, `"build": "vite build"`.
- `cat web/vite.config.ts`: assumed to hold the `test:` block (`environment: 'jsdom'`, `coverage.provider: 'v8'`). There is no separate `vitest.config.ts` and no `vitest.workspace.ts`.
- `cat .github/workflows/ci.yml`: assumed `actions/setup-node@v4` with `node-version: 18` at line 18.
- `cat web/Dockerfile`: `FROM node:18-alpine AS build` at line 1. Assumed runtime stage is `nginx:alpine`, so no other Node pin.
- `ls -a . web/ .devcontainer/`: assumed no `.nvmrc`, and no Node version pinned in the devcontainer.

**2. Check what the new versions require:**
```
npm view vitest@5 peerDependencies engines
npm view vite@7 engines
npm view @vitejs/plugin-react@latest peerDependencies
npm view @vitest/coverage-v8@5 peerDependencies
```
Assumed results:
- vitest 5: peer `vite ^6 || ^7 || ^8`; engines `node ^20.19 || >=22.12` (as you stated).
- vite 7: engines `node ^20.19 || >=22.12`.
- `@vitejs/plugin-react` 5.x: peer includes vite ^7.
- `@vitest/coverage-v8` 5: peer `vitest 5.x` (must match vitest exactly).

Decisions:
- **vite ^7**: same Node range as vitest 5 and not a new major beyond what's needed.
- **Node 22** (`node-version: 22`, `node:22-alpine`).
- `@vitejs/plugin-react` moves to ^5.
- `@vitest/coverage-v8` moves to ^5.

**3. Pin the check:** `cd web && npm test -- --run && npm run build` passes on vitest 3 today, as the baseline. The proof of the upgrade is `npx vitest --version` showing 5.x plus the same suite and build passing.

**4. Write the task** (assumed run `2026-11-23-vitest-5`), at `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`:

```markdown
---
id: T1
run: 2026-11-23-vitest-5
depends_on: []
attempt: 1
---
# Upgrade vitest 3 → 5 in web/, with vite 5 → 7 and Node 18 → 22

## Context
vitest 5 needs peer vite ^6 || ^7 || ^8 and node ^20.19 || >=22.12. vite 7 needs the same node range.
So all four move together: vitest + @vitest/coverage-v8 → ^5, vite → ^7, @vitejs/plugin-react → ^5,
Node → 22 in CI (.github/workflows/ci.yml:18) and in the Docker build stage (web/Dockerfile:1).
Test config lives in web/vite.config.ts (`test:` block).

## Files
- may change: web/package.json, web/package-lock.json, web/vite.config.ts, .github/workflows/ci.yml, web/Dockerfile
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In web/: `npm install -D vitest@^5 @vitest/coverage-v8@^5 vite@^7 @vitejs/plugin-react@^5`
   (this updates package.json and package-lock.json; do not edit the lockfile by hand).
2. `npx vitest --version` must print 5.x. Run `npm test -- --run`.
3. Only if step 2 fails with a config or API error: fix web/vite.config.ts per the vitest 4 and 5
   migration guides (e.g. renamed `test.*` options). Do not change test files. If a test itself
   fails, stop and report it under Questions.
4. `npm run build` must pass.
5. .github/workflows/ci.yml: change every `node-version: 18` to `node-version: 22`.
6. web/Dockerfile: `FROM node:18-alpine AS build` → `FROM node:22-alpine AS build`.

## Done when
- `cd web && npx vitest --version` prints 5.x
- `cd web && npm test -- --run && npm run build` passes
- `grep -rn "18" .github/workflows/ci.yml web/Dockerfile` shows no Node 18 pin left

## Out of scope
- Upgrading any other dependency, or running `npm update` / `npm audit fix`
- Editing tests or source files under web/src/
- Other CI changes (matrix, cache, action versions)
- Changing the runtime stage of the Dockerfile
- Formatting other files
```

Assumption: the dispatch environment lets opencode reach the npm registry for `npm install`. Without that, the contract's no-network rule blocks this task. In that case I'd run step 1 myself first and give opencode the rest.

**5. Log in `board.md`:**
- Task table row: `T1 | Upgrade vitest 3→5 (+vite 7, Node 22) | written | attempt 1`
- Log line: `2026-11-23 T1 written: .orchestra/2026-11-23-vitest-5/tasks/T1.task.md; found requirements vite ≥6, node ^20.19||≥22.12 → CI + Dockerfile pins in scope`

**6. Final reply:**

> I wrote the task at `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`. Vitest 5 forces two more changes: vite goes 5 → 7 (with `@vitejs/plugin-react` ^5 and `@vitest/coverage-v8` ^5), and Node goes 18 → 22 in `ci.yml` and the Dockerfile build stage. The check is `cd web && npm test -- --run && npm run build`, plus `vitest --version` showing 5.x. opencode needs npm registry access for this task. Without it, I'll run the install first.

If I were running as the orchestrator's subagent, I'd reply with only `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`.