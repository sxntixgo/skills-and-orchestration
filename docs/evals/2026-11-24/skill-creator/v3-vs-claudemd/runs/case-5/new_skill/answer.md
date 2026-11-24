The slimmed skill is about 1.3k characters, down from roughly 1.9k plus two reference files that the old version made Claude read on every use. It still does the same six steps, keeps both red flags and the same scope. This is a dry run: I couldn't see the `references/` files or `evals/evals.json`, so I assumed the reference files only restate Conventional Commits and that no evals exist yet.

**What I'd do, in order**

1. **Read the skill's files in one parallel batch:** `skills/commit-messages/SKILL.md`, `references/conventional-commits.md`, `references/examples.md` and `evals/evals.json`. Only `SKILL.md` exists in the case files.
2. **Rewrite `skills/commit-messages/SKILL.md`:**

```markdown
---
name: commit-messages
description: Writes the commit message for the staged changes (Conventional Commits, ticket id from the branch) and shows it for approval before committing. Use when the user asks to write a commit message, "commit this", or "what should the commit say".
---
# Commit Messages
Write the message for what is staged; never commit without approval.

## Scope
DOES: write the message for the staged changes. Does NOT: commit without approval, amend or push.

## Steps (TodoWrite items; output in `./.claude-skills-work/commit-messages/message.txt`)
1. `git diff --staged`. Nothing staged → stop and say so; don't stage files yourself.
2. Type: feat | fix | docs | style | refactor | perf | test | build | ci | chore. Breaking change → `type!:` plus a `BREAKING CHANGE:` footer.
3. Subject: `type(scope): <imperative summary>`, ≤ 72 chars, no trailing period.
4. Body only if the reason isn't obvious from the diff: explain why, wrapped at 72 characters.
5. Ticket id in the branch name (`git branch --show-current`, e.g. `ABC-123`) → put it in the footer.
6. Write the message to the file, show it, and ask. Run `git commit -F <file>` only after the user says yes.

## Red flags
| If you notice… | Do this |
|---|---|
| A subject that lists the changed files | Say what the change does and why |
| Committing without asking | Show the message first |

## Done when
The message follows the format and the user approved it.
```

3. **Delete `references/conventional-commits.md` and `references/examples.md`.** The only part of the spec that changes behaviour (the type list and how to mark a breaking change) is now one line in step 2.
4. **Write `skills/commit-messages/evals/evals.json`** with 4 cases:
   - **`feat-with-ticket`**: fixture `files/feat.diff` (adds a CSV export endpoint) on branch `ABC-123-export`. Assertions: the subject starts with `feat`; it's ≤ 72 chars with no trailing period; the footer contains `ABC-123`; `git commit` isn't run before approval.
   - **`breaking-change`**: fixture `files/breaking.diff` (removes the `--legacy` flag). Assertions: the subject has `!:`; there's a `BREAKING CHANGE:` footer.
   - **`files-only-subject`**: fixture `files/rename.diff`. Assertions: the subject is imperative and doesn't list file names; it's ≤ 72 chars.
   - **`nothing-staged`** (the must-stop case): empty staged diff. Assertions: it says nothing is staged; it runs no `git add` or `git commit`.

   Each case also gets the fixture diffs under `evals/files/`.
5. **Validate:** `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/commit-messages`, then fix any FAILs and rerun. The CHECK line isn't real because nothing ran in this dry run.

**What changed beyond trimming**
- **Description:** the old one ("This skill is about commit messages.") had no trigger, so the skill would rarely load. I rewrote it.
- **Nothing staged:** step 1 now stops when nothing is staged. It's one line and protects against Claude staging files on its own.
- **Approval:** writing the message to a file and committing with `git commit -F` only after a yes keeps the original "show it and ask before committing" step.

Approve, or what should change? Next step is running `skill-reviewer` to compare the old and new versions on pass rate and tokens.