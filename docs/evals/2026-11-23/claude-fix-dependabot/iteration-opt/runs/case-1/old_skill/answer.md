Stopped at **gate 1**. 12 open alerts on `sxntixgo/news`: 7 in `web/` (all development-only) and 5 in `mobile/` (4 with runtime scope). Under my assumptions, 8 of them need only a lockfile update. The other 4 (glob, minimatch, two for image-size) can only be fixed with a major bump or an `overrides` entry, and I need your choice before dispatching anything.

## What I'd do, in order

**1. TodoWrite**: one item per skill step: Preflight, Collect, Triage, Gate 1, Write tasks, Dispatch+review, Verify, Gate 2.

**2. Preflight** (in `/workspaces/news`)
```bash
git status --porcelain && git rev-parse --abbrev-ref HEAD && git fetch && git status -sb
gh auth status
jq .base_branch .orchestra/config.json
git branch -a | grep -i -E 'deps|security|dependabot'
gh pr list --author app/dependabot
```
Then I'd read `CLAUDE.md`, the README and `.github/workflows/*` to get the test and build commands.
**Assumed:** the repo is clean, on `main` and up to date. `gh` is logged in and `base_branch` is `main`. No old `deps/…` branches and no open Dependabot PRs. The web commands are `npm ci && npm test && npm run build` in `web/`. The mobile commands are `npm ci && npm test && npx expo export` in `mobile/`. The web app is deployed as a Docker image built from the Vite output; the mobile app is an Expo build and isn't deployed as a server image.

**3. Collect**, using the saved file instead of GitHub:
```bash
mkdir -p .orchestra/2026-11-23-dependabot/{tasks,logs}
<base>/scripts/alerts.sh --file evals/files/news-alerts.json > .orchestra/2026-11-23-dependabot/alerts.tsv
wc -l < .orchestra/2026-11-23-dependabot/alerts.tsv   # baseline = 12
```

**4. Triage.** Find which dependency pulls in each package:
```bash
cd web    && npm ls vite source-map-js --all
cd mobile && npm ls zod brace-expansion glob minimatch image-size --all
npm view <parent>@<installed> dependencies.<pkg>   # for each transitive path
```
**Assumed results:**
- `web` has `"vite": "^8.x"`, and postcss allows `source-map-js@^1.2.1`. Both are lockfile fixes.
- `mobile` has `"zod": "^4.x"` directly, which is a lockfile fix.
- In `mobile`, brace-expansion@1 comes in through minimatch@3 (jest/eslint) with range `^1.1.7`, which is also a lockfile fix.
- glob@10, minimatch@9 and image-size@1 are pulled in by Expo/Metro (`@expo/cli`, `metro`) with `^10` / `^9` / `^1` ranges. Their fixes are only in glob 14.0.2, minimatch 11.0.1 and image-size 2.0.3, which are new majors of those packages. No released Expo SDK allows those versions (still to be confirmed with `npm view expo@latest`), so the only options are an override or leaving them open.

**File `.orchestra/2026-11-23-dependabot/triage.md`:**
```markdown
# Dependabot triage — sxntixgo/news — 2026-11-23 (baseline: 12 open)

| # | package | lockfile | scope | sev | kind | task | outcome |
|---|---|---|---|---|---|---|---|
| 73 | source-map-js <1.2.2 → 1.2.2 (via postcss) | web | dev | high | lockfile | T1 | pending |
| 74 | vite ≤8.1.5 → 8.1.6 (GHSA-698v-4r3x-3vcv) | web | dev | med | lockfile | T1 | pending |
| 75 | vite → 8.1.6 (GHSA-587h-7wmj-h5pm) | web | dev | high | lockfile | T1 | pending |
| 76 | vite → 8.1.6 (GHSA-r825-w8mm-5pxw) | web | dev | med | lockfile | T1 | pending |
| 77 | vite → 8.1.6 (GHSA-rq7h-c2jc-7f22) | web | dev | med | lockfile | T1 | pending |
| 78 | vite → 8.1.6 (GHSA-9jrq-w75r-8gcw) | web | dev | low | lockfile | T1 | pending |
| 40 | brace-expansion <1.1.21 → 1.1.21 (via minimatch@3) | mobile | dev | med | lockfile | T2 | pending |
| 45 | zod <4.6.6 → 4.6.6 (direct) | mobile | runtime | high | lockfile | T2 | pending |
| 58 | glob ≤14.0.1 → 14.0.2 (via @expo/cli, ^10) | mobile | runtime | med | override? | T3? | gate 1 |
| 59 | minimatch <11.0.1 → 11.0.1 (via glob@10, ^9) | mobile | runtime | med | override? | T3? | gate 1 |
| 33 | image-size ≤2.0.2 → 2.0.3 (via metro, ^1) | mobile | runtime | high | override? | T3? | gate 1 |
| 34 | image-size → 2.0.3 (GHSA-5p2g-fcmc-qvqq) | mobile | runtime | high | override? | T3? | gate 1 |

## Proposed tasks
- T1 web lockfile: `npm update vite source-map-js` (8.1.6 / 1.2.2). Runs in parallel with T2.
- T2 mobile lockfile: `npm update zod brace-expansion`.
- T3 (only if approved) mobile `overrides`: glob ^14.0.2, minimatch ^11.0.1, image-size ^2.0.3; depends on T2.
  Forces: glob 14 / minimatch 11 need Node ≥20 (check `.nvmrc`, CI `setup-node`, the Dockerfile);
  @expo/cli and metro call glob@10 / image-size@1 APIs, so it can break `expo start` / `expo export`.
- No major of a direct dependency fixes these; an Expo SDK upgrade doesn't help until Expo raises its ranges.

## Runtime reach
- web: all dev-only. The deployed image's runtime contents don't change, only the build tool.
- mobile: glob, minimatch and image-size are "runtime" only because they're pulled in through `expo`'s
  dependencies. They're CLI/bundler code and don't ship in the app bundle. zod (#45) does ship in the app.
```
No subagents are spawned and nothing is dispatched yet. I'd log the triage to `board.md` as "steps 1–3 done; waiting at gate 1".

## Gate 1: decision needed

| kind | alerts | plan |
|---|---|---|
| lockfile | 8 (#73–78 web, #40 and #45 mobile) | T1 (web) and T2 (mobile) run in parallel |
| override / no fixed parent | 4 (#58, #59, #33, #34; all mobile, runtime scope) | needs your call |
| no fix / pin | 0 | n/a |

These reach production:
- **zod #45 (high) ships in the mobile app.** T2 fixes it.
- glob, minimatch and image-size (#58, #59, #33, #34) are marked runtime but are Expo/Metro build tooling, not shipped code.
- Nothing in `web` changes the deployed runtime.

**For #58, #59, #33 and #34, pick one:**
- **A)** Add T3 with npm `overrides` (glob ^14.0.2, minimatch ^11.0.1, image-size ^2.0.3). This may break `expo export` or Metro, and needs Node ≥20 in CI and the Dockerfile. T3 is rejected if the mobile build fails.
- **B)** Skip them and list them as remaining ("waiting for Expo/Metro to raise their ranges"). They wouldn't be dismissed.

My recommendation is **B**, plus T1 and T2 now. The risk of breaking the toolchain outweighs a DoS fix in code that only runs at build time. If you'd rather try A, I'll run T3 after T2 and keep it only if the mobile build and tests pass.

Every `npm ls` result above is assumed, since I didn't run anything. If the real output shows a parent that allows the patched versions, those alerts become lockfile fixes too.