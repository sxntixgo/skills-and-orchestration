Drafted `skills/summarize-diff/`. Here's what I'd do, in order.

**1. TodoWrite:** Draft SKILL.md · Write evals + fixtures · Validate · Reply

**2. Write `skills/summarize-diff/SKILL.md`**
```markdown
---
name: summarize-diff
description: Summarizes the uncommitted git changes (staged, unstaged and untracked) into 3-6 bullets and flags risky changes such as migrations, auth/permission code and deleted tests. Use when the user asks to "summarize my changes", "what did I change", "summarize my diff" or wants a recap before committing.
---
# Summarize Diff
Give a short, accurate recap of *all* uncommitted work and call out what deserves a second look.

## Scope
DOES: read the working tree diff; write 3-6 bullets and a risk list.
Does NOT: stage, commit, stash or edit files; review code quality (→ `code-review`).

## Steps (TodoWrite items; output in `./.claude-skills-work/summarize-diff/summary.md`)
1. `git rev-parse --is-inside-work-tree`. If this fails, ⛔ say "not a git repo" and stop.
2. Run these in one batch: `git status --porcelain`, `git diff HEAD --stat`,
   `git diff HEAD --diff-filter=D --name-only`. `git diff` alone misses staged changes, and
   neither command shows untracked files, so take those from `status` (`??`).
3. If nothing changed, reply "No uncommitted changes." and stop. Don't print bullets.
4. Read `git diff HEAD -- <file>` file by file, starting with the biggest. If the diff is over
   ~2k lines, summarize the smallest files from `--stat` alone.
5. Flag risks using the table below. Each flag names the file, and the line where possible.
6. Write the output in the format below to the checkpoint file, then print it.

## Risk table
| Flag | Match |
|---|---|
| MIGRATION | `migrations/`, `*.sql`, `alembic/`, `schema.rb`, `prisma/schema` |
| AUTH | paths or hunks touching auth, login, session, token, password, permission, role, CORS, secrets |
| DELETED TEST | test file deleted (filter=D), or a removed `def test_`/`it(`/`test(` with no replacement |
| CONFIG/SECRETS | `.env*`, CI workflows, dependency lockfile major bumps |

## Output format
Changes (N files, +A/-D):
- <3-6 bullets, by intent not by file; group related files>
Risks:
- [FLAG] path:line — why
(or `Risks: none found`)

## Red flags
| If you notice… | Do this |
|---|---|
| Used `git diff` only | Add staged changes (`HEAD`) and untracked files |
| One bullet per file, or more than 6 | Group by intent |
| A risk with no path | Add the path, or drop it |
| About to commit or fix something | Don't. Only summarize |

## Done when
The summary is written and printed, with 3-6 bullets and every risk tied to a path.
```

**3. Write the fixtures** (each one is the assumed `git status` plus `git diff HEAD` output):
- `evals/files/risky.patch`: adds `db/migrations/0042_add_role.sql`, edits `src/auth/session.py:31` (token expiry raised from 1h to 30d), and has an untracked `notes.txt`.
- `evals/files/deleted-test.patch`: deletes `tests/test_billing.py` and edits `src/billing.py`.
- `evals/files/docs-only.patch`: changes `README.md` and `docs/setup.md` only.

**4. Write `skills/summarize-diff/evals/evals.json`**
```json
{"skill_name":"summarize-diff","evals":[
 {"id":"risky-migration-auth","prompt":"summarize my changes","files":["evals/files/risky.patch"],
  "expected_output":"3-6 bullets; flags MIGRATION and AUTH","assertions":[
   "Output has between 3 and 6 bullets under 'Changes'",
   "A MIGRATION flag names db/migrations/0042_add_role.sql",
   "An AUTH flag names src/auth/session.py:31",
   "Mentions the untracked notes.txt"]},
 {"id":"deleted-test","prompt":"what did I change?","files":["evals/files/deleted-test.patch"],
  "expected_output":"flags the deleted test file","assertions":[
   "A DELETED TEST flag names tests/test_billing.py",
   "No git add/commit/stash command is run"]},
 {"id":"benign-docs","prompt":"summarize my diff before I commit","files":["evals/files/docs-only.patch"],
  "expected_output":"short summary, no risks","assertions":[
   "Contains 'Risks: none found'",
   "Bullet count is 3-6, or fewer only if there are fewer than 3 distinct changes"]},
 {"id":"clean-tree-stop","prompt":"summarize my changes","files":[],
  "expected_output":"git status is empty; replies with no changes and stops","assertions":[
   "Reply contains 'No uncommitted changes'",
   "Reply contains no 'Changes (' header and no bullets"]}
]}
```

**5. Validate**
```
python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/summarize-diff
```
Assumed result: `CHECK skills/summarize-diff: PASS`. If there are FAILs, fix them and rerun.

**6. Reply to the user**

I created `skills/summarize-diff/`. It summarizes uncommitted git changes (staged, unstaged and untracked) into 3-6 bullets and flags migrations, auth code and deleted tests. It fires when you ask to "summarize my changes", "what did I change" or "summarize my diff".

`CHECK skills/summarize-diff: PASS`

Eval cases:
- **risky-migration-auth:** flags the migration file and `session.py:31` by path, and catches the untracked file.
- **deleted-test:** flags `tests/test_billing.py` and changes nothing in the repo.
- **benign-docs:** short summary ending with "Risks: none found".
- **clean-tree-stop:** says "No uncommitted changes" and prints no bullets.

Assumptions:
- "Uncommitted" includes staged changes and untracked files.
- I added a CONFIG/SECRETS flag (`.env`, CI files, lockfiles). Drop it if you only want the three you listed.
- The skill only summarizes and never stages or commits.

Approve, or what should change? Next step: run `skill-authoring:skill-reviewer` on it for the with/without-skill comparison.