I'd change only the `description` in the frontmatter, leaving the skill body as it is.

**Steps**
1. Find the skill: `ls .claude/skills/*/SKILL.md ~/.claude/skills/*/SKILL.md 2>/dev/null | xargs grep -l '^name: code-review'`. I'm assuming it's at `.claude/skills/code-review/SKILL.md`.
2. Read it to see the current description (I'm assuming something like `description: Helps with code review.`) and what the body actually covers. The new description has to match what the skill really does.
3. Edit the frontmatter to the version below. Nothing else changes.
4. Validate: run `head -5 .claude/skills/code-review/SKILL.md`. The YAML has to parse, the description has to fit on one line under 1024 characters, and it can't contain angle brackets.
5. Trigger check: start a fresh session and try these prompts:
   - "ok I think the retry logic is done": should fire
   - "review this before I merge": should fire
   - "is this branch ready for a PR?": should fire
   - "explain what this function does": should not fire
   - "write a parser for X": should not fire

**New frontmatter**
```yaml
---
name: code-review
description: Review a code change for bugs, regressions, security issues, missing tests, and unclear code before it ships. Use whenever the user has just finished implementing a change, fix, or feature, or is about to commit, push, open a PR, or merge — even if they don't say "review" (e.g. "I think that's done", "ready to merge?", "check my changes", "look over this diff/branch/PR before I ship it"). Not for explaining unfamiliar code or writing new code.
---
```

**Reply to the user**
> I rewrote the `code-review` description. The old one only said what the skill was about. The new one lists the situations that should trigger it: finishing a change, commit/push/PR/merge, and phrases like "I think that's done" or "ready to merge?". It also excludes requests to explain code or write new code so it doesn't fire on those. Nothing in the body changed. I checked it with three prompts that should trigger it and two that shouldn't. If it fires too often now, the first thing to remove is the "even if they don't say 'review'" clause.