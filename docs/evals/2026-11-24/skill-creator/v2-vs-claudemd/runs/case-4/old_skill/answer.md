I've written the `changelog-entries` skill, but it isn't done under the repo's rules. Rule 8 in CLAUDE.md says no skill is finished until a with/without-skill comparison has been run, and you asked me to skip that. I still wrote an `evals.json` because the folder layout requires it and the rule 8 comparison will need it later. I did not run that comparison.

The skill also carries a real risk. A frontier model already knows the Keep a Changelog format, and repeating what the model knows is the pattern that made `security-review` score 0.00. So I built the skill around steps the model tends to skip rather than the format: start from the git history since the last tag, write for users, and keep the comparison links and the Unreleased section correct.

## What I'd do, in order

1. Invoke `skill-authoring:skill-creator`, as CLAUDE.md requires.
2. TodoWrite: write SKILL.md · write evals.json · update README · update plan.md · run skill-reviewer · baseline eval (**skipped, per user**).
3. Write `skills/changelog-entries/SKILL.md`:

```markdown
---
name: changelog-entries
description: Drafts and formats CHANGELOG.md entries in Keep a Changelog 1.1.0 style from the git history since the last release. Use when the user asks to add, update, tidy, or release changelog entries.
---

# Changelog entries

**Does:** add or tidy entries under `## [Unreleased]`, or cut a release section.
**Does NOT:** bump versions in code, create tags, commit, or rewrite old releases.

## Steps (track as TodoWrite items)
1. Find the last release: `git describe --tags --abbrev=0`. If there is none, use the full history.
2. Collect changes: `git log <tag>..HEAD --no-merges --format='%h %s'`. Write them to
   `.claude-skills-work/changelog-entries/changes.md`. To resume, start from this file.
3. Put each change in one category, in this order: Added, Changed, Deprecated, Removed,
   Fixed, Security. Leave out refactors, CI, test-only and docs-only changes unless users can see them.
4. Rewrite each entry for users: imperative, one line, no commit hashes, and no internal jargon.
5. Edit CHANGELOG.md:
   - Put entries under `## [Unreleased]`. Leave out empty categories.
   - Releasing: rename Unreleased to `## [X.Y.Z] - YYYY-MM-DD` (ISO date), add a fresh empty
     `## [Unreleased]` above it, and update the compare links at the bottom.
6. **STOP:** show the diff and wait for the user to approve it. Don't commit.

## Red flags
- Pasting commit subjects verbatim, which gives a log instead of a changelog. Rewrite them for users.
- Inventing a version number or date. Ask the user.
- Editing released sections. Only touch Unreleased unless the user asks otherwise.
- Forgetting the `[Unreleased]: .../compare/vX.Y.Z...HEAD` link.
```

4. Write `skills/changelog-entries/evals/evals.json` with `skill_name` and three cases:
   - **raw-git-log:** add Unreleased entries from a messy log with chore and CI commits. Expected: those commits are dropped, the rest are categorized and rewritten.
   - **cut-release:** release 1.4.0. Expected: a dated section, a new empty Unreleased section and updated compare links.
   - **no-version-given:** "release this." Expected: it asks for the version and doesn't invent one.
5. Add a row for the skill to the skill list in `README.md`.
6. Add an unchecked item to `plan.md`: `- [ ] changelog-entries: baseline eval not run (user skipped 2026-11-24); unverified lift`.
7. Run `skill-authoring:skill-reviewer` for the static checks only (frontmatter, scope, red flags, checkpointing). Its eval loop would be skipped. I'd fix anything it flags.
8. No commit and no push.

## Final reply

> Added `skills/changelog-entries/` (SKILL.md, evals.json) and listed it in README. I didn't run the baseline eval, as you asked, so `plan.md` marks the skill as unverified. CLAUDE.md requires that comparison before a skill counts as done. This kind of skill tends to score near zero because the model already knows the format, so the 3-case comparison is worth running before release. Want me to run it?