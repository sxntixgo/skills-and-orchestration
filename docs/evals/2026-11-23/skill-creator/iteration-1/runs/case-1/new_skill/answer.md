I'd stop at the Stage 1 gate: the plan below has open questions, so nothing gets drafted until you answer them and approve it.

**Steps, in order**

1. **TodoWrite**, one item per stage:
   - Stage 1 Clarify intent ⛔
   - Stage 2 Frontmatter
   - Stage 3 Body
   - Stage 4 Scaffold + evals
   - Stage 5 Hand off
   
   Stage 1 is marked in_progress.
2. **Don't load any reference files yet.** Each one is only read at the stage that needs it.
3. **Write `./.claude-skills-work/summarize-diff/plan.md`** (`summarize-diff` is a working name):

```markdown
# summarize-diff — plan (Stage 1, awaiting approval)

## Trigger
Use when the user asks for a summary of their uncommitted/current/local changes
("summarize my changes", "what did I change?", "summarize the diff before I commit").
Not for: reviewing a PR, summarizing commit history, or writing a commit message.

## Scope
DOES:
- Read the uncommitted diff (`git diff` + `git diff --cached`; untracked files listed by name — see Q1).
- Produce 3–7 bullet points summarizing the changes by intent, not file-by-file.
- Flag risky changes in a separate "⚠ Risky" section, each with file:line and why.
DOES NOT:
- Commit, stage, stash, or modify any file.
- Do a full code review or suggest fixes (see Q4).
- Write a commit message.
- Look at committed history or other branches.

## Success criteria
- Output has ≤7 summary bullets covering every changed file group.
- Every flagged risk cites a file and a concrete reason drawn from the diff.
- No risk section noise: if nothing is risky, it says "No risky changes detected."
- Working tree is unchanged after the skill runs.
- Doesn't fire on "review my PR" or "write a commit message".

## Open questions (answer before Stage 2)
1. Which changes count: staged + unstaged only, or also untracked files (and their contents)?
2. What counts as "risky"? Proposed default: secrets/credentials, deleted or
   weakened tests, auth/permission changes, DB migrations/schema, dependency or
   lockfile changes, CI/deploy config, deleted files, large mass edits. Add/remove?
3. Large diffs: cap (e.g. summarize per-directory above N files), or always full?
4. Should risk flags include a suggested fix, or only flag?
5. Output format: plain bullets in chat is fine, or a fixed template?

## Status
Stage 1 — waiting for user approval.
```

4. **Log:** "Wrote Stage 1 plan to `./.claude-skills-work/summarize-diff/plan.md`." I'd also mark Stage 1 as blocked on your approval.

**My reply to you**

> The Stage 1 plan is in `./.claude-skills-work/summarize-diff/plan.md`.
>
> - **Name:** `summarize-diff`
> - **Fires on:** requests like "summarize my changes" or "what did I change?" about uncommitted work.
> - **Doesn't fire on:** PR reviews, commit history, or commit messages.
> - **What it does:** summarizes the diff in 3–7 bullets, plus a separate "Risky" section that gives the file and the reason for each flag.
> - **Read-only:** it never stages, commits, or edits anything.
>
> I need your answers on these before drafting:
> 1. Should untracked files count, or only staged and unstaged changes?
> 2. What counts as "risky"? My default list:
>    - secrets
>    - deleted or weakened tests
>    - auth changes
>    - migrations
>    - dependency or lockfile bumps
>    - CI/deploy config
>    - deleted files
>    - mass edits
>
>    Add or remove anything?
> 3. For very large diffs, should it cap the output and summarize by directory, or always give the full summary?
> 4. Should it only flag risks, or also suggest fixes?
> 5. Is plain bullets fine, or do you want a fixed output template?
>
> Once you approve (with changes if needed), I'll draft the frontmatter (Stage 2).