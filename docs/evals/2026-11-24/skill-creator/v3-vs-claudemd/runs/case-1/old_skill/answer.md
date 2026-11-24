Below is the full plan for the new `skills/summarize-changes/` skill. I'd follow the repo's working agreements: draft it with `skill-creator`, then check it with `skill-reviewer`.

**One risk before I start.** Summarizing a diff is something the model already does well, and CLAUDE.md warns that skills restating known behaviour show no gain (`security-review` measured 0.00). This skill has to earn its cost through process the model doesn't already follow: a fixed 3–6 bullet format, risk checks run in a fixed order with no invented flags, untracked files included, and a clean stop on an empty diff. If the baseline comparison shows no gain, I'd recommend not shipping it.

## Steps

1. **Load the authoring skill:** `skill-authoring:skill-creator`.
2. **Check for overlap:** look at the names and descriptions in `skills/*/SKILL.md`. I'm assuming no `summarize-changes` exists, and that `code-review` covers reviewing changes for problems, not summarizing them. The two descriptions must not compete, so this one says "not a review".
3. **Track progress with TodoWrite:** draft `SKILL.md` → evals + fixtures → review and baseline → update `plan.md`/`README.md`.
4. **Write `skills/summarize-changes/SKILL.md`:**

```markdown
---
name: summarize-changes
description: Summarizes the uncommitted git diff (staged, unstaged, untracked) into 3-6 bullets and flags risky changes - migrations, auth, deleted or skipped tests. Use when the user asks for a summary of their changes, "what did I change", or a recap of their working tree before committing. Not a code review.
---

# Summarize changes

**Does:** summarize uncommitted work and flag the 3 risk types below. **Does NOT:** review code quality, suggest fixes, commit, or summarize history/PRs (use code-review for review).

## Checklist (TodoWrite)
1. Collect: `git status --porcelain`, `git diff HEAD --stat`, `git ls-files --others --exclude-standard`.
   - Not a repo → say so, STOP. Empty diff and no untracked files → "No uncommitted changes.", STOP.
2. Read hunks: `git diff HEAD -- <path>` for files a risk rule matches, plus the largest files until intent is clear. For >2000 changed lines, rely on --stat for the rest and say so.
3. Run risk checks (table). Flag only on evidence; cite file (+line if known).
4. Write the output (format below) to `.claude-skills-work/summarize-changes/summary.md`, then print it.

## Risk checks
| Flag | Evidence |
|---|---|
| MIGRATION | new/changed files under `migrations/`, `alembic/`, `db/migrate/`, `*.sql`; schema/model field changes |
| AUTH | changes touching auth, login, session, token, JWT, OAuth, password, permission/role checks, auth middleware |
| TESTS REMOVED | deleted test files; removed test functions/assertions; added skip/xfail/`.only` |

## Output
**Summary** - 3-6 bullets, grouped by intent (not one per file), each naming the files.
**Risks** - one line per flag: `MIGRATION: db/migrate/0042_add_col.rb - adds non-null column`. If none: "No risky changes detected."

## Red flags
- More than 6 or fewer than 3 bullets → merge or split. (1 tiny change → 1 bullet is allowed; say so.)
- Flagging something "might be risky" without evidence from the table → drop it.
- Inventing new risk categories or giving review advice → out of scope.
- Ignoring untracked files → they count as changes.
```

5. **Write `skills/summarize-changes/evals/evals.json`** with one fixture per case in `evals/files/`. Each fixture is a `.diff` plus its `--stat`/untracked listing:

| Case | Fixture | What must happen |
|---|---|---|
| `mixed-with-migration` | feature + new `migrations/0042_*.py` | 3–6 bullets; MIGRATION flag citing the file; no other flags |
| `auth-change` | edits `middleware/auth.ts` (token expiry) | AUTH flag that cites the file and says what changed |
| `deleted-tests` | `tests/test_billing.py` deleted, one `@pytest.mark.skip` added | TESTS REMOVED flag covering both |
| `benign` | README and CSS tweaks | "No risky changes detected."; no made-up flags |
| `empty` | nothing changed | "No uncommitted changes." and a stop |
| `untracked-only` | only a new untracked file | file appears in the summary |
| `negative-trigger` | "review my PR for bugs" | the skill does not trigger |

6. **Run `skill-authoring:skill-reviewer`** on `skills/summarize-changes/`. This includes the baseline comparison: every case is run in a fresh session with the skill and again with it disabled. Those are the only subagent runs; each gets the case prompt and fixtures and returns its transcript plus token count. Results are written to `.claude-skills-work/evals/summarize-changes/iteration-1/benchmark.json`. I'd fix whatever the review finds and re-run.
7. **Finish up:** tick the item in `plan.md`, add the skill to the `README.md` list and to the skill count in CLAUDE.md (8 → 9). No commit or push unless you ask.

The skill sticks to the three risk types you named. Secrets and dependency bumps are also common risks; say if you want those added.