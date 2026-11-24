I drafted `skills/changelog-format/` with a SKILL.md and a 3-case `evals/evals.json`. I didn't run any evals. The repo's CLAUDE.md requires every skill to ship an `evals.json`, so the file is there, but the with/without-skill comparison was skipped as you asked.

**Assumptions:**
- Entries use [Keep a Changelog](https://keepachangelog.com) style.
- The skill belongs in the `frugal-skills` plugin.
- The plugin picks up new folders under `skills/` automatically, so `plugin.json` needs no change.

**What I'd do, in order:**

1. Write `skills/changelog-format/SKILL.md`:
   ```markdown
   ---
   name: changelog-format
   description: Formats changelog entries in a project's existing CHANGELOG convention (default Keep a Changelog). Use when the user asks to add, write, or tidy changelog entries, release notes for a CHANGELOG file, or "log this change".
   ---
   # Changelog Format

   **Does:** turn changes (commits, diff, PR, user's description) into entries in the project's CHANGELOG.
   **Does NOT:** pick version numbers, cut releases, edit released sections, or tag/push.

   ## Steps (TodoWrite each)
   1. Read the existing CHANGELOG (top ~60 lines). Match ITS conventions: headings, category names, bullet style, link/issue format, tense. No file → offer Keep a Changelog 1.1.0 and wait for yes.
   2. Group changes into the file's categories (default: Added, Changed, Deprecated, Removed, Fixed, Security). One change = one bullet.
   3. Write each bullet for users, not committers: what changed and its effect; no internal refactors unless they change behavior. Keep the PR/issue reference if one was given.
   4. Insert under `## [Unreleased]` (create it if missing). Never touch released sections.
   5. Show the diff. STOP for approval before saving if anything was ambiguous (category, breaking or not).

   ## Red flags → correction
   - Inventing a version or date → leave it under Unreleased; ask.
   - Pasting commit subjects verbatim ("fix typo", "wip") → rewrite or drop non-user-facing ones.
   - Reformatting old entries to "fix" style → don't; only add new ones.
   - Breaking change buried in Changed → mark it **BREAKING** (or use the file's convention) and say so in the reply.
   ```

2. Write `skills/changelog-format/evals/evals.json` (written but not run):
   ```json
   {
     "skill_name": "changelog-format",
     "evals": [
       {"id": 1, "prompt": "Add changelog entries for these commits: 'fix null deref in parser (#212)', 'wip', 'add --json flag to export', 'refactor utils'", "expected_output": "Entries under [Unreleased]: Added (--json flag), Fixed (parser, #212). The wip and refactor commits are dropped. No version invented.", "files": []},
       {"id": 2, "prompt": "Log that we removed the v1 API endpoints in CHANGELOG.md", "expected_output": "A Removed entry flagged as breaking, matching the existing file's style. Released sections untouched.", "files": ["files/CHANGELOG.md"]},
       {"id": 3, "prompt": "Write a changelog entry for this change; there's no changelog yet", "expected_output": "Offers Keep a Changelog and waits for confirmation before creating the file.", "files": []}
     ]
   }
   ```
   I'd also add a short `evals/files/CHANGELOG.md` fixture, an existing changelog in a non-default style with one released version, for case 2.

3. Add a "changelog-format: unvalidated (no baseline run)" item to `plan.md`.

**Reply to you:**

> I created `changelog-format` but didn't run any evals.
>
> One thing to consider: "obviously simple" is exactly when a skill often doesn't help. The model already knows changelog formats. `security-review` measured zero improvement over no skill twice and was folded into `code-review`. I wrote the skill around steps the model tends to skip on its own: matching the file's existing style, never inventing versions, and dropping commits users don't care about. Whether it actually helps is unproven.
>
> The repo's rules don't count a skill as done until it passes a with/without-skill comparison, so I've listed it in `plan.md` as unvalidated. That comparison is three short cases. Should I run it, or leave the skill unvalidated?