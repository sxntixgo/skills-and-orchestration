I'd rewrite `SKILL.md` to about 230 tokens and delete both reference files. The behaviour stays the same. Nothing has been run or measured yet: this is a dry run, the reference files and `evals/evals.json` aren't in `case-files/5/`, and every saving below is an estimate.

**What I assume:** `references/conventional-commits.md` and `references/examples.md` are generic restatements of the Conventional Commits spec, about 1–2k tokens together. Most of the cost is there, because the skill's "Before you start" step makes Claude load both files on every run. There is no `evals/` folder yet.

## What I'd do, in order

1. **Invoke `skill-authoring:skill-creator`**, as the repo's CLAUDE.md requires when editing a skill. Track these steps as TodoWrite items.
2. **Read both reference files** before deleting anything. If `examples.md` has project-specific rules (scopes, footer format), keep them as one line in the new body. If not, delete both: `git rm skills/commit-messages/references/{conventional-commits,examples}.md`. Claude already knows the spec, and the repo's own evals showed that restating known material gives no benefit.
3. **Rewrite `skills/commit-messages/SKILL.md`:**

```markdown
---
name: commit-messages
description: Writes a Conventional Commits message for the staged changes and asks before committing. Use when the user asks for a commit message or to commit staged work.
---

# Commit Messages

**Does:** draft the message for the staged changes; commit only after the user approves it.
**Does NOT:** amend, push, or change what is staged.

Steps (track as TodoWrite items):
1. `git diff --staged`. Nothing staged → STOP and tell the user.
2. Subject `type(scope)!: summary`: Conventional Commits type, imperative mood, ≤72 chars,
   no trailing period. Breaking change → `!` plus a `BREAKING CHANGE:` footer.
3. Add a body only if the diff doesn't make the reason obvious: explain why, wrap at 72.
4. Branch name has a ticket id (e.g. `ABC-123`) → put it in the footer.
5. Write the draft to `.claude-skills-work/commit-messages/msg.txt`, show it, and STOP for
   approval. Once approved: `git commit -F .claude-skills-work/commit-messages/msg.txt`.

## Red flags
| If you notice… | Do this |
|---|---|
| The subject lists the files that changed | Say what the change does and why |
| You're about to commit without approval | Show the message and wait |
```

**Removed:** the Background section (Git history and the spec, which Claude already knows), the instruction to read the reference files first, and "Done when" (now part of step 5).

**Kept:** the scope, all 6 original steps, the 72-character rules, the ticket footer, the approval gate and both red flags.

**Added (3 lines):**
- A description that says when to use the skill. The old one ("This skill is about commit messages.") gave Claude no way to decide when to load it. This adds about 20 tokens to the always-loaded description, which is worth it.
- A STOP when nothing is staged.
- A draft file on disk, which the repo's resumability rule requires.

4. **Write `skills/commit-messages/evals/evals.json`** with 3 test cases:
   - A feature on branch `feat/ABC-123-login`: expect a `feat:` subject of at most 72 characters, `ABC-123` in the footer, and no commit before approval.
   - An API signature change: expect `!` and a `BREAKING CHANGE:` footer.
   - Nothing staged plus "just commit it": expect it to stop and say so, with no commit.
5. **Compare against a baseline.** For each case, run a fresh Sonnet subagent three ways: with the old skill, with the new one, and with no skill. Save the results to `.claude-skills-work/evals/commit-messages/iteration-1/benchmark.json`. The slim version passes only if its pass rate is at least the old version's with fewer tokens. If it scores no better than no skill, I'd tell you the skill may not be worth keeping.
6. **Run `skill-authoring:skill-reviewer`** on the result and tick the box in `plan.md`.

## Decision for you

The old file contradicted itself. Its scope said "Does NOT: commit", but step 6 and the red flags assumed it commits once you approve. I followed the steps: it commits only after you explicitly approve. Tell me if it should only draft the message and never commit.

**Expected outcome:** each run goes from about 330 tokens plus two reference files (roughly 1.5–2.3k tokens) to about 230 tokens. The benchmark in step 5 would confirm or correct that.