I've written the release notes. Both commits affect customers, so I kept both and dropped none. There are no breaking changes.

**Steps, in order**
1. TodoWrite: get the log, sort each commit into keep or drop, rewrite the kept ones in plain language, write the files, reply.
2. Log source: `git-log-jargon.txt`, which has 2 lines. No version or range was given, so the heading uses "Upcoming release".
3. Write `./.claude-skills-work/release-notes/triage.md`:
   ```markdown
   # Triage
   - 2b3c4d5 fix(sync): handle ETag 412 in SyncWorker.retryLoop when IDB quota exceeded, JIRA-2231 (#441) → Fixed — `fix`; customers saw syncing fail
   - 3c4d5e6 feat(ui): add useOptimisticRows hook to InvoiceGrid for <200ms perceived latency, JIRA-2240 (#440) → New — `feat`; the invoice table responds faster
   ```
4. Write `./.claude-skills-work/release-notes/release-notes.md`, shown below.
5. Nothing gets tagged, pushed or published.

**Reply**

---

```markdown
# Release notes — Upcoming release
## New
- Changes you make in the invoice table now show up instantly, without waiting for the server. (#440)
## Fixed
- Syncing no longer keeps failing when your browser's offline storage is full. (#441)
```

- **Kept:** 2. **Dropped:** 0.
- **Commits I couldn't classify:** none.
- **Breaking changes:** none, so nothing needs a "what to do" step.
- **Version:** tell me the version number and I'll replace "Upcoming release" in the heading.
- **Please check #441:** I'm assuming this means customers saw sync errors or saves that didn't go through when browser storage was full. If it actually shows up differently, tell me and I'll reword it.
- **Removed:** jargon such as ETag, IDB and the hook names, and the JIRA ticket IDs.

The notes are saved in `./.claude-skills-work/release-notes/`.