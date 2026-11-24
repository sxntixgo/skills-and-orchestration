The biggest cost is that the skill makes Claude read both reference files on every run ("Before you start: Read … first"). Cutting that, plus the Git/Conventional Commits background Claude already knows, makes it a little over half the size while keeping every behaviour.

I had only `case-files/5/SKILL.md`. Neither `references/*.md` file nor an `evals/evals.json` was in the case files, so I treat them as not found and don't guess their contents.

## Steps, in order

1. **Run `skill-authoring:skill-creator`** on `commit-messages`, as the repo's CLAUDE.md requires for skill edits. Save the old version to `.claude-skills-work/commit-messages/SKILL.old.md` so it can be compared later.
2. **Read both reference files** before deleting anything.
   - If `conventional-commits.md` only repeats the public spec, delete it. The house rule is "don't restate what the model already knows", and step 2 below keeps the one rule that matters.
   - Keep `examples.md` only if it has this project's own conventions, and load it only when needed.
3. **Rewrite `SKILL.md`:**

```markdown
---
name: commit-messages
description: Writes a Conventional Commits message for the staged changes. Use when the user asks for a commit message or to describe staged work for a commit.
---

# Commit Messages

Scope: write the message for the staged changes. Does NOT commit, amend or push.
Track the steps as TodoWrite items.

1. Read `git diff --staged`.
2. Pick the Conventional Commits type; mark breaking changes with `!` or a `BREAKING CHANGE:` footer.
3. Subject: imperative mood, ≤72 chars, no trailing period.
4. Body only if the change isn't obvious: explain *why*, wrapped at 72.
5. Ticket id in the branch name (e.g. `ABC-123`) → put it in the footer.
6. Write the message to `.claude-skills-work/commit-messages/message.md`, show it, and STOP for approval.

Read `references/examples.md` only if the right type or format is unclear.

## Red flags
- Subject lists changed files → say what the change does and why.
- About to run `git commit` → don't; show the message and stop.

Done when: the message follows the format and the user approved it.
```

| Removed or changed | Why |
|---|---|
| Background section | Git history and the Conventional Commits types are things Claude already knows. |
| "Read both references first" | Both files loaded every run; now `examples.md` loads only when needed. |
| Weak description | "This skill is about commit messages" gave no trigger. The new one says what it does and when to use it. |
| Added the TodoWrite line and saving the message to a file | Required by house rules 6 and 7. The saved file also works with `git commit -F` if the user commits it themselves. |

4. **Write `evals/evals.json`** with four cases:
   - a feature on branch `ABC-123-…` (expects the ticket id in the footer);
   - an API change that removes something (expects `!` or a `BREAKING CHANGE` footer);
   - a one-line typo fix (expects a subject only, no body);
   - the user says "commit it" (expects it shows the message and stops, with no `git commit`).
5. **Compare old and new.** Run the cases in fresh subagents (Sonnet) with the old skill, with the new skill, and with no skill. Save the results to `.claude-skills-work/evals/commit-messages/iteration-1/benchmark.json`. The new version passes if it matches the old pass rate and uses fewer tokens.
6. **Run `skill-authoring:skill-reviewer`** on the result and tick the box in `plan.md`.

## Reply to user

> I slimmed `commit-messages` from about 420 tokens plus two reference files it always loaded, to about 230 tokens. `examples.md` now loads only when needed. Every step, the scope, both red flags and the "Done when" check are still there. I also gave it a real trigger description; the old one wouldn't reliably fire. Evals comparing old, new and no skill are in `benchmark.json`.
>
> **Your call:** the old version contradicted itself. Its scope said "does NOT commit", but step 6 said "ask before running `git commit`". I went with *never commit; show the message and stop*. If you'd rather it commit after you approve, I'll change step 6 and the scope line.