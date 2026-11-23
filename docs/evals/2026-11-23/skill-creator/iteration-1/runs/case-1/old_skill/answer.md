I'd write one file, `.claude/skills/summarize-diff/SKILL.md`, in the project. I'm assuming you want a project-level skill and that no skill with that name exists yet. If you want it in every repo, put it at `~/.claude/skills/summarize-diff/SKILL.md` instead.

**Steps, in order**

1. Check the target is free: `ls .claude/skills/ 2>/dev/null`. I'm assuming it's empty or has no `summarize-diff`.
2. Make the directory: `mkdir -p .claude/skills/summarize-diff`.
3. Write `.claude/skills/summarize-diff/SKILL.md`:

```markdown
---
name: summarize-diff
description: Summarize the uncommitted git changes (staged, unstaged, and untracked) into a few bullet points and flag risky changes. Use when the user asks for a summary of their changes, e.g. "summarize my changes", "what did I change?", "recap my diff", "what's uncommitted?", "review my changes before I commit".
---

# Summarize uncommitted diff

Read-only. Never stage, commit, stash, or edit files.

## Gather
1. `git status --porcelain` — if empty, reply "No uncommitted changes." and stop.
2. `git diff HEAD --stat` and `git diff HEAD` (staged + unstaged together).
   In a repo with no commits yet, use `git diff --cached` plus `git diff`.
3. Untracked files: `git ls-files --others --exclude-standard`. Read the small text ones; for large or binary ones, just list them.
4. If the diff is over ~2000 lines, work from `--stat` and read only the hunks of the riskiest files.

## Summarize
- 3–6 bullets, grouped by intent (feature, fix, refactor, config, tests), not one bullet per file.
- Each bullet: what changed and where (`path` or area). No line-by-line narration.

## Flag risks
Add a **⚠️ Risky** section only if something applies; otherwise write "No risky changes spotted."
For each item, give the file and one line saying why. Check for:
- Secrets or credentials (keys, tokens, passwords, `.env` files, private keys)
- Auth, permissions, crypto, input validation, or SQL changes
- DB migrations or schema changes, especially drops or renames
- Deleted files, or large deletions in non-test code
- Dependency or lockfile changes, version bumps
- CI/CD, Dockerfiles, deploy or infra config
- Disabled, skipped, or deleted tests; loosened assertions
- Debug leftovers: `console.log`, `print`, `debugger`, `TODO`/`FIXME` added, commented-out code
- Destructive commands added to scripts (`rm -rf`, `--force`, `DROP`)
- Public API or signature changes that could break callers

## Output format
**Summary** (N files, +X/−Y)
- …

**⚠️ Risky**
- `path` — reason
```

4. No subagents: this is a single small file. Nothing to log.
5. Sanity check: `head -5 .claude/skills/summarize-diff/SKILL.md` to confirm the frontmatter parses.

**Final reply to user**

> Created `.claude/skills/summarize-diff/SKILL.md`. It triggers on requests like "summarize my changes", "what did I change?" or "review my changes before I commit". It reads the staged, unstaged and untracked changes, gives you 3–6 bullets, and adds a **⚠️ Risky** section listing each flagged file with the reason. It flags things like secrets, auth code, migrations, dependency or CI changes, deletions, skipped tests and debug leftovers. It never changes anything in the repo. Restart the session or run `/skills` to load it. To use it in every repo, move it to `~/.claude/skills/`.