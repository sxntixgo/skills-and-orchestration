The skill-creator process requires your approval of the plan before I draft anything, so I've written the plan and stopped there.

**What I did**
1. Created TodoWrite items, one per stage: Clarify intent (in progress), Frontmatter, Body, Scaffold + evals, Hand off.
2. Wrote `./.claude-skills-work/diff-summary/plan.md`:

```markdown
# diff-summary — plan (stage 1: clarify intent) — AWAITING APPROVAL

Location: skills/diff-summary/ (plugin frugal-skills)

## Trigger
Use when the user asks for a summary of their changes, e.g. "summarize my changes",
"what did I change?", "recap my diff", "give me a summary before I commit".

## Scope
DOES:
- Read the uncommitted diff: staged + unstaged (`git diff HEAD`), plus a list of untracked files.
- Output 3–6 bullets describing what changed and why it matters, grouped by intent rather than by file.
- Flag risky changes in a separate "⚠ Risky" list, each with file:line and a one-line reason.
Does NOT:
- Commit, stage, stash or edit files.
- Do a full code review (that's frugal-skills:code-review).
- Summarize already-committed history or a PR or branch range.

## Risk heuristics (proposed, please confirm)
Deleted or weakened tests · auth/crypto/permissions code · secrets or credentials in the diff ·
migrations/schema changes · dependency or lockfile changes · CI/deploy config ·
removed error handling · large deletions · new network or exec calls.

## Success criteria (observable)
- At most 6 summary bullets, and none of them just restates a filename.
- Every risky item cites file:line and a reason; it says "No risky changes" when there are none.
- A clean tree gets "No uncommitted changes" and nothing more.
- No file is modified and no git state changes.
- Large diffs (over ~2k lines) get the `--stat` summary first, then the risky hunks only.

## Open questions
1. Include untracked files, or tracked changes only?
2. Keep the risk list above, or add or remove anything (e.g. project-specific paths)?
3. Name: `diff-summary` OK?

next: approve stage 1 → stage 2 (frontmatter)
```

**Please answer these before I continue**
1. Should untracked files be included, or only staged and unstaged changes to tracked files?
2. Is the list of what counts as risky right? Add or drop anything, such as paths specific to your project.
3. Is the name `diff-summary` OK?

Once you approve, I'll draft the frontmatter and body, scaffold the skill with `scripts/new_skill.sh diff-summary`, and write 3–5 test cases in `evals/evals.json`. Then you run `skill-reviewer` to check it.