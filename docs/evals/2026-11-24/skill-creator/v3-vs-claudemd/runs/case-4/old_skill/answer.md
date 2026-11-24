I'm creating the skill but not skipping evals entirely. This repo's CLAUDE.md requires every skill to ship `evals/evals.json` (rule 8), so I'll write that file. I'll leave out the expensive part, the with/without-skill baseline run, as you asked. The skill will be marked unvalidated rather than done.

There's also a bigger risk. Keep a Changelog is a format the model already knows. CLAUDE.md records that skills which only restate known knowledge measured 0.00 lift (`security-review`). So I'll write this one around process, not format rules.

## Steps

1. **Invoke `skill-authoring:skill-creator`**, as the working agreement requires, and follow its scaffold: `skills/keep-a-changelog/` with `SKILL.md` and `evals/evals.json`.

2. **Write `skills/keep-a-changelog/SKILL.md`:**

```markdown
---
name: keep-a-changelog
description: Turns commits, PR titles or rough notes into Keep a Changelog entries and merges them into CHANGELOG.md under [Unreleased]. Use when the user asks to add, update or tidy changelog entries.
---

# Keep a Changelog entries

**Does:** classify changes, write user-facing entries, merge into an existing CHANGELOG.md.
**Does NOT:** bump versions, tag releases, edit other files, invent changes not in the input.

## Checklist (TodoWrite)
1. Collect input: the user's notes, or `git log <last-tag>..HEAD --oneline` if none given.
2. Classify each change: Added / Changed / Deprecated / Removed / Fixed / Security. Drop internal-only changes (CI, refactors, tests) unless the user wants them.
3. Rewrite each entry for users: imperative and outcome-focused, one line, issue/PR ref if present.
4. Write the draft to `.claude-skills-work/keep-a-changelog/draft.md`. **STOP** and show it if any classification was a guess.
5. Merge into `## [Unreleased]`: create the section if it's missing, reuse existing subsections, keep section order, no duplicates.
6. Report: entries added and items dropped (with reasons).

Resume: if `draft.md` exists, start at step 5.

## Red flags
- Pasting raw commit messages → rewrite them for users.
- Creating a version heading or date → only under [Unreleased] unless told otherwise.
- Merging two changes into one entry, or splitting one into several → one change, one line.
- Unsure whether something is breaking → ask; don't guess "Changed" vs "Removed".
```

3. **Write `skills/keep-a-changelog/evals/evals.json`** with 3 cases:
   - **Raw notes, no CHANGELOG.md:** creates the file with a header and `[Unreleased]`, and classifies the notes correctly.
   - **Existing CHANGELOG.md with a populated `[Unreleased] ### Fixed`:** appends to it without duplicating the heading, and doesn't create a version heading.
   - **Mixed commit log** (feat, ci, refactor, a security fix, a removed flag): drops the internal commits, puts the security fix under Security and the removed flag under Removed, and rewrites messages for users.

4. **Update `plan.md`:** add `- [ ] keep-a-changelog — written; baseline comparison NOT run (skipped at user request)`. I won't mark the item done.

5. **Skipped:** the baseline comparison runs and `skill-reviewer`.

## Reply

I created `skills/keep-a-changelog/` with `SKILL.md` and 3 eval cases in `evals/evals.json`. I didn't run any evals.

- **Eval file still written:** this repo requires an `evals/evals.json` for every skill (CLAUDE.md rule 8), so I didn't drop it.
- **Unvalidated:** I left it unchecked in `plan.md` because no baseline comparison has been run.
- **Likely low value:** the model already knows Keep a Changelog, and `security-review` was folded because it showed zero lift. Any value here comes from the process (filtering internal commits, merging into `[Unreleased]` without duplicates, the stop gate), not from the format rules.
- **Next step:** a baseline run on these 3 cases would tell you whether the skill helps or just costs tokens. If it shows no lift, I'd suggest deleting the skill.