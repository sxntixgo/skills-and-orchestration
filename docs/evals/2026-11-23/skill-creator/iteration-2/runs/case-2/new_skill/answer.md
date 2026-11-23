Edits to existing skills still go through the Stage 1 gate, so in this session I stop for your approval before drafting the description.

**What I'd do, in order:**

1. **TodoWrite** with one item per stage: Clarify intent ⛔, Frontmatter, Body (light touch), Evals, Hand off.
2. **Find the skill:** Glob `skills/*/SKILL.md` and `plugins/*/skills/*/SKILL.md` for `code-review`. I assume it's at `skills/code-review/SKILL.md` with something like `description: Helps with code review.` I'd read that file and its `evals/evals.json`, and nothing else yet. The reference files get read together at Stage 2.
3. **Check for overlap:** `plugins/orchestration/skills/claude-review-merge` already covers "before merging". Two skills that both trigger on "merge" would compete, so the boundary between them needs settling first.
4. **Write `./.claude-skills-work/code-review/plan.md`:**

```markdown
# code-review — edit (description only)

## Trigger (proposed, pending approval)
- User says a change is done ("done", "finished", "ready", "wrap up") and asks for/accepts a review
- User is about to merge/open a PR and asks "is this ready?", "review before merge", "check my diff"
- NOT: merging orchestration task branches (→ claude-review-merge)
- NOT: reviewing someone else's PR on GitHub? (open question)

## Scope
DOES: rewrite the `description` frontmatter (third person, what + concrete "Use when…");
      add trigger/non-trigger eval cases.
Does NOT: change the review procedure in the body (unless the description reveals a scope mismatch).

## Success criteria
- Description names the action (reviews the working diff / branch vs base) and both triggers
- Should-trigger eval prompts match it; near-miss prompts (claude-review-merge, "explain this code") don't
- skill-reviewer passes the description rubric

## Status
Stage 1 — awaiting user approval
next: frontmatter
```

5. **Stop and reply:**

---

I wrote the plan to `./.claude-skills-work/code-review/plan.md`. Please answer these before I draft the new description:

1. **What does the skill actually review?** Uncommitted changes, the branch diff against `main`, or a GitHub PR? The description has to name this.
2. **How should it relate to `claude-review-merge`?** That skill already covers "before merging" for orchestration task branches. Should `code-review` hand those off to it and only handle your own work-in-progress branches?
3. **Should it trigger on its own?** For example, should it run when you say "done" with no mention of a review, or only when you ask for one?
4. **Which prompts didn't trigger it?** If you remember a couple, I'll use them as eval cases.

Once you approve, I'll write the description, show it to you, and add 3–5 eval cases to `evals/evals.json`: prompts that should trigger it, plus near misses that shouldn't. Evals are required for edits too (rule 8). After that I'll hand the skill to `skill-reviewer`.