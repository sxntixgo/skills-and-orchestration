Here is the plan. It cuts the skill from about 2.0k chars in `SKILL.md` plus two reference files that are read on every use (I assume about 200 lines) down to one file of about 1.3k chars. Every rule that changes what the model does is kept.

**Assumptions** (only `SKILL.md` was provided):
- The skill lives at `skills/commit-messages/`.
- `references/conventional-commits.md` restates the public spec, and `references/examples.md` holds generic examples.
- There is no `evals/evals.json` yet.

## What I'd do, in order

**1. Read everything in one parallel batch:** `CLAUDE.md`, one sibling `SKILL.md` for house style, `skills/commit-messages/SKILL.md`, both `references/*.md` and `evals/evals.json` if it exists. If the references contain a rule specific to this repo (allowed scopes, a type that isn't standard, a footer format), I'd move it into `SKILL.md` as one line. If they only restate the spec or show generic examples, I'd cut them.

**2. Edit `skills/commit-messages/SKILL.md`:**
- **Cut "Background":** it's git history and the Conventional Commits spec, which the model already knows.
- **Cut "Before you start":** reading two files first costs extra turns and tokens on every use.
- **Delete `references/`:** the one useful fact (the type names and the `!` marker) fits in one line.
- **Rewrite the description:** it currently has no trigger, so the skill rarely loads.
- **Fix a contradiction:** Scope says the skill never commits, but step 6 commits after approval. Scope now says it commits only after the user approves.
- **Keep unchanged:** 72-char imperative subject, a body that says why, the ticket ID from the branch name, showing the message before committing, and both red flags.

```markdown
---
name: commit-messages
description: Writes a Conventional Commits message for the staged changes, adds the branch's ticket ID, and commits only after the user approves. Use when the user asks for a commit message, to "write the commit", or to commit staged changes.
---
# Commit Messages
Write the message for what is staged; the user approves before anything is committed.

## Scope
DOES: write the message for staged changes; run `git commit` after approval.
Does NOT: commit without approval, amend, or push.

## Steps (TodoWrite items)
1. `git diff --staged`. Nothing staged → say so and stop.
2. Subject: `type(scope)!: summary` (feat, fix, docs, style, refactor, perf, test, build, ci, chore; `!` only for breaking changes). Use the imperative mood, ≤ 72 chars, no trailing period.
3. Body only if the change isn't obvious: say *why*, wrapped at 72. Breaking change → add a `BREAKING CHANGE:` footer.
4. Branch name has a ticket ID (e.g. `ABC-123`) → put it in the footer.
5. Show the message; ⛔ wait for approval, then `git commit`.

## Red flags
| If you notice… | Do this |
|---|---|
| A subject that lists the changed files | Say what the change does and why |
| Committing without asking | Show the message first |
| Asked to push or amend | Out of scope: say so, don't run it |

## Done when
The message follows the format, the user approved it, and the commit was made.
```

**3. Run `git rm -r skills/commit-messages/references/`.**

**4. Write `evals/evals.json`** with four cases. Fixtures go in `evals/files/`.

| id | prompt / fixture | assertions |
|---|---|---|
| 1 | "write a commit message" + `feature.diff` (adds a CSV export endpoint) | subject starts with `feat`; subject ≤ 72 chars, imperative, no period; doesn't list file names; asks before committing |
| 2 | "commit this, I'm on `PROJ-482-null-total`" + `fix.diff` (null check) | type `fix`; footer contains `PROJ-482`; no `git commit` before approval |
| 3 | "commit message please" + `breaking.diff` (removes a public API parameter) | uses `!` or a `BREAKING CHANGE:` footer; body says why; lines wrapped ≤ 72 |
| 4 (stop) | "commit and push to main" + `fix.diff` | says pushing is out of scope; no `git push` |

**5. Validate:** run `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/commit-messages`, fix every FAIL, decide each WARN, and rerun until it passes.

## Final reply

> I slimmed `commit-messages` from about 2.0k chars plus two reference files read on every use to one `SKILL.md` of about 1.3k chars (the exact size comes from the check line).
>
> **Description:** "Writes a Conventional Commits message for the staged changes, adds the branch's ticket ID, and commits only after the user approves. Use when the user asks for a commit message, to "write the commit", or to commit staged changes." The old one had no trigger.
>
> **Cut:**
> - the Background section
> - the "read first" step
> - both `references/` files (spec text and generic examples the model already knows; any repo-specific rule moved inline)
>
> **Kept:** every rule that changes behaviour (72-char imperative subject, a body that says why, ticket footer, approval before committing, red flags). I also fixed the Scope/step-6 contradiction and added "nothing staged → stop".
>
> **Evals:**
> 1. feat diff: type, subject format, no file list, asks first
> 2. fix + branch ticket: `PROJ-482` in the footer
> 3. breaking diff: `!` or a `BREAKING CHANGE:` footer, body says why
> 4. "commit and push": refuses to push
>
> **Assumptions:** the references held no repo-specific rules beyond the type list, and there was no existing eval file.
>
> Approve, or what should change? Next step: `skill-reviewer` to compare token cost and pass rate against the old version and against no skill.