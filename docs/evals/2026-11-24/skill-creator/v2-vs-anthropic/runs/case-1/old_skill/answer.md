I drafted the skill at `skills/summarize-changes/` and wrote three test cases. I've stopped before running the comparison against a no-skill baseline until you confirm the test cases and two scope questions (end of this reply).

## What I'd do, in order

**1. TodoWrite**
- Capture intent
- Draft SKILL.md
- Write evals.json and fixtures
- Confirm test cases with you
- Run with-skill and no-skill evals
- Grade, build the benchmark and open the viewer
- Revise the skill
- Run `skill-reviewer`
- Update `plan.md`

**2. Check for a name clash.** I'd run `ls skills/` and assume there's no existing `summarize-changes` skill.

**3. Write `skills/summarize-changes/SKILL.md`**

```markdown
---
name: summarize-changes
description: Summarizes the uncommitted git diff (staged + unstaged + untracked) into 3-6 bullet points and flags risky changes — database migrations, auth/permission code, and deleted or disabled tests. Use when the user asks for a summary or recap of their changes, "what did I change", or a quick overview of their working tree before committing, even if they don't say "diff".
---

# Summarize changes

**Does:** read the uncommitted diff, write 3-6 bullets, flag risky changes.
**Does NOT:** commit, stage, edit files, review code quality, or flag risk categories beyond the three below. It is read-only.

## Checklist (TodoWrite)
1. Collect the diff
2. Write the summary
3. Flag risks

## 1. Collect
- `git status --porcelain` lists changed and untracked files. If nothing is listed, say "No uncommitted changes." and STOP.
- `git diff HEAD --stat`, then `git diff HEAD`. In a repo with no commits yet, use `git diff --cached`. If the diff is over ~2000 lines, read it per file, starting with the files that have the most changed lines.
- Untracked files: name them, and read them only if a filename suggests a risk category.

## 2. Summarize
Write 3-6 bullets about **intent**, not files ("Add retry to webhook client", not "edit client.py"). Group related files under one bullet. Reviewers skim, so more than 6 bullets hides the point.

## 3. Flag risks (only these three)
| Category | Signals |
|---|---|
| Migration | `migrations/`, `db/migrate/`, `alembic/versions/`, `*.sql`, schema/DDL changes |
| Auth | login, session, token/JWT, password, permission/role checks, auth middleware, CORS |
| Deleted tests | deleted test files, removed test functions, newly added `skip`/`xfail`/`.only` |

Flag only on real evidence in the diff. A filename match alone is not enough: `author.py` is not auth.

## Output (exact template)
**Summary**
- …
**⚠ Risky changes**
- [Migration] `path` — one-line reason
(or "None flagged.")

## Red flags
- More than 6 bullets, or one bullet per file → regroup by intent.
- Reviewing or "fixing" code → out of scope; stop at the summary.
- Ignoring staged or untracked files → use `git diff HEAD` plus `git status`.
- Flagging on keywords alone → check the hunk before flagging.
```

This skill is a single pass with no intermediate state, so I didn't add a checkpoint file (the repo's rule 6 applies to multi-step skills).

**4. Write `skills/summarize-changes/evals/evals.json`**
Prompts only for now. Checks for pass/fail come later, per skill-creator.

```json
{
  "skill_name": "summarize-changes",
  "evals": [
    {"id": 1, "prompt": "can you summarize my changes? (treat evals/files/migration.diff as `git diff HEAD`)",
     "expected_output": "3-6 intent-level bullets; flags the new migration file as Migration; no other flags",
     "files": ["evals/files/migration.diff"]},
    {"id": 2, "prompt": "quick recap of what I changed before I commit — diff is evals/files/auth-and-tests.diff",
     "expected_output": "Flags the session-token change in auth/session.py as Auth and the deleted tests/test_auth.py as Deleted tests",
     "files": ["evals/files/auth-and-tests.diff"]},
    {"id": 3, "prompt": "summarize my uncommitted changes (evals/files/benign.diff)",
     "expected_output": "3-6 bullets; 'None flagged.'; does not flag models/author.py or docs mentioning 'login'",
     "files": ["evals/files/benign.diff"]}
  ]
}
```

I'd also write the three fixture diffs (`migration.diff`, `auth-and-tests.diff`, `benign.diff`), each about 30–80 lines and made up for testing. Case 3 is a deliberate trap: nothing in it should be flagged.

**5. After you approve (not done yet)**
- **Spawn runs:** six subagents in one turn on the session model (claude-opus-5-5), one with-skill and one no-skill run per case. Results go to `.claude-skills-work/evals/summarize-changes/iteration-1/<eval-name>/{with_skill,without_skill}/outputs/`, which is the repo's gitignored convention, instead of skill-creator's sibling workspace folder. Each case also gets an `eval_metadata.json`.
- **Draft checks while runs go:** bullet count is 3–6, the output follows the template, the expected categories are flagged, nothing is flagged in case 3, and no files are edited.
- **Record timing:** save `timing.json` as each run finishes.
- **Grade and aggregate:** grade into `grading.json`, then run `python -m scripts.aggregate_benchmark … --skill-name summarize-changes`.
- **Review:** open the results with `eval-viewer/generate_review.py` so you can look at them, then revise from your feedback.
- **Finish:** run `skill-authoring:skill-reviewer` and tick off the `plan.md` item.

## Reply to you

Here are three test cases:
1. **Migration added:** the migration should be flagged.
2. **Auth change plus a deleted test file:** both should be flagged.
3. **Harmless changes:** includes `author.py` and docs that mention "login". Nothing should be flagged.

Do these look right, or do you want more? Also:
- **Untracked files:** should the summary include them? I've assumed yes, listed by name.
- **Skipped tests:** should a newly added `skip`/`xfail` count as "deleted tests"? I've assumed yes.

Once you confirm, I'll run each case with and without the skill and open the results for you to review.