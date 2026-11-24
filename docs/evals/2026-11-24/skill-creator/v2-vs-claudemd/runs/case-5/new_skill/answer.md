The slimmed `SKILL.md` drops from about 11k characters (counting the two reference files it made Claude read every time) to about 1.3k, with the same scope, steps, stop point and red flags. Nothing was run in this dry run, so the numbers below are estimates.

**Assumptions:**
- The skill is at `skills/commit-messages/`.
- `references/conventional-commits.md` (assumed ~6k chars) restates the Conventional Commits spec, and `references/examples.md` (assumed ~3k chars) holds sample messages.
- No `evals/evals.json` exists yet, so I write one.

## What I'd do, in order

1. **Read in one parallel batch:** the repo's `CLAUDE.md`, `skills/code-review/SKILL.md` (for house style), and the target's `SKILL.md`, `references/*` and `evals/` (none found).

2. **Cuts:**

| Cut | Why |
|---|---|
| `## Background` (history of Git, what a commit is) | The model already knows this, so it changes nothing |
| "Read `references/…` first" and both reference files | The model knows the spec and good examples. Each file was an extra turn on every use. The one thing step 2 needed from the spec (the type list) is now a single line in the skill |
| Description "This skill is about commit messages." | It gave no trigger, so the skill was unlikely to load |

   I kept the 72-char subject rule, the "why" body, the ticket footer, ask-before-commit and both red flags.

3. **Write `skills/commit-messages/SKILL.md`:**
```markdown
---
name: commit-messages
description: Writes a Conventional Commits message for the staged changes, adds the ticket id from the branch name, and shows it for approval before committing. Use when the user asks to write, draft or suggest a commit message, or to commit staged changes.
---
# Commit Messages
A message for the staged diff; nothing is committed until the user approves it.

## Scope
DOES: write the commit message for the staged changes.
Does NOT: commit without approval, amend or push.

## Steps (TodoWrite items)
1. Run `git diff --staged` and `git branch --show-current`.
2. Pick the type: feat, fix, docs, style, refactor, perf, test, build, ci, chore. For a breaking change, add `!` after the type or a `BREAKING CHANGE:` footer.
3. Subject: `type(scope): summary`. Use the imperative, ≤ 72 chars, no trailing period.
4. Change not obvious → add a body that explains why, wrapped at 72.
5. Ticket id in the branch name (e.g. ABC-123) → put it in the footer.
6. Show the message and ask before running `git commit`.

## Red flags
| If you notice… | Do this |
|---|---|
| A subject that says what files changed | Say what the change does and why |
| Committing without asking | Show the message first |

## Done when
The message follows the format and the user approved it.
```

4. **Delete** `skills/commit-messages/references/` (both files).

5. **Write `skills/commit-messages/evals/evals.json`** with 4 cases. Each case is `{id, prompt, expected_output, files, assertions}`, and the fixtures go under `evals/files/`:

| id | Prompt / fixture | Assertions |
|---|---|---|
| 1 | "Write a commit message for what I staged." `null-check.diff` (guard against a null user in `login.ts`), branch `ABC-123-login-crash` | Subject starts `fix`. Subject is ≤ 72 chars with no trailing period. Footer contains `ABC-123`. Does not run `git commit` |
| 2 | "Commit message please." `rename-api.diff` (removes `getUser`, adds `fetchUser`) | Uses `!` or a `BREAKING CHANGE:` footer. Body says why the API changed. Subject doesn't just list file names |
| 3 | "Message for this?" `readme-typo.diff` | Type is `docs`. No body |
| 4 (stop) | "Commit this and push it to main." `null-check.diff` | Shows the message and asks for approval. No `git commit` before approval. No `git push` |

6. **Validate:** `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/commit-messages`. Fix every FAIL, decide each WARN, and rerun until it's clean.

## Reply to the user

The `commit-messages` skill is down from about 11k characters across 3 files to about 1.3k in 1 file, and it no longer needs 2 extra reads per use. Nothing it does was cut.

- **New description:** "Writes a Conventional Commits message for the staged changes, adds the ticket id from the branch name, and shows it for approval before committing. Use when the user asks to write, draft or suggest a commit message, or to commit staged changes."
- **Removed:** the Git background section and both reference files. The model already knows the spec, and the type list is now one line in the skill.
- **Fixed:** the old Scope said "Does NOT: commit", but step 6 commits after approval. It now says "commit without approval".
- **Added:** 4 eval cases (a fix with a ticket footer, a breaking change, a docs typo with no body, and a commit-and-push request where it must stop and must not push), each with a diff fixture.

Approve, or what should change? Next step: run `skill-reviewer` to profile the skill and compare it with no skill, to confirm the slimmed version scores as well as the old one.