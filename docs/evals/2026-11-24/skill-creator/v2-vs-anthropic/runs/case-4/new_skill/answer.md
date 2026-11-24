Drafted `changelog-entry` with evals anyway. Evals are cheap, and they're the only way `skill-reviewer` can show the skill does better than no skill. A format the model already knows well is exactly the case where lift is often 0.

**What I would do, in order:**

1. **Read in one parallel batch:** `CLAUDE.md` and one sibling skill, e.g. `skills/code-review/SKILL.md`, for house style.
2. **Write `skills/changelog-entry/SKILL.md`:**

```markdown
---
name: changelog-entry
description: Turns a list of changes, commits or a diff summary into Keep a Changelog 1.1.0 entries and inserts them into CHANGELOG.md. Use when the user asks to add, write, format or update changelog entries or release notes in Keep a Changelog style.
---
# Changelog Entry
Write user-facing entries in the right section and place them under [Unreleased] unless told otherwise.
## Scope
DOES: classify changes, word entries, edit CHANGELOG.md (create it with the standard header if missing). Does NOT: pick version numbers, tag, bump package versions, push.
## Steps (TodoWrite items; the edited CHANGELOG.md is the checkpoint)
1. Read the input changes and the existing CHANGELOG.md (if any) once.
2. Drop entries with no user-visible effect (chore, CI, refactor, test, typo in code). List what you dropped in the reply.
3. Classify each kept change into exactly one of: Added, Changed, Deprecated, Removed, Fixed, Security. No other headings ("Improvements", "Misc" → map or ask).
4. Write each as one line: `- <what changed for the user>` (no commit hash, no "feat:" prefix, keep issue refs like `(#123)`).
5. Insert under `## [Unreleased]`, sections in the order above, merging into existing sections and not duplicating lines.
6. ⛔ Only when asked to cut a release: if no version is given, ask for it. Never invent one. Then rename to `## [X.Y.Z] - YYYY-MM-DD` (ISO date, today), add a fresh empty `## [Unreleased]`, and update the compare links at the bottom.
## Red flags
| If you notice… | Do this |
|---|---|
| Creating a new version heading unasked | Use [Unreleased] |
| Guessing a version number | Ask |
| Copying commit messages verbatim | Rewrite for users; drop internal ones |
| A change fits two sections | Pick the user-facing effect (a breaking removal → Removed) |
## Done when
CHANGELOG.md has the entries in standard sections and order, links are consistent, and the reply lists the added and dropped items.
```

3. **Write `skills/changelog-entry/evals/files/`:**
   - `CHANGELOG.md`: has a header, an `[Unreleased]` section with one `Fixed` item, a `[1.2.0] - 2026-10-01` section, and compare links.
   - `commits.txt`: about 8 conventional commits, including `feat: add CSV export`, `fix: crash on empty config (#41)`, `chore: bump eslint`, `ci: cache deps`, `feat!: remove --legacy flag`, `security: upgrade jwt lib (CVE-2026-1234)`, and `refactor: split parser`.

4. **Write `skills/changelog-entry/evals/evals.json`** with 4 cases:
   - **`add-from-commits`** ("Add these commits to the changelog", files: both): asserts the entries sit under `[Unreleased]`; the chore, ci and refactor commits are absent and listed as dropped; no `feat:`/`fix:` prefixes; `#41` is kept.
   - **`section-classification`** (same files): asserts `--legacy` appears under Removed, the jwt upgrade under Security, and the sections follow the order Added, Changed, …, Security.
   - **`release-no-version`** ("Cut a release with these", files: both): asserts the skill asks for a version number and writes no new version heading.
   - **`release-with-version`** ("Release 1.3.0", files: both): asserts a `## [1.3.0] - 2026-11-24` heading, a new empty `[Unreleased]`, and a `[1.3.0]` compare link plus an updated `[Unreleased]` link.

5. **Validate:** run `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/changelog-entry` and fix any FAIL until it's clean. I'm assuming it passes at about 2.3k chars.

**Assumptions**
- The skill lives in the core plugin as `skills/changelog-entry`.
- It follows Keep a Changelog 1.1.0.
- It writes to `CHANGELOG.md` at the repo root.
- It never bumps package versions.

**Eval cases**
- `add-from-commits`: entries go under `[Unreleased]` and internal commits are dropped.
- `section-classification`: only the standard sections, in the standard order.
- `release-no-version`: stops and asks for a version.
- `release-with-version`: correct heading, date and compare links.

Approve, or what should change? The next step is `skill-reviewer`, which runs a profile and a comparison against no skill. If it measures about 0 lift, the skill isn't worth keeping.