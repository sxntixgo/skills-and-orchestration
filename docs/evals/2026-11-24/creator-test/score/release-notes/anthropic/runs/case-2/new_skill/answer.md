**Steps I'd take:**

1. **TodoWrite** with the five skill steps. Work dir: `./.claude-skills-work/release-notes/git-log-internal/`. No range was given, so I'd name the folder after the file.
2. **Get the log:** use `case-files/2/git-log-internal.txt`. It has 4 lines.
3. **Classify:**
   ```
   python3 <skill-dir>/scripts/classify.py case-files/2/git-log-internal.txt \
     > .claude-skills-work/release-notes/git-log-internal/classified.json
   ```
   Assumed output: one each of `chore`, `ci`, `refactor` and `test`. None are breaking, nothing is reverted, every line parses, and the PRs are #427–#430.
4. **Judge each line and write `decisions.md`:**
   ```markdown
   # Decisions — git-log-internal.txt
   | Commit | PR | Type | Decision | Reason |
   |---|---|---|---|---|
   | bump vitest 2.1.0 → 2.1.4 | #430 | chore(deps) | drop | dev-dependency |
   | run lint on PRs only | #429 | ci | drop | CI |
   | rename getConn → getConnection | #428 | refactor | drop | internal |
   | invoice parser fixtures | #427 | test | drop | tests |
   ```
   The vitest bump is a test-tooling update. It isn't a security fix and doesn't change what users need to run it, so it's dropped.
5. **Write `RELEASE_NOTES.md`:**
   ```markdown
   No user-facing changes in this release.
   ```
6. **Hand off** (the reply below).

---

**Reply:**

This release has no user-facing changes, so `RELEASE_NOTES.md` just says "No user-facing changes in this release."

- **Kept / dropped:** 0 kept, 4 dropped: a dev-dependency bump (#430), a CI change (#429), a code rename (#428) and test fixtures (#427).
- **TODOs / borderline calls:** none.

The per-commit reasons are in `.claude-skills-work/release-notes/git-log-internal/decisions.md`.