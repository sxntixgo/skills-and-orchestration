I'll build the skill, but I won't skip the evals. This repo's rule 8 requires them for every skill, simple ones included. Simple skills also tend to hit edge cases, like entries with no category or breaking changes. They'll be 3–5 short cases.

**What I'd do, in order:**

1. **Make a TodoWrite list with five items:** Clarify intent (gate) · Frontmatter · Body · Scaffold + evals · Hand off to `skill-reviewer`.

2. **Write `./.claude-skills-work/format-changelog-entry/plan.md`** as a draft for you to approve:
   ```markdown
   # format-changelog-entry — plan (DRAFT, awaiting approval)

   ## Trigger (proposed)
   Use when the user asks to write, add, or format a changelog entry
   (e.g. "add a changelog entry for this fix", "format these notes for CHANGELOG.md").

   ## Scope
   DOES: turn a change description / commit list into entries in the project's
   changelog format; place them under the right version/Unreleased + category.
   Does NOT: bump versions, tag, publish releases, or invent changes not given.

   ## Success criteria (observable)
   - Entry lands under the correct heading (Unreleased or given version) and category.
   - Matches existing CHANGELOG.md style (bullets, tense, links) when one exists.
   - Breaking changes are flagged explicitly.
   - No fabricated items.

   ## Open questions (blocking)
   1. Format: Keep a Changelog (Added/Changed/Fixed…), Conventional Commits groups, or "match the repo's existing file"?
   2. Input: free-text description, commit range, PR, or all of these?
   3. Edit CHANGELOG.md directly, or only output the entry?
   4. Where should the skill live: `skills/` or a plugin's `skills/`?

   ## Evals: required (rule 8), 3–5 cases, written in stage 4.
   next: approve stage 1
   ```

3. **Stop here.** No frontmatter, body, scaffold or evals until you approve. I won't read the references or run `scripts/new_skill.sh` yet.

**Reply to the user:**

> I'll build it, but not without evals. Rule 8 requires them for every skill. They'll be 3–5 short cases.
>
> The draft plan is in `./.claude-skills-work/format-changelog-entry/plan.md`. Before I write the skill, I need answers to four questions:
> 1. **Format:** Keep a Changelog, Conventional Commits groups, or match whatever `CHANGELOG.md` the repo already has?
> 2. **Input:** a plain description, a commit range, a PR, or any of these?
> 3. **Output:** should it edit `CHANGELOG.md` directly or only print the entry?
> 4. **Location:** `skills/` or a plugin?
>
> Once you approve the plan with these answers, I'll write the frontmatter, the body and the evals, then hand it to `skill-reviewer`.