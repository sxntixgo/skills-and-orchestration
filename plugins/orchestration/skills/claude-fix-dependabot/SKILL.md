---
name: claude-fix-dependabot
description: Fixes a GitHub repo's open Dependabot security alerts by triaging them (lockfile-only, same-major bump, major bump, no fix) and orchestrating the fixes as opencode tasks on atlas, with Claude reviewing and merging. Use when the user asks to fix, clear or triage Dependabot / security / vulnerability alerts for a repo, or when a git push printed "GitHub found N vulnerabilities on <repo>'s default branch" and the user wants them fixed.
---

# Fix Dependabot alerts

Claude triages and reviews; opencode implements. Turn the open alerts into a few small,
verifiable tasks (one per lockfile, one per approved major bump) and run them through the normal
orchestration flow. Most alerts in these repos are development-only JS packages: fix them, but
say plainly which ones reach production (runtime scope, in a deployed image).

## Scope
This skill DOES:
- Read open alerts (`scripts/alerts.sh <owner/repo>`), classify each, plan and run fix tasks.
- Use the plugin's run conventions (`../../contract.md`): board, task files, worktrees, dispatch, review.
- Report fixed vs remaining alerts, runtime vs development, and which deployed apps would change.

This skill does NOT:
- Dismiss, snooze or comment on alerts, or change Dependabot settings.
- Push, open PRs or deploy without the user's OK (deploys are a separate ask).
- Use `npm audit fix --force`, `--legacy-peer-deps`, or hand-edit lockfiles; make unrelated upgrades.

## Steps (one TodoWrite item each)
1. **Preflight.** Repo clean, on the default branch, up to date with origin; `gh auth status` OK;
   atlas reachable (the dispatcher checks too). Note the repo's test/build commands (CLAUDE.md,
   README, CI workflow).
2. **Collect.** `scripts/alerts.sh <owner/repo> > .orchestra/<date>-dependabot/alerts.tsv`
   (relative to this skill's base directory for the script). Count rows; this is the baseline.
3. **Triage** each row with `references/triage.md`: who pulls it, which kind (lockfile /
   same-major / major / pin / no fix / override). Write `triage.md` in the run folder: a table
   alert# → package → scope → kind → task id, plus the proposed majors with what they force
   (peer deps, Node/engine, CI and Dockerfile pins).
4. ⛔ **STOP — gate 1.** Show the triage table summary (counts per kind, runtime alerts called out)
   and ask which majors (and any override) to include. Nothing is dispatched before the answer.
5. **Write tasks** (claude-write-task): one per lockfile for its lockfile/same-major/pin rows,
   one per approved major (depends on its lockfile's task). Steps name the exact commands; Done-when
   names the GHSA ids that must disappear from `npm audit` and the repo's test + build commands.
6. **Dispatch** (claude-dispatch) up to the repo's `concurrency`; tasks on different lockfiles run
   in parallel. **Review and merge** each result (claude-review-merge): diff touches only the
   manifest + lockfile (+ files a major forces), no `--force` traces, tests and build pass.
7. **Verify on the merged branch:** rerun `scripts/alerts.sh`-equivalent locally (`npm audit`,
   `pip-audit`/pin check) and the full test + build. Update `triage.md` with fixed / remaining
   (reason for each remaining one).
8. ⛔ **STOP — gate 2.** Show: merged tasks, test/build results, alerts expected to close vs remain,
   deployed apps whose runtime image changes. Push only on the user's OK; then confirm CI is green
   and the alert count on GitHub dropped (it can take a few minutes to refresh).

## Checkpoints
Everything lives in `.orchestra/<date>-dependabot/` (alerts.tsv, triage.md, board.md, tasks/,
logs/). To resume, read board.md and triage.md and continue from the first unfinished step.

## Red flags (stop and correct)
| If you notice… | Do this |
|---|---|
| A task or result using `--force` / `--legacy-peer-deps` | Reject; find the direct dependency to bump, or propose an override at gate 1 |
| A lockfile diff with no manifest reason, or a hand-edited lockfile | Reject; regenerate with the package manager |
| A major bump sneaking into a lockfile task | Split it out; it needs gate 1 approval and the peer/engine check |
| Calling an alert "fixed" because tests pass | Fixed = the GHSA id is gone from `npm audit` / the pin is ≥ first patched |
| About to dismiss an alert as "dev only" | Don't; fix it or list it as remaining with the reason |
| Alerts on a non-default branch's code | Alerts are for the default branch; work there (merge feature branches first or ask) |
| Pushing before gate 2 | Stop and ask |

## Done when
- triage.md lists every baseline alert with its kind and outcome (fixed / remaining + reason).
- All approved tasks merged, the repo's tests and build pass on the merged branch.
- After the user's OK: pushed, CI green, GitHub's open-alert count reflects the fixes.

## References (load only when needed)
- `references/triage.md` — step 3: who pulls a package, kind table, task grouping, Done-when lines.
- `scripts/alerts.sh` — step 2 (and `--file` for a saved JSON reply, used by the evals).
