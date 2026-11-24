## What I'd do, in order

**1. TodoWrite:** read context · draft SKILL.md · write evals + fixtures · validate · reply.

**2. Read in one parallel batch:** `CLAUDE.md` (already loaded) and one sibling for house style, `skills/code-review/SKILL.md`. I'm assuming it uses the standard skeleton and that its description covers "review my code/diff/PR". That overlap is why the new description says "summary, not a review".

**3. The request is clear enough to draft without asking.** Name: `diff-summary`.

**4. Write `skills/diff-summary/SKILL.md`:**

```markdown
---
name: diff-summary
description: Summarizes the uncommitted git changes (staged, unstaged, untracked) into 3-6 bullets and flags risky ones: migrations, auth/permission code, deleted or disabled tests. Use when the user asks to summarize, recap or describe "my changes", "my diff" or "what I changed". Not a code review (→ code-review).
---
# Diff Summary
A short, read-only summary of what changed. Risk flags come from the diff itself, not guesses.

## Scope
DOES: read the uncommitted diff; write 3-6 bullets; flag risky changes with file paths.
Does NOT: review code quality or find bugs (→ code-review); commit, stage, stash or edit files; summarize commits that are already made unless the user asks.

## Steps (TodoWrite items; single pass, output goes to chat)
1. Run `git status --porcelain` and `git diff HEAD --stat`. If there is no repo or the tree is clean, say so and STOP. Don't fall back to the last commit.
2. Read `git diff HEAD`. Untracked files don't show up in it, so list them from the status output and read the ones that matter. Skip lockfiles, generated files and vendored files (name them in one line). If the diff is over ~3000 lines, work from `--stat` and read only the hunks in risky paths.
3. Flag a change only when the diff shows it:
   | Flag | Evidence |
   |---|---|
   | migration | new or changed file under `migrations/`, `alembic/`, `db/migrate/`, `*.sql`; schema/model field changes |
   | auth | code touching login, session, token/JWT, password, permission/role checks, auth middleware, CORS/CSRF settings |
   | deleted-test | test file deleted; test function or assertion removed; `skip`/`xfail`/`.only` added |
4. Reply using exactly this template:
   **Summary** (<N> files, +<A>/−<D>)
   - <3-6 bullets, grouped by intent rather than by file>
   **⚠ Risky**
   - [<flag>] `<path>`: <what changed, one line>
   (or `⚠ Risky: none found`)

## Red flags
| If you notice… | Do this |
|---|---|
| Writing one bullet per file | Group by intent, 6 bullets at most |
| Flagging something as "might affect auth" without a matching hunk | Drop it, or quote the line |
| Missing untracked files | Check the `??` lines from step 1 |
| Commenting on bugs or style | Not this skill; suggest code-review |
| Clean tree, so summarizing HEAD~1 instead | Say there are no changes and stop |

## Done when
The reply follows the template with 3-6 bullets, and every flag names a path backed by the diff.
```

**5. Write `skills/diff-summary/evals/evals.json`** (4 cases) and fixtures in `evals/files/`:

| id | prompt / fixture | assertions |
|---|---|---|
| `migration-auth` | "Summarize my changes" + `migration_auth.diff` (new `migrations/0042_add_role.py`, edit to `app/auth/middleware.py`, UI tweak) | has 3-6 summary bullets · flags `[migration]` with `migrations/0042_add_role.py` · flags `[auth]` with `app/auth/middleware.py` · doesn't flag the UI file |
| `deleted-tests` | "what did I change?" + `deleted_tests.diff` (deletes `tests/test_billing.py`, adds `@pytest.mark.skip` in `tests/test_api.py`) | flags the deleted file by path · flags the added skip by path · has 3-6 bullets |
| `benign-refactor` | "recap my diff" + `refactor.diff` (rename, docs, formatting) plus untracked `README_dev.md` in `status.txt` | says "Risky: none found" · mentions the untracked file · has 3-6 bullets |
| `clean-tree` (stop) | "summarize my changes" + `clean_status.txt` (empty porcelain output, `git diff HEAD` empty) | says there are no uncommitted changes · has no bullets and no Risky section · doesn't summarize past commits |

Each case uses the shape `{id, prompt, expected_output, files, assertions}` with `skill_name: "diff-summary"`.

**6. Validate:** `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/diff-summary`, then fix every FAIL, decide each WARN, and rerun until it's clean. I'm assuming it ends clean at about 2.4k chars.

**7. Final reply:**

---

I drafted `skills/diff-summary/` (SKILL.md is about 2.4k chars and passes `check_skill.py`) with 4 eval cases.

**Description:** "Summarizes the uncommitted git changes (staged, unstaged, untracked) into 3-6 bullets and flags risky ones: migrations, auth/permission code, deleted or disabled tests. Use when the user asks to summarize, recap or describe "my changes", "my diff" or "what I changed". Not a code review (→ code-review)."

**Eval cases:**
- `migration-auth`: flags the migration and the auth middleware by path, and leaves the UI change unflagged.
- `deleted-tests`: flags a deleted test file and an added `skip`.
- `benign-refactor`: reports "none found" and still mentions the untracked file.
- `clean-tree`: stops and says there are no changes, without falling back to the last commit.

**Assumptions:**
- "Uncommitted" means `git diff HEAD` plus untracked files.
- The output goes to chat only. It's a single read-only pass, so it writes no checkpoint file.
- Lockfiles and generated files are skipped.
- Risk is judged from paths and hunks, not guesses.
- It doesn't overlap `code-review` because it never judges code quality.

Approve, or what should change? The next step is `skill-reviewer` (profile + baseline). After that I'd tick `plan.md` and add the skill to the README.