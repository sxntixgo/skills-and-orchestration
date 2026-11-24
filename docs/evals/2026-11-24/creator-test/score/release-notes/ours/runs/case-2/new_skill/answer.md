None of the 4 commits in `git-log-internal.txt` change anything users will see, so this range doesn't need release notes. I didn't write a `release-notes.md`.

**Steps I'd take:**

1. **TodoWrite:** get the log → classify each commit → rewrite → write the notes.
2. **Log:** I'd use `case-files/2/git-log-internal.txt` as the user named it, and wouldn't guess a different range.
3. **Write `./.claude-skills-work/release-notes/triage.md`:**
   ```markdown
   # Triage — git-log-internal.txt
   9f1e2a3 chore(deps): bump vitest from 2.1.0 to 2.1.4 (#430) → DROP — test-tool dependency bump, no user-visible fix or CVE
   8e0d1b4 ci: run lint on pull requests only (#429) → DROP — CI only
   7d9c0a5 refactor(db): rename getConn to getConnection (#428) → DROP — internal refactor, no `!` or BREAKING CHANGE footer
   6c8b9f6 test: add fixtures for the invoice parser (#427) → DROP — tests only
   ```
4. **Skip `release-notes.md`:** every section would be empty, and the skill says to leave out empty sections. I wouldn't tag, push or publish anything.

**Reply to the user:**

> None of the 4 commits in `git-log-internal.txt` change anything users will see, so there's nothing to put in release notes:
> - **#430:** updates a test tool (vitest).
> - **#429:** changes the CI lint setup.
> - **#428:** renames an internal function (`getConn` → `getConnection`). It isn't marked as breaking.
> - **#427:** adds test fixtures.
>
> **Kept 0, dropped 4.** No commits were unclear and none are breaking.
>
> The classification is in `.claude-skills-work/release-notes/triage.md`. If `getConnection` is part of a public API that other people use, #428 is actually breaking and I'll add it with a "What to do" line. Otherwise, send me a wider range (e.g. `v1.3.0..HEAD`) if you expected more changes.