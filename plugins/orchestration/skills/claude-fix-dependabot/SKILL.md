---
name: claude-fix-dependabot
description: Fixes a GitHub repo's open Dependabot security alerts by triaging them (lockfile-only, same-major bump, major bump, no fix) and orchestrating the fixes as opencode tasks on atlas, with Claude reviewing and merging. Use when the user asks to fix, clear or triage Dependabot / security / vulnerability alerts for a repo, or when a git push printed "GitHub found N vulnerabilities on <repo>'s default branch" and the user wants them fixed.
---

# Fix Dependabot alerts

Claude triages and reviews; opencode implements. Turn the open alerts into a few small, verifiable
tasks (one per lockfile, one per approved major) and run them through the orchestration flow
(`claude-write-task` → `claude-dispatch` → `claude-review-merge`). Most alerts are dev-only JS
packages: fix them, but say plainly which reach production (runtime scope, in a deployed app).
Everything you need is on this page: don't open `contract.md` or the script.

## Scope
DOES: read open alerts, classify each, plan and run fix tasks; report fixed vs remaining, runtime
vs development, and which deployed apps change.
Does NOT: dismiss, snooze or comment on alerts, or change Dependabot settings; push, open PRs or
deploy without the user's OK; use `npm audit fix --force`, `--legacy-peer-deps` or hand-edited
lockfiles; make unrelated upgrades.

## Steps (one TodoWrite item each; state in `.orchestra/<date>-dependabot/`)
1. **Preflight.** Repo clean, on the default branch, up to date; `gh auth status` OK; model server
   reachable; `.orchestra/config.json` `base_branch` = default branch (alerts are for it). Note the
   repo's test/build commands (CLAUDE.md, README, CI). Look for earlier fix work:
   `git branch -a | grep -iE 'deps|security|dependabot'`, `gh pr list --author app/dependabot`; an
   unmerged fix branch → offer reuse (rebase, regenerate lockfile, verify) or supersede, at gate 1.
   Several repos → one run per repo, in turn.
2. **Collect:** `<skill-dir>/scripts/alerts.sh <owner/repo> > .orchestra/<date>-dependabot/alerts.tsv`
   (or `alerts.sh --file <saved.json>` for a saved API reply). TSV columns: number, severity,
   scope (runtime/development), ecosystem, manifest, package, vulnerable range, first patched
   (`none` = no fix), GHSA id. The row count is the baseline.
3. **Triage** each row: find who pulls it (npm `npm ls <pkg> --all`; pnpm `pnpm why`; uv
   `uv tree --invert --package`; pip: the requirements pins) and whether each path's range allows
   `first_patched` (`npm view <parent>@<installed> dependencies.<pkg>`). Kind:
   | Kind | When | Fix |
   |---|---|---|
   | lockfile | every path allows the patched version | `npm update <pkg>` / `pnpm update` / `uv lock --upgrade-package` |
   | same-major | a direct dep must move within its major | bump its range, reinstall |
   | major | only a new major of a direct dep fixes it | own task, after gate 1; check peers/engines/CI/Dockerfile pins |
   | pin | pip `==`/`>=` pin | raise to `>= first_patched` |
   | no fix | first patched = none | report with the GHSA id + options (replace the dep, override/remove); never dismiss |
   | override | parent pins an old range and has no fixed release | npm/pnpm `overrides`, only if OK'd at gate 1 |
   Write `triage.md`: alert → package → scope → kind → task, plus proposed majors and what they force.
4. ⛔ **Gate 1.** Show counts per kind, runtime alerts called out (and in which app), the tasks
   (one per lockfile, parallel across lockfiles), the majors/overrides on offer; ask which to
   include. Dispatch nothing before the answer.
5. **Tasks:** one per lockfile (its lockfile/same-major/pin rows), one per approved major
   (depends on its lockfile task). Steps name exact commands and target versions; Done when:
   the GHSA ids gone from `npm audit` (list them), the repo's test + build pass, `git diff --stat`
   touches only manifest + lockfile (+ files a major forces).
6. **Dispatch** up to `concurrency`; **review** each result: only manifest + lockfile changed, no
   `--force` traces, tests + build pass. On reject, notes name the allowed fix exactly
   (e.g. "`npm update vite` → 8.1.6, the first patched 8.x; no major").
7. **Verify on the merged branch:** each targeted GHSA id gone from `npm audit` (per lockfile
   folder), pins ≥ first patched, full test + build. Update `triage.md`: fixed / remaining + reason.
8. ⛔ **Gate 2.** Show merged tasks, test/build results, alerts expected to close vs remain,
   deployed apps whose runtime changes. Push only on OK; then check CI is green and GitHub's alert
   count dropped (it refreshes after a few minutes).

Resume: read `board.md` and `triage.md`, continue from the first unfinished step.

## Red flags
| If you notice… | Do this |
|---|---|
| `--force` / `--legacy-peer-deps` in a task or result | Reject; bump the direct dep, or offer an override at gate 1 |
| A major bump inside a lockfile task | Reject/split it; majors need gate 1 + the peer/engine check |
| Lockfile diff with no manifest reason, or hand-edited | Reject; regenerate it |
| "Fixed" because tests pass | Fixed = GHSA id gone from `npm audit` / pin ≥ first patched |
| Dismissing an alert ("dev only", "no fix") | Don't; fix it or list it as remaining with the reason |
| Work on a non-default branch | Alerts are for the default branch |
| An old `deps/…` branch already fixes it | Reuse or supersede it explicitly (gate 1) |
| Pushing before gate 2 | Stop and ask |

## Done when
`triage.md` lists every baseline alert with kind and outcome; approved tasks merged; tests + build
pass on the merged branch; after the OK: pushed, CI green, GitHub's alert count reflects the fixes.
