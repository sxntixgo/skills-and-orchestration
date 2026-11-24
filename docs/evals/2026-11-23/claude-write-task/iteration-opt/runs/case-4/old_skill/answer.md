The task file is below. It is a dry run, so I assumed the file contents and command outputs, and I list those assumptions. You didn't name a run, so I'd create `2026-11-23-vitest-5`.

## What I'd do, in order

**1. Read the code and find every Node pin**
```bash
cd /workspaces/<repo>
cat web/package.json .github/workflows/ci.yml web/Dockerfile
ls web/vite.config.* web/vitest.config.* 2>/dev/null && cat web/vite*.config.*
grep -rn --include='*.json' --include='*.yml' --include='*.yaml' --include='Dockerfile*' \
  -e 'node-version' -e 'FROM node' -e '"node"' . | grep -v node_modules
ls .nvmrc web/.nvmrc .node-version .devcontainer/devcontainer.json 2>/dev/null
```
Assumed results:
- `web/package.json` has `vite ^5.4.10`, `vitest ^3.2.4`, `@vitest/coverage-v8 ^3.2.4`, `@vitejs/plugin-react ^4.3.4` and `"test": "vitest run"`.
- `web/vite.config.ts` has a `test:` block (`environment: 'jsdom'`, `coverage.provider: 'v8'`).
- There's no `.nvmrc` and no `engines` field.
- The devcontainer uses its own image, so it's out of scope.

**2. Check what the new versions require (skill step 5)**
```bash
npm view vitest@5 peerDependencies engines
npm view vite@7 engines
npm view @vitejs/plugin-react@latest peerDependencies engines
npm view @vitest/coverage-v8@5 peerDependencies
```
Assumed results:
- vitest 5 needs vite `^6 || ^7 || ^8` and Node `^20.19 || >=22.12`.
- vite 7 needs Node `^20.19 || >=22.12`.
- plugin-react 5 needs vite `^4.2 || ^5 || ^6 || ^7`.
- `@vitest/coverage-v8` must match vitest exactly.

Decisions:
- **vite ^7**, because it's the newest major the React plugin supports.
- **Node 22**, because it's the current LTS and 18 is past end of life.

**3. Record a baseline**
```bash
cd web && npx vitest run && npm run build
```
Both should pass on the current versions. If they fail, the failure is unrelated to this task, and I'd report it instead of writing the task.

**4. Write `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`**
```markdown
---
id: T1
run: 2026-11-23-vitest-5
depends_on: []
attempt: 1
---
# Upgrade vitest 3 → 5 in web/, with vite 7 and Node 22 where required

## Context
vitest 5 needs vite ^6||^7||^8 and Node ^20.19||>=22.12; vite 7 needs Node ^20.19||>=22.12.
Repo today: vite ^5.4, vitest ^3.2, @vitest/coverage-v8 ^3.2, @vitejs/plugin-react ^4.3 (web/package.json);
CI node-version 18 (.github/workflows/ci.yml); web/Dockerfile `FROM node:18-alpine AS build`.
Test config lives in the `test:` block of web/vite.config.ts.

## Files
- may change: web/package.json, web/package-lock.json, web/vite.config.ts,
  .github/workflows/ci.yml, web/Dockerfile
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. In web/package.json set: `vitest` → `^5`, `@vitest/coverage-v8` → `^5` (same major as vitest),
   `vite` → `^7`, `@vitejs/plugin-react` → `^5`. Change no other versions.
2. Run `cd web && npm install` to regenerate web/package-lock.json.
3. Run `cd web && npx vitest run`. If it fails on config options (not on test logic), fix only the
   `test:` block in web/vite.config.ts per the vitest 4/5 migration notes (e.g. `poolOptions` removed,
   `workspace` → `projects`). Do not edit test files; if a test itself breaks, stop and write it in
   RESULT.md Questions.
4. .github/workflows/ci.yml: every `node-version: 18` (or '18', 18.x) → `22`.
5. web/Dockerfile: `FROM node:18-alpine AS build` → `FROM node:22-alpine AS build`; same for any
   other `node:18` stage in that file.
6. Run the Done-when commands.

## Done when
- `cd web && npx vitest --version` prints `vitest/5.`
- `cd web && npx vitest run` passes
- `cd web && npm run build` passes
- `grep -rnE 'node-version: *.?18|node:18' .github/workflows/ci.yml web/Dockerfile` prints nothing

## Out of scope
- Upgrading any other dependency, or running `npm audit fix` / `npm update`
- Adding an `engines` field or `.nvmrc`
- Editing test files, refactoring config, formatting other files
- devcontainer and any other Dockerfile or workflow
```

**5. Log it in `.orchestra/2026-11-23-vitest-5/board.md`** (created if missing)
```markdown
| id | goal | depends_on | status | attempt |
|---|---|---|---|---|
| T1 | vitest 3→5 (+vite 7, Node 22 in CI/Dockerfile) | – | spec written | 1 |

## Log
- 2026-11-23 T1 spec written: tasks/T1.task.md (peers/engines checked: vite ≥6, node ≥20.19/22.12)
```
I'd also make sure `.orchestra/` is listed in `.git/info/exclude`.

## Reply to user

I wrote the task at `.orchestra/2026-11-23-vitest-5/tasks/T1.task.md`.

- **What the spec covers:** vitest 5 can't be upgraded alone. The task also moves vite to ^7 and plugin-react to ^5, keeps `@vitest/coverage-v8` on the same major as vitest, and changes Node 18 → 22 in both `ci.yml` and `web/Dockerfile`.
- **The check:** vitest reports version 5, the tests and build pass, and grep finds no Node 18 pins.
- **Network blocker:** step 2 (`npm install`) needs the npm registry, but the contract doesn't let opencode use the network. If the dispatch sandbox can't reach the registry, either I run `npm install` in the worktree before dispatch, or Claude handles T1 instead of opencode. Tell me which you want.