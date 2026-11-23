The task file is below: `T1` bumps vitest to ^5, vite to ^6 and Node 18 → 22. Vitest 5 can't be upgraded alone: it needs vite 6 or later and Node 20.19+ or 22.12+, so the CI and Dockerfile Node pins are part of the same task.

**Assumptions** (nothing is on disk):
- **Run:** `2026-11-23-vitest-5`, with `.orchestra/2026-11-23-vitest-5/` and `board.md` already set up.
- **Other packages in `web/package.json`:**
  - `@vitejs/plugin-react ^4.3.1`
  - `@vitest/coverage-v8 ^3.2`
  - a `package-lock.json`
  - a `vite.config.ts` with a `test:` block
  - scripts `test: vitest run` and `build: vite build`
- **Node pins:** there is no `.nvmrc`, no `engines` field in `web/package.json`, and the devcontainer image is already Node 22.
- **npm registry access:** the opencode worktree can reach the npm registry for `npm install`. Earlier dependabot fixes ran through opencode the same way. If it can't, I run the install in the worktree myself before dispatch.

## What I'd do, in order

**1. Read the code.** I'd open these files and note the `file:line` of each pin:
- `web/package.json`
- `web/vite.config.ts`
- `.github/workflows/ci.yml` (the `node-version: 18` line)
- `web/Dockerfile` (`FROM node:18-alpine AS build`)

I'd also grep for other Node pins, which I assume finds none beyond those two:
```
grep -rn "node-version\|FROM node\|\"engines\"" .github web .devcontainer
ls .nvmrc .node-version
```

**2. Check what the new versions require:**
```
npm view vitest@5 peerDependencies engines
npm view vite@6 peerDependencies engines
npm view @vitejs/plugin-react@latest peerDependencies
npm view @vitest/coverage-v8@5 peerDependencies
```
Assumed results:
- **vitest 5:** peer vite `^6 || ^7 || ^8`, node `^20.19 || >=22.12`
- **vite 6:** node `^18 || ^20 || >=22`
- **@vitejs/plugin-react 4.3.4+:** accepts vite 6
- **@vitest/coverage-v8 5:** peer vitest 5

**3. Decide the targets:**
- **vite `^6`:** the smallest step that meets the peer requirement.
- **Node `22`:** it satisfies `>=22.12` and has longer support than 20.
- **Companion packages:** `@vitest/coverage-v8` goes to ^5 and `@vitejs/plugin-react` to ^4.3.4.

**4. Run the check now (baseline):**
```
cd web && npx vitest run && npm run build
```
I'd expect it to pass on vitest 3. The task's Done-when also checks `npm ls` and the version pins, and those fail today, so the task is meaningful.

**5. Write `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`:**

```markdown
---
id: T1
run: 2026-11-23-vitest-5
depends_on: []
attempt: 1
---
# Upgrade vitest 3 → 5 in web/, with vite 5 → 6 and Node 18 → 22

## Context
vitest 5 requires peer vite ^6 || ^7 || ^8 and node ^20.19 || >=22.12. Today web/package.json has
vite ^5.4 and vitest ^3.2, CI uses node-version 18 (.github/workflows/ci.yml:<line>) and the image
builds FROM node:18-alpine (web/Dockerfile:1). Targets: vitest ^5, @vitest/coverage-v8 ^5,
vite ^6, @vitejs/plugin-react ^4.3.4 (first version accepting vite 6), Node 22 everywhere.

## Files
- may change: web/package.json, web/package-lock.json, web/vite.config.ts, .github/workflows/ci.yml, web/Dockerfile
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In web/: `npm install -D vitest@^5 @vitest/coverage-v8@^5 vite@^6 @vitejs/plugin-react@^4.3.4`
   (this updates package.json and package-lock.json; do not edit the lockfile by hand).
2. Run `npm ls vite vitest @vitest/coverage-v8 @vitejs/plugin-react`; it must print no
   "invalid" or "ERESOLVE" lines.
3. Run `npx vitest run`. If it fails because of vitest/vite config changes, fix only
   web/vite.config.ts (e.g. renamed `test:` options); do not change test files or app code.
4. Run `npm run build`; fix only web/vite.config.ts if vite 6 rejects an option.
5. .github/workflows/ci.yml: change `node-version: 18` to `node-version: 22` (every occurrence).
6. web/Dockerfile: change `FROM node:18-alpine AS build` to `FROM node:22-alpine AS build`.

## Done when
- `cd web && npm ls vite vitest @vitest/coverage-v8 @vitejs/plugin-react && npx vitest run && npm run build` passes
- `grep -rn "node-version: 18\|node:18" .github web/Dockerfile` prints nothing
- web/package.json lists vitest ^5.x and vite ^6.x

## Out of scope
- vite 7/8, other dependency upgrades, `npm audit fix`
- editing tests or app source to silence failures (report in Questions instead)
- adding an `engines` field, .nvmrc, or changing the devcontainer
- reformatting package.json or other files
```

**6. Log in `board.md`:**
```
| T1 | Upgrade vitest 3→5 (+vite 6, Node 22 in CI/Dockerfile) | written | tasks/T1.task.md |
2026-11-23 T1 written: vitest 5 needs vite ≥6 + node ≥20.19/22.12 → vite ^6, Node 22 in ci.yml + Dockerfile.
```

## Reply to user

I wrote the task to `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`. It covers more than the vitest version:
- **vite 5.4 → ^6:** vitest 5 needs vite 6 or later, so `@vitejs/plugin-react` goes to ^4.3.4 and `@vitest/coverage-v8` to ^5 as well.
- **Node 18 → 22:** vitest 5 needs Node 20.19+ or 22.12+, so the task updates both `node-version` in `ci.yml` and the `node:18-alpine` base image in `web/Dockerfile`.

The check is `npm ls` with no peer errors, then `vitest run`, then `vite build`, plus a grep confirming no Node 18 pins are left.

Two things to confirm:
- **Production image:** moving the Dockerfile to Node 22 changes it, so check that it's OK before merge.
- **npm registry access:** the task assumes opencode's worktree can reach the npm registry. If it can't, I'll run the install there myself before dispatch.