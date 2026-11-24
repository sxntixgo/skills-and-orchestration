I'd write `.orchestra/2026-11-23-vitest-5-upgrade/tasks/T1.task.md` for opencode. Running vitest 5 means bumping vite and Node 18 → 22 too, so CI and the Dockerfile are part of the task.

**1. Read the code first** (assumed contents in brackets)
- `web/package.json`: [`vite ^5.4`, `vitest ^3.2`, `@vitejs/plugin-react ^4.3`, `@vitest/coverage-v8 ^3.2`, scripts `test: vitest`, `build: vite build`; npm with `package-lock.json`]
- `web/vite.config.ts`: [`test` block inline at about line 8: `environment: 'jsdom'`]
- `.github/workflows/ci.yml`: [line 18 `node-version: 18`]
- `web/Dockerfile`: [line 1 `FROM node:18-alpine AS build`]
- Check for other Node pins: `ls -a web/ .nvmrc .node-version .devcontainer/ 2>/dev/null` [assume none]

**2. Check version requirements**
```
npm view vitest@5 peerDependencies engines
npm view vite@7 version engines peerDependencies
npm view @vitejs/plugin-react@latest version peerDependencies
npm view @vitest/coverage-v8@5 peerDependencies
```
Assumed results:
- vite 7 needs node `^20.19 || >=22.12`.
- plugin-react 5 accepts vite 7; plugin-react 4 does not.
- `@vitest/coverage-v8` must match the vitest version (5).
- Target: vite `^7`, Node 22.

**3. Baseline check**
```
cd web && npm ci && npx vitest run && npm run build
```
Assumed to pass on the current stack. For an upgrade, that's correct: the check is that it still passes after the bump.

**4. Write the task file**
```markdown
---
id: T1
run: 2026-11-23-vitest-5-upgrade
depends_on: []
attempt: 1
---
# Upgrade web/ to vitest 5, vite 7 and Node 22
## Context
vitest 5 requires peer vite ^6 || ^7 || ^8 and node ^20.19 || >=22.12. Today web/ has vite ^5.4 and
Node 18 is pinned in CI (.github/workflows/ci.yml:18) and in the Dockerfile (web/Dockerfile:1).
Target: vitest ^5, @vitest/coverage-v8 ^5 (must match vitest), vite ^7, @vitejs/plugin-react ^5
(the first version that accepts vite 7), Node 22.
Test config is the `test` block in web/vite.config.ts:8.
## Files
- may change: web/package.json, web/package-lock.json, .github/workflows/ci.yml, web/Dockerfile, web/vite.config.ts
- must NOT touch: everything else (and never .orchestra/, .git/)
## Steps
1. Use Node 22 locally (`node --version` must print v22.12 or higher).
2. In web/: `npm install -D vitest@^5 @vitest/coverage-v8@^5 vite@^7 @vitejs/plugin-react@^5`.
   This updates package.json and package-lock.json. Add no other packages.
3. .github/workflows/ci.yml: change `node-version: 18` to `node-version: 22`. Change nothing else.
4. web/Dockerfile line 1: `FROM node:18-alpine AS build` becomes `FROM node:22-alpine AS build`. Change nothing else.
5. Run `cd web && npx vitest run && npm run build`. Edit web/vite.config.ts only if one of them
   fails because of a vitest 5 or vite 7 config change (renamed or removed option). Fix only that
   option and keep the same behaviour.
6. If a test fails for a reason other than config, stop and report the test name and error.
   Don't edit the test.
## Done when
- `cd web && npm ci && npx vitest run && npm run build` passes on Node 22
- `cd web && npx vitest --version` prints 5.x and `npm ls vite` shows 7.x with no peer warnings
- ci.yml and the Dockerfile reference Node 22 and nothing else in them changed
## Out of scope
- Editing test files or source under web/src
- Bumping any other dependency (eslint, typescript, react, etc. stay as they are)
- Other Dockerfile stages, CI jobs or matrix changes; adding .nvmrc
- Reformatting package.json or the config
```

**5. Log** — append to `.orchestra/2026-11-23-vitest-5-upgrade/board.md`:
`- T1 written: tasks/T1.task.md (vitest 5 + vite 7 + Node 22; CI/Dockerfile pins included)`

**Final reply:**

I wrote the task to `.orchestra/2026-11-23-vitest-5-upgrade/tasks/T1.task.md`. Besides vitest 5, it moves vite 5.4 → 7, @vitejs/plugin-react → 5 and @vitest/coverage-v8 → 5, and changes Node 18 → 22 in `ci.yml` and the `web/Dockerfile` build stage. The check is `cd web && npm ci && npx vitest run && npm run build`.

If the Dockerfile's later stages also run Node, you'll need to bump those separately because the task leaves them out of scope. Production would then run a different Node version from build.