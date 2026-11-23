**Assumptions:** this is a personal skill, so it goes in `~/.claude/skills/summarize-diff/`. "Uncommitted" covers staged, unstaged and untracked files. The skill only reads the repo and never stages, commits or changes anything. The request is clear enough that I'd skip clarifying questions and put the defaults in the final reply.

## 1. Write `~/.claude/skills/summarize-diff/SKILL.md`

```markdown
---
name: summarize-diff
description: Summarize the uncommitted git changes (staged, unstaged, and untracked) into a few bullet points and flag risky changes. Use when the user asks for a summary of their changes, "what did I change", "summarize my diff", "recap my work", or wants to check their changes before committing. Not for writing commit messages, reviewing a PR, or diffing committed branches.
---

# Summarize uncommitted changes

Read-only: never stage, commit, stash, or modify files.

## Gather
1. `git status --porcelain=v1` — if empty, say "No uncommitted changes" and stop.
2. `git diff HEAD --stat` (staged + unstaged), then `git diff HEAD` for content.
   For diffs over ~1500 lines, read per file (`git diff HEAD -- <path>`), skipping lockfiles and generated files after noting them.
3. Untracked: `git ls-files --others --exclude-standard`; read small text files, list the rest.
4. No commits yet (no HEAD): use `git diff --cached` + `git diff`.

## Summarize
- 3–6 bullets, grouped by intent (feature/fix/refactor/config), not by file.
- Each bullet names the key files. Lead with a one-line totals: `N files, +A/−D`.

## Flag risks
Add a **⚠ Risky** section only if something applies; cite file:line and say why:
- Secrets/credentials: keys, tokens, passwords, `.env`, private keys
- Data: migrations, schema changes, dropped columns/tables, destructive SQL
- Security: auth, permissions, CORS, crypto, input validation removed
- Deletions: removed files or large removed blocks; removed error handling
- Tests: deleted tests, `.skip`/`xit`/`@Ignore`, lowered assertions
- Deps/infra: dependency or lockfile bumps, CI/CD, Dockerfile, deploy config
- Leftovers: debug prints, `TODO`/`FIXME` added, commented-out code, conflict markers
- Binary or very large files added

If nothing is risky, say "No risky changes spotted." Don't pad with low-value flags.

## Output
**Summary** (bullets) → **⚠ Risky** (bullets, or the no-risk line). Nothing else.
```

## 2. Write `~/.claude/skills/summarize-diff/evals/evals.json`

```json
{
  "skill_name": "summarize-diff",
  "evals": [
    {"id": 1, "prompt": "summarize my changes", "fixture": "risky",
     "expectations": ["3-6 summary bullets", "flags .env API key", "flags DROP COLUMN migration", "flags skipped test", "does not modify repo"]},
    {"id": 2, "prompt": "what did I change so far?", "fixture": "benign",
     "expectations": ["summary bullets present", "states no risky changes", "no invented risks"]},
    {"id": 3, "prompt": "quick recap of my diff before I commit", "fixture": "clean",
     "expectations": ["reports no uncommitted changes", "no bullets fabricated"]},
    {"id": 4, "prompt": "summarize my changes", "fixture": "untracked-only",
     "expectations": ["mentions untracked files", "does not say 'no changes'"]}
  ],
  "trigger_evals": [
    {"query": "can you give me a summary of my changes", "should_trigger": true},
    {"query": "what have I modified in this repo?", "should_trigger": true},
    {"query": "anything risky in what I've got uncommitted?", "should_trigger": true},
    {"query": "write a commit message for this", "should_trigger": false},
    {"query": "review PR #42", "should_trigger": false},
    {"query": "summarize the README", "should_trigger": false}
  ]
}
```

## 3. Build fixture repos
I'd write a script at `evals/make_fixtures.sh` that creates repos under `/tmp/summarize-diff-fixtures/`:
- **risky:** an auth refactor, a migration with `ALTER TABLE users DROP COLUMN email`, a `.env` containing `OPENAI_API_KEY=sk-...` (a dummy value), a test marked `it.skip`, a `package.json` dependency bump, and a stray `console.log`.
- **benign:** README edits and a renamed helper.
- **clean:** no changes.
- **untracked-only:** two new files.

## 4. Run with-skill vs. baseline
I'd spawn 8 subagents in parallel (`model: "sonnet"`), one with the skill and one without for each of the 4 fixtures:
> "cd /tmp/summarize-diff-fixtures/<fixture>. User says: '<prompt>'. [With-skill: First read ~/.claude/skills/summarize-diff/SKILL.md and follow it.] Reply as you would to the user. Do not modify the repo."

After each run I'd check `git status --porcelain` in the fixture to confirm the repo wasn't touched.

## 5. Grade
I'd spawn one grader subagent (`model: "opus"`):
> "Grade each output against its expectations in evals.json. Return pass/fail per expectation with a one-line reason, as JSON."

I'd save the results to `evals/results/iteration-1.json` and log the pass rates for with-skill vs. baseline.

## 6. Iterate
I'd fix failures in SKILL.md and rerun the failing cases. Likely fixes: missing untracked files, or false positives such as flagging README edits. I'd stop when every expectation passes and the skill clearly beats the baseline on risk flagging.

## 7. Check triggering
I'd run each `trigger_evals` query against the description, with a subagent judging whether the skill would load. If the commit-message case triggers, I'd tighten the "Not for" clause.

## Final reply

The `summarize-diff` skill is in `~/.claude/skills/summarize-diff/` and fires on requests like "summarize my changes", "what did I change" or "recap my diff". It reads staged, unstaged and untracked changes and gives 3–6 bullets grouped by intent. A **⚠ Risky** section points to exact lines for secrets, migrations or destructive SQL, auth or security edits, removed tests or error handling, dependency or CI changes, debug leftovers, and large binaries. It never changes the repo.

**Results (iteration N):** with-skill X/Y expectations, baseline Z/Y. The trigger evals were 6/6.

**Defaults I chose:**
- It's a personal skill, not a project skill.
- Untracked files count as changes.
- The skill doesn't write commit messages.

Tell me if you want any of these changed.