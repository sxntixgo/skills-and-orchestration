I created `changelog-format` and skipped the eval runs as you asked. I still wrote a small `evals/evals.json` without running it, because this repo's CLAUDE.md requires every skill to ship one (rule 8). Nothing is on disk here, so I assumed the skill belongs in the main `frugal-skills` plugin (`skills/`), not `skill-authoring`.

One concern before you rely on it: Keep a Changelog is a well-known format, and this repo already found that skills which restate things the model knows add nothing (`security-review` measured 0.00 lift). So I kept the skill to the steps the model tends to skip on its own:
- reading the existing file first
- never editing past releases
- not inventing entries
- keeping the compare links at the bottom correct

It does not explain the format itself.

### Steps, in order

1. **TodoWrite:** draft SKILL.md, write evals.json (not run), update plan.md, report.
2. **Write `skills/changelog-format/SKILL.md`:**

```markdown
---
name: changelog-format
description: Formats and inserts changelog entries in Keep a Changelog 1.1.0 style (Unreleased section, Added/Changed/Deprecated/Removed/Fixed/Security, dated releases, compare links). Use when the user asks to add, update, or cut a release in CHANGELOG.md, or to turn commits/PRs into changelog entries.
---

# Changelog Format

**Does:** add entries to `CHANGELOG.md`, cut a release from `[Unreleased]`, fix compare links.
**Does NOT:** bump versions in code, tag or push, rewrite past releases, or create a changelog for a repo that has none (ask first).

## Checklist (track as TodoWrite items)
1. Read the existing `CHANGELOG.md`. Match its heading style, its link style, and its order of entries within a section.
2. Collect changes only from what the user gave (commits, PR list, a description). If the source is unclear, STOP and ask.
3. Put each change in exactly one section: Added, Changed, Deprecated, Removed, Fixed, Security. Use only those sections, in that order, and omit empty ones.
4. Write each entry for users, not developers: one line, past-tense effect ("Fixed crash when…"), no commit hashes unless the file already uses them.
5. Add new entries under `## [Unreleased]`. To cut a release, rename it to `## [X.Y.Z] - YYYY-MM-DD` (ISO date), add a fresh empty `## [Unreleased]` above it, and update the compare links at the bottom (`[Unreleased]: …/compare/vX.Y.Z...HEAD`, `[X.Y.Z]: …/compare/vPREV...vX.Y.Z`).
6. Show the diff and stop. Do not commit.

## Red flags → correction
- Editing an already-released section → leave it alone and add to Unreleased.
- Making up entries from code you skimmed → use only the changes you were given; ask if any are missing.
- One entry per commit ("fix typo", "wip") → merge them or drop internal-only noise.
- Version or date guessed → ask for the version; use today's date only when cutting the release.
```

3. **Write `skills/changelog-format/evals/evals.json`** (cases and assertions, not run):

```json
{
  "skill_name": "changelog-format",
  "evals": [
    {"id": 1, "prompt": "Add these to the changelog: feat: CSV export; fix: login redirect loop; chore: bump eslint",
     "expected_output": "Added/Fixed entries under [Unreleased]; chore dropped or not user-facing",
     "files": ["evals/files/CHANGELOG.md"],
     "assertions": ["Entries under [Unreleased]", "CSV export in Added", "Redirect fix in Fixed", "No eslint bump entry", "Released sections unchanged"]},
    {"id": 2, "prompt": "Cut release 1.4.0 from Unreleased",
     "expected_output": "Dated 1.4.0 heading, new empty Unreleased, compare links updated",
     "files": ["evals/files/CHANGELOG.md"],
     "assertions": ["Heading '## [1.4.0] - YYYY-MM-DD'", "Empty [Unreleased] above it", "Both compare links updated"]},
    {"id": 3, "prompt": "Update the changelog for my last few commits",
     "expected_output": "Asks for or reads the commit range; does not invent entries",
     "files": [],
     "assertions": ["Does not invent changes", "No commit performed"]}
  ]
}
```

4. **Write `skills/changelog-format/evals/files/CHANGELOG.md`:** a short sample with `[Unreleased]`, `1.3.0` and `1.2.0` sections, and compare links.
5. **Update `plan.md`:** add "changelog-format — drafted, evals written, baseline comparison NOT run" as an unchecked task.
6. **Not done:** the with-skill vs. no-skill runs, `skill-reviewer`, `/reload-plugins`, and any commit.

### Reply to you

> Created `skills/changelog-format/` (SKILL.md plus an evals.json that hasn't been run). Per your request I skipped the eval runs, so under the repo's rules the skill isn't marked done: `plan.md` lists it as unvalidated. Since the model already knows Keep a Changelog well, the skill may add little, which is the same pattern that got `security-review` folded. If you ever want proof it helps, `skill-reviewer` can run the 3 cases against a no-skill baseline. Run `/reload-plugins` to try it as `frugal-skills:changelog-format`.