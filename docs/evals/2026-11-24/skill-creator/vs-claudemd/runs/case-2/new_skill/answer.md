I've stopped at the skill's first gate (Stage 1, Clarify intent) and drafted nothing yet. The skill needs your approval of the plan below before I change the description. I'm assuming your skill is at `skills/code-review/SKILL.md` and its current description is vague, something like "Reviews code."

**Steps, in order:**

1. Read `skills/code-review/SKILL.md` and `skills/code-review/evals/evals.json` to see the current description and the existing test prompts.
2. Create TodoWrite items for the stages: (1) Clarify intent, (2) Frontmatter, (3) Body (likely nothing to do, since this is a description-only edit), (4) Evals, (5) Hand off.
3. Write `./.claude-skills-work/code-review/plan.md`:

```markdown
# code-review: description edit

## Trigger (proposed)
Fires when the user finishes a change or is about to merge. Example phrasings:
"I'm done with this change", "review my diff/branch/PR", "is this ready to merge?",
"check before I merge", "look over what I just changed".
NOT triggered by: writing new code, debugging a failing test, general questions about
review practices.

## Scope
DOES: rewrite only the frontmatter `description` (third person, "<what>. Use when <trigger>.");
add or adjust eval cases so the trigger phrasings are covered.
Does NOT: change the skill body, the review process or the security pass; does not run evals
(→ skill-reviewer).

## Success criteria
- The description names concrete triggers: a finished change, a diff/branch/PR to review, pre-merge.
- It mentions correctness, quality and security, so it beats other skills for "review".
- evals.json has 3–5 cases with assertions, including 1–2 should-trigger prompts from
  the list above and 1 near-miss that should not trigger.
- skill-reviewer is run afterwards (handed off, not self-judged).

## Status
Stage 1: awaiting user approval.
```

4. Stop and reply.

**Reply to you:**

> I wrote the plan to `./.claude-skills-work/code-review/plan.md`. Please confirm:
> 1. **Triggers:** should it fire on "I'm done with this change", "review my diff/branch/PR" and "ready to merge?"? Any phrasings to add or drop?
> 2. **Scope:** only the `description` line changes and the review body stays as it is. Correct?
> 3. **Exclusions:** should it stay quiet while you're still writing or debugging code?
>
> Once you approve, I'll draft the new description (Stage 2), update the evals with trigger and near-miss cases (Stage 4), and then hand off to `skill-reviewer`.