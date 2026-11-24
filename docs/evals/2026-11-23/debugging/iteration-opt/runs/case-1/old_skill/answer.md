No fix yet: "sometimes does nothing" doesn't come with a repro, and the skill says to reproduce and verify the cause before changing code. Below is what I'd do, in order. Anything about the project's contents is assumed and marked.

**1. Track the work**
- TodoWrite items: Reproduce, Isolate, Hypothesize, Verify cause, Fix, Confirm.
- Create `./.claude-skills-work/debugging/export-button-noop/notes.md`:
  ```markdown
  # Bug: export button sometimes does nothing
  Report: users, intermittent. No steps, browser, data or error given.
  ## Repro
  (pending)
  ## Isolation
  ## Hypotheses
  ## Verified cause
  ```

**2. Find the code path (read only, no edits)**
- `rg -n -i "export" --glob '!node_modules' src/` to find the button and its handler.
- Assumed result: `src/components/ExportButton.tsx` calls `api/export.ts`, which POSTs `/api/export`, then a server handler builds a CSV or XLSX and the client triggers a download.
- `git log --oneline -20 -- <those files>` to check for a recent change.
- Read the handler end to end, looking for paths that do nothing silently:
  - a `disabled`/`isExporting` flag that doesn't reset on error;
  - a `catch` that swallows the error;
  - a promise that isn't awaited;
  - a blob URL revoked before the download starts;
  - a popup or download blocked because it runs after an `await`;
  - an empty dataset that returns early.
- These are candidates only. I won't fix anything on that basis.

**3. Reproduce (⛔ the gate)**
- Run the app, click export in a few different conditions and watch the console and network tab:
  - empty data, large data, slow network (throttled), double-click, export a second time after a failed one, a different browser.
- Check server logs for `/api/export` errors or timeouts.
- Once I find the trigger, write a failing test as the repro. For example, if a failed request leaves the button stuck: "after one rejected export, a second click fires a request" (fails).
- Log the exact steps and conditions in `notes.md`.
- **If I can't reproduce it, I stop and ask the user** (reply below) rather than guessing.

**4. Isolate → hypothesize → verify**
- Shrink to the smallest failing case and add temporary logging at each stage: click → handler → request → response → download.
- State one testable root cause. Example (assumed): "`isExporting` is set true and only reset on success, so after one failed or timed-out export the handler returns early on every later click."
- Verify it with a log or assertion on `isExporting` at click time, changing one variable at a time. If the evidence disagrees, go back to forming a hypothesis.

**5. Fix the verified cause only**
- Example: reset the state in `finally`, and show the error to the user instead of swallowing it.
- No unrelated cleanup. Other issues I notice go in `notes.md`.

**6. Confirm**
- The repro test now passes and stays in as a regression test.
- Run the tests around the export feature (`npm test -- export`).
- Remove the temporary logging.
- Record why it broke and why the fix works in `notes.md`.

**Reply if step 3 can't reproduce it:**

> I couldn't reproduce "export does nothing" yet. I tried empty, large and slow exports, double-clicks, and exporting again after a failure. I don't want to ship a guessed fix, so could you give me any of these?
> - Which page or export type (CSV, XLSX, PDF), and roughly how much data?
> - Browser and version, and whether it fails on the first click or only after an earlier export.
> - Any console or network errors, or a timestamp so I can find it in the server logs.

**Reply once it's fixed:**

> Fixed. **Cause:** `<verified cause>`, which happens when `<trigger>`. **Fix:** `<change>` in `<file:line>`. Regression test `<name>` failed before the fix and passes now, and the surrounding export tests pass.