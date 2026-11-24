I'll handle this with the `claude-fix-dependabot` skill. This is a dry run, so the alert data below is assumed, and the run stops at gate 1 for your answer.

## What I'd do, in order

**0. TodoWrite**, one item per step: Preflight, Collect, Triage, Gate 1, Write tasks, Dispatch + review/merge, Verify, Gate 2.

**1. Preflight** (in `/workspaces/learn`)
```bash
git status --porcelain                      # must be empty
git rev-parse --abbrev-ref HEAD             # must be main (the default branch)
git fetch origin && git status -sb          # up to date with origin/main
gh auth status
gh repo view sxntixgo/learn --json defaultBranchRef -q .defaultBranchRef.name   # → main
cat .orchestra/config.json                  # base_branch must be "main"; missing file = defaults
git branch -a | grep -i -E 'deps|security|dependabot'
gh pr list --repo sxntixgo/learn --author app/dependabot
```
I'd also read `CLAUDE.md`, `README.md` and `.github/workflows/*.yml` to find the test and build commands.
Assumptions:
- The repo is clean and on `main`.
- `base_branch` is `main`.
- There are no earlier `deps/…` branches and no open Dependabot PRs. If there were, I'd offer at gate 1 to reuse or supersede them.
- There is one npm project at the repo root with a `package-lock.json`.
- The commands are `npm ci && npm test && npm run build`.
- There is a Dockerfile that runs `npm ci --omit=dev`.

**2. Collect**
```bash
mkdir -p .orchestra/2026-11-23-dependabot/{tasks,logs}
<skill-base>/scripts/alerts.sh sxntixgo/learn > .orchestra/2026-11-23-dependabot/alerts.tsv
wc -l < .orchestra/2026-11-23-dependabot/alerts.tsv   # baseline: expect 15
```

**3. Triage**, following `references/triage.md`, for each row:
```bash
npm ls <pkg> --all
npm view <parent>@<installed> dependencies.<pkg>   # does the range allow first_patched?
```
Then I'd write `.orchestra/2026-11-23-dependabot/triage.md`. This content is assumed:

```markdown
# Dependabot triage — sxntixgo/learn (main), 2026-11-23
Baseline: 15 open (2 high, 11 moderate, 2 low)

| # | package | sev | scope | pulled by | kind | task |
|---|---|---|---|---|---|---|
| 41 | cross-spawn | high | dev | eslint | lockfile | T1 |
| 42 | path-to-regexp | high | runtime | express@4 | lockfile | T1 |
| 43–47 | nanoid, micromatch, braces, postcss, @babel/helpers | moderate | dev | vite, jest, tailwind | lockfile | T1 |
| 48 | vite | moderate | dev | (direct) | same-major | T1 |
| 49 | body-parser | moderate | runtime | express@4 | lockfile | T1 |
| 50–51 | esbuild (×2) | moderate | dev | vite@5 | major (vite 5→6) | T2 (if approved) |
| 52 | send | moderate | runtime | express@4 | lockfile | T1 |
| 53 | cookie | low | runtime | express@4 | lockfile | T1 |
| 54 | brace-expansion | low | dev | glob | lockfile | T1 |
| 55 | (pkg) | moderate | dev | … | no fix (first_patched none) | — |

## Proposed majors
- vite 5 → 6 (closes #50–51). Requires Node ≥ 18.18/20+ (CI pins Node 20: OK).
  Peer deps: @vitejs/plugin-react must move to ≥ 4.3.4. Dockerfile build stage is unaffected (runtime image ships no vite).
```

**4. ⛔ Gate 1.** I stop here, and nothing is dispatched until you reply.

After you answer, the run would continue:
- **Write tasks** with claude-write-task: T1 for the lockfile and same-major rows, and T2 for vite 6 if you approve it (`depends_on: [T1]`). Each task's Done-when lists the exact GHSA ids that must be gone from `npm audit` and `npm audit --omit=dev`, `npm ci && npm test && npm run build` passing, and a diff limited to `package.json` and `package-lock.json`.
- **Dispatch** with claude-dispatch. T2 has to wait for T1 because they share a lockfile.
- **Review and merge** each result with claude-review-merge, using the config's `review_model` (default sonnet). It rejects any `--force` or `--legacy-peer-deps` use, hand-edited lockfiles, or a major bump slipped into T1.
- **Verify** on the merged branch: `npm audit`, then the full test and build. Then update `triage.md` with fixed and remaining.
- **⛔ Gate 2** before any push.

## Final message to you

The 15 alerts on `sxntixgo/learn` (`main`) are triaged and nothing is dispatched yet. (Dry run: the breakdown below is assumed.)

| kind | alerts | task |
|---|---|---|
| lockfile / same-major | 12 | T1 (one lockfile task) |
| major (vite 5 → 6) | 2 (esbuild) | T2, needs your OK |
| no fix upstream | 1 | stays open (reported, not dismissed) |

**4 alerts reach production:** `path-to-regexp` (high), `body-parser`, `send` and `cookie`. All four come in through express 4 at runtime and are in the deployed image. T1 fixes them with a lockfile update, with no express major bump. The other 11 are development-only.

**Your call:**
1. Should T2 (vite 5 → 6) be included? It also needs `@vitejs/plugin-react` ≥ 4.3.4. CI's Node 20 is fine, and it doesn't change the runtime image.
2. No override is proposed. The no-fix alert stays open and is listed with its GHSA id.

Once you answer, I'll write the tasks and run them through opencode on atlas. Nothing gets pushed until you've seen the test and build results and the list of alerts expected to close.