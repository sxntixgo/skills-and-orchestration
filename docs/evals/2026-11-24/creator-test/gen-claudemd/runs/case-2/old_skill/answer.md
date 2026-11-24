I wrote the `release-notes` skill and its evals to `skills/release-notes/`. A script check passed: the JSON parses, every fixture it points to exists, the frontmatter `name` matches the folder, and SKILL.md is 75 lines. I haven't run the evals yet, so it isn't proven that the skill helps.

**`SKILL.md`** works in three steps:
1. **Sort the commits:** it puts every commit into a table, saved to `.claude-skills-work/release-notes/classified.md`, and decides whether to keep or drop it.
2. **Rewrite:** it turns the kept commits into plain-language notes, saved to `notes.md` in the same folder.
3. **Check:** it confirms every input line was handled, PR numbers match the input exactly, breaking changes come first, and the notes contain no jargon.

Choices I made that you didn't specify:
- **Section order:** Breaking changes, Security, New, Improved, Fixed.
- **Breaking change with no stated migration step:** it writes `Action required: TODO - confirm migration step` instead of guessing one.
- **Reverts:** if a commit and its revert are both in the log, both are left out.
- **Unsure commits:** these go under "Needs your call" rather than into the notes.
- **No log given:** it stops and asks for one instead of running `git` itself.
- **Not covered:** version bumps, tagging and publishing.

**`evals/evals.json`** has 5 cases, using fixture logs in `evals/files/`:
1. `mixed.log`: a mix of user-facing changes, one breaking change and internal commits; checks grouping, ordering, PR numbers and that internal work is dropped.
2. `breaking-no-action.log`: breaking changes without migration steps, a revert pair, and a merge commit.
3. `internal-only.log`: mostly internal commits plus one security fix; checks that the notes aren't padded.
4. No log given: it should ask for one.
5. A request for a developer code summary: the skill shouldn't fire.

**Still to do:**
- I followed the `skill-creator` rules by hand because the skill itself isn't loadable in this session.
- The required with-skill vs. without-skill comparison and the `skill-reviewer` pass haven't run. In a `claude --plugin-dir .` session, run `skill-authoring:skill-reviewer` on `skills/release-notes`.
- `plan.md` isn't updated.