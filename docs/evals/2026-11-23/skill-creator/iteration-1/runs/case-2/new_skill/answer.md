**What I'd do, in order**

1. TodoWrite with the 5 stages: 1 Clarify (gate), 2 Frontmatter, 3 Body (check only, since this is an edit), 4 Evals (no scaffolding for an edit), 5 Hand off.
2. Read the current skill and its siblings. I won't edit anything yet.
   - `cat skills/code-review/SKILL.md skills/code-review/evals/evals.json`
   - `grep -H '^description:' skills/*/SKILL.md` to find overlapping triggers.
   - **Assumptions:** the current description is `Helps with code review.` The body reviews the working diff (`git diff` against the base branch) for correctness, tests and quality. The evals have 3 generic prompts like "review my code". There's a sibling `security-review` skill whose trigger is "a change touches auth/input/external I/O".
3. Write `./.claude-skills-work/code-review/plan.md`:

```markdown
# code-review — edit plan (description only)

## Trigger
- User says they finished a change: "done", "that should do it", "finished the fix".
- User is about to merge or open a PR: "ready to merge", "open a PR", "ship it", "LGTM?".
- User asks directly: "review my changes / this diff / this branch".
- NOT: a general question about code, or a security-specific audit (that's security-review).

## Scope
- DOES: change the `description` frontmatter so it fires on the triggers above.
  Update evals/evals.json prompts so they match those triggers.
- Does NOT: change the review steps in the body, rename the skill, or touch security-review.

## Success criteria
- The description follows "<what it does>. Use when <trigger>." and is written in third person.
- Each eval prompt would plausibly fire code-review and not security-review.
- A "finished the change" prompt and a "ready to merge" prompt are both in evals.

## Open questions
1. Should it fire on its own when Claude finishes its own edits, or only when the user signals they're done?
2. Which do you review: the uncommitted diff, the branch vs main, or a GitHub PR?

## Status
stage 1 — awaiting approval
```

4. Stop at the Stage 1 gate. No description draft until the user approves.

**Reply to the user**

I've written the edit plan to `./.claude-skills-work/code-review/plan.md`. It's scoped to the description and evals only, and the body stays as it is.

The skill would fire when you:
- say you're done with a change
- are about to merge or open a PR
- ask for a review of your diff or branch

It would stay out of security audits, which `security-review` handles.

Before I draft the description I need two answers:
1. Should it also fire when I finish my own edits, or only when you say you're done?
2. What does it review: the uncommitted diff, the branch vs `main`, or a PR?

Once you approve, I'll draft the description against `references/writing-descriptions.md` and update the eval prompts to match. Then I'll hand off to `skill-reviewer` to check whether it actually triggers.