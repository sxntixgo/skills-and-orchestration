I wrote `RELEASE_NOTES.md` from the two commits in `git-log-jargon.txt`. Both are user-facing, so both are in the notes and none were dropped. This is a dry run, so nothing actually ran; the steps below are what I would do.

**Steps**

1. **Get the log.** Use `case-files/3/git-log-jargon.txt`. The user gave no tag range, so the work folder is `./.claude-skills-work/release-notes/git-log-jargon/`.
2. **Classify.** Run:
   ```
   python3 .claude-skills-work/creator-test/gen/anthropic/skills/release-notes/scripts/classify.py case-files/3/git-log-jargon.txt > ./.claude-skills-work/release-notes/git-log-jargon/classified.json
   ```
   Expected result: one `fix` (scope `sync`, #441) and one `feat` (scope `ui`, #440). Neither is breaking, and there are no reverts and no unreadable lines.
3. **Decide each commit.** Write `decisions.md`:
   ```markdown
   - 2b3c4d5 fix(sync) #441 — KEPT (Fixed): user-visible sync failure
   - 3c4d5e6 feat(ui) #440 — KEPT (New): user-visible speed-up in invoice table
   ```
4. **Write `RELEASE_NOTES.md`:**
   ```markdown
   ## New
   - Edits in the invoice table now show up instantly, without waiting for the server to respond. (#440)
   ## Fixed
   - Syncing no longer gets stuck retrying when your browser's offline storage is full. (#441)
   ```
   The code names (`SyncWorker.retryLoop`, `useOptimisticRows`, `InvoiceGrid`, ETag 412, IDB), the JIRA IDs and the commit hashes are left out. The PR numbers are kept exactly as they appear in the log.

**Final reply**

> Release notes are in `RELEASE_NOTES.md`: 2 commits kept, 0 dropped, no breaking changes and no TODOs.
>
> Please check how I translated the technical terms:
> - **#441:** I read "IDB quota exceeded" as the browser's offline storage being full, and the ETag 412 handling as sync retrying instead of getting stuck. If the fix actually changes what users see in another way, such as a new error message, I'll reword it.
> - **#440:** I described "<200ms perceived latency" as edits showing up instantly. I left out the exact number because it's an internal target.
>
> I also removed the JIRA IDs (JIRA-2231, JIRA-2240) as internal references. If your customers can see those tickets, I'll put them back.