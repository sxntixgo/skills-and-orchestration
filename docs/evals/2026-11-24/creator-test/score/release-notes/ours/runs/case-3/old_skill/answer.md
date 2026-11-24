Steps: read `git-log-jargon.txt` (2 commits) and reply with the notes below. I wouldn't write a file, since no destination was given.

---

## What's new

**Faster invoice editing**
Changes you make in the invoice list now show up right away. You no longer wait for the server to confirm each edit.

## Fixes

**More reliable syncing when your device is low on storage**
Before this fix, syncing could stall or fail if your browser's local storage was full and someone else had changed the same data. Sync now recovers on its own and finishes, so you don't need to reload.

---

Assumptions (please confirm before publishing):
- "Sync" is how the app keeps data on the user's device in step with the server. "InvoiceGrid" is the invoice list customers see.
- I left out the ticket and PR numbers (JIRA-2231/2240, #440/#441) and the "<200ms" figure because they're internal. I can add the figure back as "under 0.2 seconds" if you want to promise that.
- There's no version number or date yet, so tell me what to use for the heading.