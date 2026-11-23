Plan (dry run). I'll skip the evals as you asked and won't argue the point. I'll do a quick manual read-through instead, since that costs nothing.

**Assumptions**
- Target format is [Keep a Changelog](https://keepachangelog.com) with an `## [Unreleased]` section. If you use a different house style, I'll adapt it.
- The skill goes in the repo's plugin layout at `plugins/<plugin>/skills/format-changelog/`. If you don't name a plugin, it goes at `~/.claude/skills/format-changelog/`.
- No scripts or reference files are needed. One `SKILL.md` is enough.

**1. Write `format-changelog/SKILL.md`**

```markdown
---
name: format-changelog
description: Format or rewrite changelog entries in Keep a Changelog style. Use when the user asks to add, clean up, or format CHANGELOG entries, release notes for a version, or "what changed" bullets for a release.
---

# Format changelog entries

## Output format
- Sections under a version heading, in this order, omitting empty ones:
  `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- Version heading: `## [X.Y.Z] - YYYY-MM-DD`; unreleased work goes under `## [Unreleased]`.
- One bullet per user-visible change, imperative-free past/present description
  ("Support for X", "Crash when Y is empty"), no trailing period.
- Reference issues/PRs at the end of a bullet: `(#123)`.
- Breaking changes: prefix the bullet with `**BREAKING:**` and put it first in its section.

## Procedure
1. Read the existing CHANGELOG.md (if any) and match its established conventions
   where they differ from the above — the file's own style wins.
2. Classify each raw change into a section. Internal-only changes (refactors, CI,
   test-only) are dropped unless the user asks to keep them.
3. Merge duplicates; split bullets that describe two unrelated changes.
4. Insert under `[Unreleased]` unless the user gives a version; never edit
   entries of already-released versions unless asked.
5. If a compare-link footer exists (`[1.2.0]: https://.../compare/...`), add/update
   the link for the new version.

## Don't
- Invent changes, versions, or dates not given or derivable from git/tags.
- Reword released entries.
```

**2. If it goes in a plugin:** bump the patch version in `plugins/<plugin>/.claude-plugin/plugin.json`, and add the matching version in `.claude-plugin/marketplace.json` if that file lists versions.

**3. Sanity check (not an eval):** I'll re-read the description to confirm it would trigger on prompts like "add this to the changelog" and "write release notes for 1.4.0", and that the procedure handles both the case with no existing CHANGELOG and the case with one.

**4. Commit:** `format-changelog: new skill (Keep a Changelog formatting)`. I won't push.

**Final reply:**

> Created `format-changelog/SKILL.md`. It formats entries in Keep a Changelog style, follows the existing CHANGELOG's conventions where they differ, and puts new entries under `[Unreleased]` by default. I skipped the evals as you asked. If it misfires later, the description triggers are the first thing to tighten. Let me know if your changelog uses a different format.