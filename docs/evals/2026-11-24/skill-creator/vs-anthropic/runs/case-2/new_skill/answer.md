I've written the plan for the description edit and stopped at the approval step. Nothing is drafted yet.

**What I did, in order**

1. Read `plugins/skill-authoring/skills/skill-creator/SKILL.md`.
2. Added 5 TodoWrite items, one per stage: Clarify intent ⛔, Frontmatter, Body (no changes, since this is a description-only edit), Evals, Hand off. I marked Clarify intent as in progress.
3. Assumed `skills/code-review/SKILL.md` exists, with a vague description like `"Helps review code."` and an existing `evals/evals.json`. I didn't open either, because this is a dry run.
4. Wrote `./.claude-skills-work/code-review/plan.md`:

```markdown
# code-review: description edit

## Trigger
Fires when the user has finished a change and wants it checked, or is about to merge:
"I'm done with this change", "review my diff", "ready to merge?", "check before I open/merge
the PR", "look over what I changed". Also when a branch or diff is handed over for review.
Does NOT fire on: writing new code, debugging a failing test, or general questions about
code quality.

## Scope
DOES: rewrite only the `description` frontmatter of skills/code-review/SKILL.md (third person,
"<what it does>. Use when <trigger>."). Mention correctness, quality and security, since
security-review was folded in. Add trigger cases to evals/evals.json.
Does NOT: change the body, the review process or the name. No new skill. No running evals
(skill-reviewer does that).

## Success criteria
- The description names concrete moments: a change is finished, before merging, a PR or diff
  needs review.
- It fires on 3+ eval prompts in finish/pre-merge wording that don't say "code review".
- It doesn't fire on a near-miss prompt ("write a function that…").
- The name still matches the directory. Rules 1–8 still hold.

## Status
Stage 1: awaiting user approval.
```

**Reply to you**

The plan is saved at `.claude-skills-work/code-review/plan.md`. It has two decisions for you to check:

- **Trigger:** the skill fires when you say a change is done, ask for a diff review, or are about to open or merge a PR. It stays silent on writing code or debugging.
- **Scope:** only the `description` changes, plus trigger-focused eval cases. The skill body stays as it is.

Approve, or adjust the trigger phrases. Once you approve, I'll draft the new description and the eval cases.