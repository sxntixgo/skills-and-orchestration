# Triage: from an alert to a fix kind

Do this per manifest/lockfile, for every alert row from `scripts/alerts.sh`.

## 1. Find who pulls the vulnerable package
| Ecosystem | Command (run in the manifest's folder) |
|---|---|
| npm | `npm ls <pkg> --all` (the top-level name on each path is the direct dependency) |
| pip (requirements*.txt) | `grep -n -i '^<pkg>' requirements*.txt`; transitive: `pipdeptree -r -p <pkg>` if installed, else read the lock/requirements |
| uv | `uv tree --invert --package <pkg>` |
| pnpm | `pnpm why <pkg>` |

## 2. Pick the kind
| Kind | When | Fix (the task's Steps) |
|---|---|---|
| **lockfile** | every path allows `first_patched` within its current range | npm: `npm update <pkg>` (or `npm audit fix`, never `--force`); uv: `uv lock --upgrade-package <pkg>`; pnpm: `pnpm update <pkg>` |
| **same-major bump** | a direct dependency must move to a newer minor/patch (same major) to allow the patched version | bump that direct dependency's range in the manifest, reinstall to regenerate the lock |
| **major** | only a new major of a direct dependency allows the patched version | its own task; claude-write-task's version-bump step (peer deps, engines, CI/Dockerfile pins) is mandatory |
| **pin** | pip `requirements.txt` with `==`/`>=` pins | raise the pin to `>= first_patched` (the books msgpack/urllib3 fix of 2026-11-21 is the pattern) |
| **no fix** | `first_patched` is `none` | report only (with the GHSA id); do not dismiss |
| **override** (last resort) | a transitive dep is fixed upstream but the parent pins an old range and has no fixed release | npm `overrides` / pnpm `overrides` entry — only after the user OKs it at gate 1 (it can break the parent) |

To check "allows": `npm view <parent>@<installed> dependencies.<pkg>` gives the range; compare with `first_patched`.

## 3. Group into tasks
- One task per lockfile for all its **lockfile** + **same-major** + **pin** rows (they touch the same files).
- One task per **major** the user picked (it touches the same manifest: make it depend on the lockfile task).
- Tasks on different lockfiles (e.g. `web/` and `mobile/`) can run in parallel.

## Done-when lines that work
- `npm audit --omit=dev` and `npm audit` no longer list <GHSA ids> (paste the ids)
- `npm ci && npm test && npm run build` pass (or the repo's own commands from CLAUDE.md/README/CI)
- pip: `pip install -r requirements.txt` resolves; tests pass; `pip-audit -r requirements.txt` if available
- `git diff --stat` touches only the manifest and its lockfile (plus files a major forces)
