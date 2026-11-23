The brief is clear enough to draft a plan, but it's missing a few decisions only you can make. Per the skill's Stage 1 stop gate, I'd write the plan and wait for your approval before drafting anything. I wouldn't read the references yet, because they're batch-read when drafting starts in Stage 2.

**What I'd do, in order**

1. **TodoWrite** with 5 items:
   1. Clarify intent (⛔ gate)
   2. Frontmatter
   3. Body
   4. Scaffold + evals
   5. Hand off to `skill-reviewer`

   Item 1 is in progress.

2. **Write `./.claude-skills-work/summarize-changes/plan.md`:**

```markdown
# summarize-changes — plan

## Trigger
Use when the user asks for a summary/overview/recap of their current, uncommitted changes
("summarize my changes", "what did I change?", "recap my diff before I commit").
NOT for: summarizing a commit, a PR, or a branch vs main.

## Scope
DOES:
- Read uncommitted changes: `git diff` (unstaged) + `git diff --cached` (staged)
  + `git status --porcelain` for untracked files (names only)
- Output 3–6 bullets summarizing what changed, grouped by intent rather than file
- Output a "⚠️ Risky changes" section flagging matches against a risk checklist
  (in references/risk-checklist.md), each with file:line and a one-line reason
- Say "no uncommitted changes" and stop if the diff is empty
Does NOT:
- Stage, commit, stash, or modify files
- Review code quality or suggest fixes (only flags)
- Summarize committed history

## Risk checklist (draft — confirm)
Secrets/credentials/.env, auth/permissions code, DB migrations/schema, deleted files or
large deletions, dependency/lockfile changes, CI/deploy config, infra (Docker, Terraform),
disabled/removed tests, public API signature changes.

## Success criteria
- Fires on "summarize my changes"-style prompts; doesn't fire on "summarize this PR/commit"
- ≤ 6 summary bullets; every bullet traceable to the diff
- Every checklist hit in the diff is flagged with file + reason; no flags on a clean diff
- No git write commands run
- Empty diff → one-line "nothing uncommitted"

## Open questions
1. Include staged + unstaged + untracked, or only one of them?
2. Is the risk checklist above right? Anything project-specific to add or drop?
3. Very large diffs: summarize from `--stat` first, then read only the flagged hunks?
4. Name: `summarize-changes` OK? Location: `skills/` or a plugin's `skills/`?

Status: awaiting approval (stage 1)
```

3. **Stop.** I wouldn't draft the frontmatter, write the body, scaffold, or spawn any subagents until you approve.

**Reply to you:**

> I've written the plan to `./.claude-skills-work/summarize-changes/plan.md`:
>
> - **Trigger:** you ask for a summary or recap of your uncommitted changes. It won't fire for commits, PRs, or a branch compared with main.
> - **Scope:** it only reads the diff. The output is 3–6 bullets plus a "⚠️ Risky changes" list with file:line and a reason for each flag. It never stages, commits, or edits anything.
> - **Success criteria:** it fires on the right prompts, every bullet is traceable to the diff, every risky pattern is flagged, it runs no git write commands, and an empty diff gets a one-line answer.
>
> Before I draft, please decide these:
> 1. Should it cover staged, unstaged, and untracked changes, or only some of them?
> 2. What counts as risky? My draft list is secrets/.env, auth code, migrations, deletions, dependency/lockfile changes, CI/deploy config, infra, removed tests, and public API changes. Should I add or drop anything?
> 3. For huge diffs, is it OK to summarize from `--stat` first and only read the hunks it flags?
> 4. Is the name `summarize-changes` OK, and should it go in `skills/` or in a plugin?
>
> Approve the plan (or adjust it) and I'll move on to the frontmatter.