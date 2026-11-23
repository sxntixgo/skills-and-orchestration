I'd create the skill without evals, as you asked. I'd still do one quick manual check so it isn't shipped completely untested.

**Steps, in order**

1. Look at the repo's conventions:
   - `ls skills/ plugins/*/skills/` to find where skills live.
   - `head -20` on one existing `SKILL.md` to copy its frontmatter style.
   - `ls CHANGELOG.md` to see whether the repo already has a changelog format.

   I'm assuming skills go in `skills/<name>/SKILL.md` with `name` and `description` frontmatter, and that the changelog follows Keep a Changelog.

2. Write `skills/changelog-format/SKILL.md`:

```markdown
---
name: changelog-format
description: Format changelog entries in Keep a Changelog style. Use when the user asks to add, write, clean up or format CHANGELOG entries, release notes for a version, or turn commits/PR titles into changelog lines.
---

# Changelog format

Turn raw input (commit messages, PR titles, notes) into changelog entries.

## Structure

- Put new entries under `## [Unreleased]` unless the user names a version.
- A version header is `## [X.Y.Z] - YYYY-MM-DD`.
- Group entries under these `###` headers, in this order, and leave out empty ones:
  Added, Changed, Deprecated, Removed, Fixed, Security.

## Entry rules

- One bullet per change, starting with `- `.
- Use the imperative mood, start with a capital letter and leave off the final period: `- Add retry to upload client`.
- Describe the effect on the user, not how it was built. Drop prefixes like `feat:`, `fix(scope):` and `chore:`.
- Pick the section from the content: `fix:` goes under Fixed and `feat:` under Added. Refactors and `chore:` items are left out unless they change what users see.
- Keep PR/issue references at the end: `(#123)`.
- Merge duplicates and reverted pairs into one entry, or drop them.
- Mark breaking changes with a leading `**Breaking:**` under Changed or Removed.

## Editing an existing CHANGELOG.md

- Follow the file's existing conventions (header style, date format, link references) when they differ from the rules above.
- Never change entries that are already released.
- If the file has link references at the bottom, add a new one for each new version header.

## Output

When the user only asked for text, return the formatted block. When they asked for the file to be updated, edit the file in place.
```

3. Skip the `evals/` directory.

4. Sanity check: run `scripts/quick_validate.py skills/changelog-format` if that script exists; otherwise check the frontmatter by hand. Then do one dry run in my head on a sample input to make sure the rules give an unambiguous result:
   - Input: `feat: add retry (#12)`, `fix(api): null crash`, `chore: bump deps`
   - Expected output: Added → `Add retry (#12)`; Fixed → `Fix null crash in API`; the deps bump is dropped.

5. If the plugin has a `marketplace.json` or `plugin.json` skill list, register the skill there.

**Final reply**

> I created `skills/changelog-format/SKILL.md` without evals, as you asked. It uses Keep a Changelog sections and maps conventional-commit prefixes to them (`feat:` → Added, `fix:` → Fixed, `chore:` and refactors dropped). It follows an existing CHANGELOG's own conventions where they differ and never changes released entries.
>
> I checked it with one sample run but didn't test it further. The part most likely to go wrong is which section an entry lands in when the commit has no prefix. If you see mistakes there, two or three evals covering that case would be worth adding.