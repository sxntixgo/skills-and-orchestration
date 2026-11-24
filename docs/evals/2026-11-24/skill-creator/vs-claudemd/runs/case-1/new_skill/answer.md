Stage 1 is a stop gate, so this answer only writes the plan and asks for your approval. No frontmatter, body or scaffold gets written until you sign off.

**What I'd do, in order**

1. TodoWrite with one item per stage: 1 Clarify intent ⛔ · 2 Frontmatter · 3 Body · 4 Scaffold + evals · 5 Hand off. Item 1 is marked in progress.
2. Write `./.claude-skills-work/diff-summary/plan.md`:

```markdown
# diff-summary — plan (Stage 1: clarify intent, AWAITING APPROVAL)

## Trigger (draft)
Use when the user asks to summarize, recap or describe their uncommitted / working-tree
changes ("summarize my changes", "what did I change?", "recap my diff").

## Scope
DOES:
- Read the uncommitted diff (`git diff` + `git diff --cached`; untracked files listed by name)
- Produce 3–6 bullet points summarizing what changed (intent-level, not line-by-line)
- Flag risky changes in a separate "Risks" list, each tied to file:line
does NOT:
- Commit, stage, stash, or modify files
- Do a full code review (→ frugal-skills:code-review)
- Summarize committed history / PRs / branches vs main (unless approved below)

## Success criteria (observable)
- Output = ≤6 summary bullets + a Risks section (or "No risky changes found")
- Every risk names a file and a reason from the agreed risk list
- Empty diff → says so, no invented summary
- Never runs a mutating git command

## Open questions (need answers before Stage 2)
1. "Risky" means which of these? (default proposal) deleted/renamed files, migrations/schema,
   auth/permissions/crypto, secrets or .env, dependency/lockfile bumps, CI/config/infra,
   public API signature changes, large deletions, removed tests.
2. Staged + unstaged both, or unstaged only? (proposal: both, labeled)
3. Which plugin: `frugal-skills` (skills/) or another? (proposal: frugal-skills)
4. Lift concern: a frontier model already summarizes diffs well (cf. security-review 0.00 lift).
   The skill should earn its cost via the fixed risk checklist + output format. OK to proceed
   on that basis, accepting skill-reviewer may recommend dropping it if lift ≈ 0?

## Status
next: user approval of Stage 1
```

3. Stop and send the reply below. When you approve, I'd read `writing-descriptions.md`, `skill-body.md`, `writing-evals.md` and `examples.md` in one parallel batch, then continue with Stage 2.

**Reply to user**

> The draft plan is in `.claude-skills-work/diff-summary/plan.md`. I need four answers before drafting:
>
> 1. **What counts as "risky"?** My proposal: deleted or renamed files, migrations, auth/crypto code, secrets or `.env` files, dependency and lockfile bumps, CI and infra config, public API signature changes, large deletions, and removed tests. Add or remove items as you like.
> 2. **Staged, unstaged, or both?** I'd include both and label which is which.
> 3. **Which plugin should it go in?** I'd put it in `frugal-skills`, under `skills/diff-summary/`.
> 4. **Is it worth adding?** The model already summarizes diffs well without a skill. `security-review` measured zero lift and was folded into `code-review`, and this could end up the same way. This skill can only add value through a fixed risk checklist and a consistent output format. Is it worth building on that basis? `skill-reviewer`'s baseline comparison will show whether it helps.
>
> If you approve the plan, with any edits, I'll draft the frontmatter next.