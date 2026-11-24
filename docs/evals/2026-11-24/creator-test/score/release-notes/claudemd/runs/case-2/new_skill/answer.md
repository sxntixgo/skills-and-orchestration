None of the 4 commits in `git-log-internal.txt` affect users, so there are no release notes to write for this range.

**What I'd do, in order:**

1. Create TodoWrite items: Classify, Rewrite, Verify.
2. Write `.claude-skills-work/release-notes/classified.md`:

   ```markdown
   | hash | type | breaking? | keep/drop | reason | PR |
   |---|---|---|---|---|---|
   | 9f1e2a3 | chore(deps) | no | drop | dev-only test dependency bump; no user-visible or security fix | #430 |
   | 8e0d1b4 | ci | no | drop | CI pipeline change | #429 |
   | 7d9c0a5 | refactor(db) | no | drop | internal rename, no user-visible effect | #428 |
   | 6c8b9f6 | test | no | drop | test fixtures only | #427 |
   ```

3. Write `.claude-skills-work/release-notes/notes.md`:

   ```markdown
   ## Release notes

   No user-facing changes in this release.
   ```

4. Verify: 4 rows for 4 input lines. Nothing was kept, so the notes contain no PR numbers, which is correct. There are no breaking changes. The notes use no jargon and include nothing without a source commit. No `git` commands were run.

**Final reply:**

> ## Release notes
>
> No user-facing changes in this release.
>
> 4 commits: 0 kept, 4 dropped, 0 breaking, 0 unclear
>
> Dropped: a test-tool dependency bump (#430), a CI lint change (#429), an internal database rename (#428) and test fixtures (#427). If one of these did change something users see, tell me and I'll add it.