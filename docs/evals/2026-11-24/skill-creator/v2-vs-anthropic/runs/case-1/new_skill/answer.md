I'd create `skills/diff-summary/`. This is a dry run, so I haven't run anything and the sizes and check results below are expected values, not measured ones.

**1. Read in one parallel batch**
- `CLAUDE.md` (already loaded)
- `skills/code-review/SKILL.md`, to match house style and check that the two triggers don't clash. I'm assuming it follows the skeleton and triggers on "review".

**2. Clarity check.** The request is clear, so I'd draft without asking first.

**3. Write `skills/diff-summary/SKILL.md`**
```markdown
---
name: diff-summary
description: Summarizes the uncommitted git diff (staged, unstaged, untracked) into 3–6 bullets and flags risky changes: migrations, auth code, deleted or disabled tests. Use when the user asks to "summarize my changes", "what did I change", "sum up my diff" or wants a recap before committing. Not a code review (→ code-review).
---
# Diff Summary
A short recap of uncommitted work, plus the changes worth a second look. No review and no fixes.

## Scope
DOES: read `git diff HEAD` and untracked files, write 3–6 bullets and a risk list.
Does NOT: review quality or bugs (→ `code-review`), suggest fixes, stage, commit or stash.

## Steps (TodoWrite items; output in `./.claude-skills-work/diff-summary/summary.md`)
1. Run `git status --porcelain` and `git diff HEAD --stat`.
   - Not a repo, or both empty → reply "No uncommitted changes." and stop.
2. Read `git diff HEAD`, one file at a time if the stat shows more than ~500 lines. Untracked files: read only the paths and head of each file.
3. Flag risks by **content**, not just by path:
   | Flag | Signals |
   |---|---|
   | migration | `migrations/`, `alembic/`, `*.sql`, schema DDL (`ALTER`/`DROP`/`CREATE TABLE`), ORM model field changes |
   | auth | login/session/token/JWT/OAuth/password/permission/role checks, auth middleware, crypto |
   | deleted tests | a deleted test file, removed test functions or assertions, newly added `skip`/`xit`/`@Disabled` |
4. Write the template below to the output file and the reply.

## Output
**Summary** — N files, +A/−D
- <3–6 bullets, by intent ("Adds X to Y"), not one per file>
**⚠ Risky**
- [migration|auth|deleted tests] `path:line` — <what and why, one line>
(or `⚠ Risky: none found`)

## Red flags
| If you notice… | Do this |
|---|---|
| One bullet per file, or more than 6 | Group by intent |
| Flagging from the filename alone | Cite the changed line |
| Commenting on code quality or suggesting fixes | Drop it; offer `code-review` |
| Only `git diff` (missing staged or untracked files) | Use `git diff HEAD` + `status` |

## Done when
3–6 bullets, every risk has `path:line` and a category, and the summary file is written.
```

**4. Write `skills/diff-summary/evals/evals.json`** (4 cases), plus fixtures in `evals/files/`: `migration_feature.diff`, `auth_tests.diff` and `docs_only.diff`.

| id | prompt | assertions |
|---|---|---|
| 1 | "Summarize my changes" + `migration_feature.diff` (new column migration + API endpoint) | 3–6 bullets; flags `[migration]` with the migration file:line; doesn't flag the endpoint as auth |
| 2 | "What did I change?" + `auth_tests.diff` (token expiry edit, deleted `test_login.py`) | flags `[auth]` with file:line for the expiry change; flags `[deleted tests]` naming `test_login.py`; no fix suggestions |
| 3 | "Sum up my diff before I commit" + `docs_only.diff` (README + CSS) | says "Risky: none found"; 3–6 bullets; no `git commit` run |
| 4 | "Summarize my uncommitted changes" with an empty diff | replies that there are no uncommitted changes; writes no bullets; flags no risks |

**5. Validate:** `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/diff-summary`, then fix every FAIL and rerun until it's clean. I expect the size line to be about 2.6k chars.

---

**Reply to user:**

I drafted `skills/diff-summary/` and the check should pass (SKILL.md about 2.6k chars).

**Description:** Summarizes the uncommitted git diff (staged, unstaged, untracked) into 3–6 bullets and flags risky changes: migrations, auth code, deleted or disabled tests. It fires on "summarize my changes", "what did I change", "sum up my diff" or a recap before committing. It points actual code reviews to `code-review`.

**Eval cases:**
1. Migration plus endpoint: flags only the migration, with `path:line`.
2. Auth change plus deleted test file: flags both.
3. Docs and CSS only: "Risky: none found", and it doesn't commit.
4. No changes: stops with "No uncommitted changes."

**Assumptions:**
- "Uncommitted" includes staged, unstaged and untracked files.
- "Deleted tests" also covers tests that were newly skipped or disabled.
- The skill saves its summary to `.claude-skills-work/diff-summary/summary.md` so the work can be resumed later.
- It flags only your three risk types, nothing more (no secrets or dependency changes).

Approve, or what should change? The next step is `skill-reviewer` (profile + baseline comparison).