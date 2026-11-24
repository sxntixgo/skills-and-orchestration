I'd create the skill as `skills/summarize-diff/`, following `skill-creator` and then reviewing it with `skill-reviewer`, as CLAUDE.md requires. Here are the steps in order:

**1. Invoke `skill-authoring:skill-creator`.** I'd add TodoWrite items: scaffold, write SKILL.md, write evals, review, baseline eval, update docs.

**2. Write `skills/summarize-diff/SKILL.md`:**
```markdown
---
name: summarize-diff
description: Summarizes the uncommitted git diff (staged, unstaged, untracked) into 3-6 bullets and flags risky changes - migrations, auth/permissions, deleted or skipped tests. Use when the user asks for a summary of their changes, "what did I change", or a recap before committing.
---
# Summarize diff
**Does:** read-only summary of uncommitted work plus risk flags. **Does NOT:** commit, stage, edit files, or do a full code review.

## Checklist (TodoWrite)
1. Collect: `git status --porcelain`, `git diff HEAD --stat`, `git diff HEAD`, `git ls-files --others --exclude-standard`. If there's no HEAD yet, use `git diff --cached`. If the diff is empty, say "No uncommitted changes" and STOP.
2. Write the raw stat and file list to `.claude-skills-work/summarize-diff/collect.md`. To resume, start from this file.
3. Scan for risks (table below). Base every flag on a file path or hunk.
4. Write the summary to `.claude-skills-work/summarize-diff/summary.md` and print it.

## Risk triggers
| Flag | Look for |
|---|---|
| Migration | `migrations/`, `db/migrate/`, `alembic/`, `*.sql`, `schema.prisma`, ALTER/DROP |
| Auth | auth, login, session, token/JWT, password, permission/role checks, middleware guards |
| Deleted tests | deleted test files, removed test functions, added `skip`/`xfail`/`.only` |

## Output
- **Summary** (3-6 bullets): grouped by intent, not by file; name the key files.
- **Risky changes:** one line per flag, `⚠ <type> - <file>: <why>`, or "None found."

## Red flags
- More than 6 bullets, or a list of every file → group by intent.
- Flagging risk without a matching hunk → drop the flag.
- Starting a code review or suggesting fixes → out of scope; offer `code-review` instead.
- Leaving out untracked files → include them.
```

**3. Write `skills/summarize-diff/evals/evals.json`** (`skill_name: summarize-diff`), with fixtures in `evals/files/`:
- `migration.diff`: adds a migration plus model changes. Expect a ⚠ Migration flag naming the file, and 3-6 bullets.
- `auth.diff`: weakens a role check in middleware. Expect an ⚠ Auth flag.
- `deleted-tests.diff`: deletes `test_billing.py` and adds `@pytest.mark.skip`. Expect two deleted-tests flags.
- `benign.diff`: README and CSS changes only. Expect "None found" and no invented risks.
- `large.diff`: 25 files. Expect at most 6 bullets, grouped by intent.

**4. Invoke `skill-authoring:skill-reviewer`** on the new skill. For the baseline comparison, I'd spawn paired subagents (`model: claude-sonnet-5-5`) per case, one with the skill and one without. The prompt: "Summarize my uncommitted changes. Diff: <fixture>". Results would be aggregated into `.claude-skills-work/evals/summarize-diff/iteration-1/benchmark.json` (pass rate, tokens, time).

**5. Update docs:** add the skill to the README list, change "8 skills" to 9 in CLAUDE.md, and tick `plan.md`. Nothing is committed or pushed.

**Final reply:**

> Created `skills/summarize-diff/` with SKILL.md and 5 eval cases. It triggers on requests like "summarize my changes" and flags migrations, auth changes, and deleted or skipped tests. One concern: models already summarize diffs well, so the evals may show little benefit from the skill. If `benchmark.json` shows no gain over running without it, I'd cut it rather than ship it. The risk-flag checklist is the part most likely to improve results. Run `/reload-plugins` to try it as `frugal-skills:summarize-diff`.