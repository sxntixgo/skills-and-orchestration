Two commits in, both kept. The release notes are below.

## Release notes

### New
- Invoice list changes now show up straight away, without waiting for the server (#440).

### Fixed
- Syncing no longer fails when your browser's offline storage is full (#441).

2 commits: 2 kept, 0 dropped, 0 breaking, 0 unclear.

---

**Steps I'd take:**

1. **TodoWrite** with three items: Classify, Rewrite, Verify.
2. **Write `.claude-skills-work/release-notes/classified.md`:**
   ```
   | hash | type | breaking? | keep/drop | reason | PR |
   |---|---|---|---|---|---|
   | 2b3c4d5 | fix | no | keep (Fixed) | users could hit sync failures when browser storage is full | #441 |
   | 3c4d5e6 | feat | no | keep (New) | faster-feeling invoice list is user-visible | #440 |
   ```
3. **Write `.claude-skills-work/release-notes/notes.md`** with the notes above.
4. **Verify:**
   - 2 input lines and 2 rows.
   - PR numbers #440 and #441 are in the notes and there are no others.
   - There are no breaking changes.
   - No jargon is left: I removed ETag, 412, IDB, SyncWorker, useOptimisticRows, InvoiceGrid, the JIRA IDs, scopes and hashes.
   - Every bullet comes from a commit.
5. **Return** the notes and the count line.

**Assumptions:**
- "IDB" means IndexedDB, the browser's offline storage.
- "Optimistic rows" means edits appear in the list right away, before the server confirms them.
- If either guess is wrong, only the wording of that bullet needs to change.
- No version was given, so the title has none.