Preflight, collection and triage are done (as a dry run). I stopped at gate 1: nothing has been dispatched. Of the 12 open alerts, 8 can be fixed by a plain lockfile refresh. The other 4 are runtime alerts in `mobile/` that only an `overrides` entry can fix, and that needs your OK.

**Assumptions.** The repo is at `/workspaces/news` on `main` (the default branch). `.orchestra/config.json` has `base_branch: "main"` and `concurrency: 2`. The test/build commands come from CI: `npm test && npm run build` in `web/`, and `npm test && npx expo export` in `mobile/`. Everything in the "Triage" section below is assumed `npm ls` / `npm view` output, since I can't run them here.

## What I'd run

**TodoWrite:** one item per step: Preflight, Collect, Triage, Gate 1, Tasks, Dispatch/review, Verify, Gate 2.

**1. Preflight**
```
cd /workspaces/news
git status --porcelain              # empty
git switch main && git pull --ff-only
jq -r .base_branch .orchestra/config.json   # main
curl -sf $MODEL_SERVER/v1/models >/dev/null # model server reachable
git branch -a | grep -iE 'deps|security|dependabot'   # assume: none
```
I'd skip `gh auth status` and `gh pr list --author app/dependabot` because you said not to call GitHub. I'd check `gh` auth before pushing at gate 2.

**2. Collect**
```
mkdir -p .orchestra/2026-11-23-dependabot
<skill-dir>/scripts/alerts.sh --file evals/files/news-alerts.json > .orchestra/2026-11-23-dependabot/alerts.tsv
```
The baseline is 12 rows: 6 in `web/` (all development scope) and 6 in `mobile/` (5 runtime, 1 development).

**3. Triage**
```
cd web    && npm ls vite source-map-js --all && npm view postcss@<installed> dependencies.source-map-js
cd mobile && npm ls zod brace-expansion glob minimatch image-size --all
npm view @expo/cli@<installed> dependencies.glob
npm view glob@<installed> dependencies.minimatch
npm view metro@<installed> dependencies.image-size
npm view @expo/cli@latest dependencies.glob ; npm view metro@latest dependencies.image-size
```
Assumed results:
- **vite:** a direct dev dependency at `^8.1.0`, installed 8.1.5. The range allows 8.1.6, so this is a lockfile fix.
- **source-map-js:** 1.2.1, pulled in by postcss with `^1.2.1`. That allows 1.2.2, so lockfile.
- **zod:** a direct dependency at `^4.5.0`, installed 4.6.2. That allows 4.6.6, so lockfile.
- **brace-expansion:** 1.1.11, pulled in by eslint/jest → `minimatch@3` with `^1.1.7`. That allows 1.1.21, so lockfile.
- **glob:** 10.4.5, pulled in by `@expo/cli` with `^10.4.2`. Even the latest `@expo/cli` still uses `^10`, and the only patched version is 14.0.2. That needs an override.
- **minimatch:** 9.0.5, pulled in by glob@10 with `^9.0.4`. The only patched version is 11.0.1, so override.
- **image-size:** 1.2.1, pulled in by `metro` with `^1.0.2`. The only patched version is 2.0.3, and the latest metro still uses `^1`. Override.

**File `.orchestra/2026-11-23-dependabot/triage.md`:**
```
# Dependabot triage: sxntixgo/news (main), 2026-11-23. Baseline: 12 open alerts

| # | GHSA | Sev | Package | Lockfile | Scope | Via | Kind | Task |
|---|---|---|---|---|---|---|---|---|
| 78 | GHSA-9jrq-w75r-8gcw | low | vite 8.1.5→8.1.6 | web | dev | direct ^8.1.0 | lockfile | T1 |
| 77 | GHSA-rq7h-c2jc-7f22 | med | vite | web | dev | direct | lockfile | T1 |
| 76 | GHSA-r825-w8mm-5pxw | med | vite | web | dev | direct | lockfile | T1 |
| 75 | GHSA-587h-7wmj-h5pm | high | vite | web | dev | direct | lockfile | T1 |
| 74 | GHSA-698v-4r3x-3vcv | med | vite | web | dev | direct | lockfile | T1 |
| 73 | GHSA-68fv-2mgg-jv7q | high | source-map-js 1.2.1→1.2.2 | web | dev | postcss ^1.2.1 | lockfile | T1 |
| 45 | GHSA-mrhx-c7xc-m3w5 | high | zod 4.6.2→4.6.6 | mobile | runtime | direct ^4.5.0 | lockfile | T2 |
| 40 | GHSA-q2hr-2g5m-vwhr | med | brace-expansion 1.1.11→1.1.21 | mobile | dev | minimatch@3 ^1.1.7 | lockfile | T2 |
| 58 | GHSA-3g3m-2fjr-6pw4 | med | glob 10.4.5→14.0.2 | mobile | runtime | @expo/cli ^10.4.2 | override (major) | T3? |
| 59 | GHSA-g3hv-75wg-m249 | med | minimatch 9.0.5→11.0.1 | mobile | runtime | glob@10 ^9.0.4 | override (major) | T3? |
| 34 | GHSA-5p2g-fcmc-qvqq | high | image-size 1.2.1→2.0.3 | mobile | runtime | metro ^1.0.2 | override (major) | T3? |
| 33 | GHSA-w3rx-r6r6-pgpr | high | image-size | mobile | runtime | metro ^1.0.2 | override (major) | T3? |

## Proposed tasks
- T1 web lockfile: `npm update vite source-map-js` (no major), parallel with T2
- T2 mobile lockfile: `npm update zod brace-expansion` (no major)
- T3 (needs OK) mobile overrides: glob ^14.0.2, minimatch ^11.0.1, image-size ^2.0.3.
  Depends on T2 (same lockfile). Forces: CLI/Metro deps running on newer majors they weren't
  released against; check engines (glob 14/minimatch 11 need Node ≥20) against CI + Dockerfile.

## Outcome
(filled in at step 7)
```

## Gate 1: what I need from you

| Kind | Alerts | Task |
|---|---|---|
| lockfile, `web/` | 6 (vite ×5, source-map-js) | **T1**: `npm update vite source-map-js` → vite 8.1.6+ (stays on 8.x), source-map-js 1.2.2 |
| lockfile, `mobile/` | 2 (zod, brace-expansion) | **T2**: `npm update zod brace-expansion` → zod 4.6.6+, brace-expansion 1.1.21+ |
| override, `mobile/` | 4 (glob, minimatch, image-size ×2) | **T3**, only if you approve it |
| no fix / pip pins | 0 | none |

T1 and T2 run in parallel. Each is done when its listed GHSA ids are gone from `npm audit` in that folder, test and build pass, and `git diff --stat` shows only that folder's `package-lock.json` changed.

**Runtime alerts (all in `mobile/`):**
- **zod (#45, high):** it's in the shipped app bundle, so T2 changes the app's runtime.
- **glob (#58), minimatch (#59) and image-size (#33, #34):** GitHub labels these runtime, but they come in through `@expo/cli` and `metro`. They run on the build and dev machine, not on users' devices. They're still real alerts, and none of them will be dismissed.
- **Deployed apps that change:** with T1 and T2, only the mobile app (because of zod). The deployed web bundle doesn't change.

**T3, the override option.** Their parents (`@expo/cli` and `metro`) only accept glob 10, minimatch 9 and image-size 1, and no release of those parents moves up, even the latest. The only fixes are new majors: glob 14.0.2, minimatch 11.0.1 and image-size 2.0.3. An `overrides` block would force those versions:
- The parents haven't been tested against those majors. In particular, image-size 2 changed its API, which could break Metro's asset sizing.
- glob 14 and minimatch 11 need Node 20 or newer, so I'd check the Node version used by CI and the Dockerfile.
- T3 would run after T2 (they share a lockfile), with an `npx expo export` plus a Metro asset build as the check.

If you decline T3, those 4 alerts stay open and I'll list each one as remaining, with its GHSA id and the reason: they wait on an Expo or Metro release.

**Questions:**
1. Run T1 and T2?
2. Include T3 (overrides for glob, minimatch and image-size), or leave those 4 open?