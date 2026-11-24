The bug isn't fixed yet. "Sometimes does nothing" gives no repro, so I'd start by finding what triggers it. This is the exact sequence I'd follow.

**Assumptions:** the app is a React/TypeScript web app. `src/components/ExportButton.tsx` posts to `/api/export` and then starts the file download. No bug-report details, logs or browser info were given, so I treat them as not found.

### 1. Set up tracking
TodoWrite items: Reproduce, Isolate, Hypothesize, Verify, Fix, Confirm.

Create `./.claude-skills-work/debugging/export-button-noop/notes.md`:
```markdown
# Export button sometimes does nothing
Report: users say clicking Export intermittently has no effect. No steps/browser/logs provided.
## Repro
## Isolation
## Hypotheses
## Verification
## Fix
## Confirm
```

### 2. Reproduce ⛔ (no fix before this step passes)
- `rg -n "export" src/ --type ts -i | rg -i "button|onClick|download"` finds the handler and the API call.
- Read `ExportButton.tsx`, the export hook or service, and `/api/export`. Assumed finding: a module-level `let isExporting = false`. It's set to `true` on click, reset only in the success branch, and the click handler returns early when it is true.
- `git log -p --since=3.months -- src/components/ExportButton.tsx src/api/export*` checks whether a recent change introduced this.
- Write a failing test, `ExportButton.test.tsx`:
  1. Mock `/api/export` to reject once (500 or timeout), then succeed.
  2. Click, wait for the failure, click again.
  3. Expect a second request and a download to start.
- `npm test -- ExportButton`: record the real output in notes. Predicted failure: "expected fetch to be called 2 times, received 1".
- If that test passes, the trigger is somewhere else. Then I'd test, one at a time:
  - two fast double-clicks
  - a slow response (fake timers at 5s+)
  - an empty dataset
  - Safari's popup blocking when `window.open` runs after an `await`, because the user gesture is lost
- If none of these reproduce it, I'd stop and ask the user for browser and version, console errors, and what users did just before it failed.

### 3. Isolate
- Compare the passing case (first click succeeds) with the failing one (click after an earlier failure). The only difference is the earlier error.
- Shrink that to the smallest case: a single rejected promise.

### 4. Hypothesize
The cause, in testable form: "`isExporting` stays `true` after a failed or aborted request because the reset only happens on success. Every later click hits the early return until the page reloads."

### 5. Verify before fixing
- Add a temporary `console.debug('export click', { isExporting })` and rerun the test.
- Prediction: the second click logs `isExporting: true` and makes no request.
- If the prediction is wrong, go back to step 4 and try the next suspect from step 2.

### 6. Fix the cause with the smallest change
- Move the reset into a `finally` block, and store the flag in component state or a ref instead of a module-level variable.
- Remove the debug log.
- No other refactors. Anything unrelated I notice goes in notes as a separate item.

### 7. Confirm
- `npm test -- ExportButton` shows the new test passing; it stays as the regression test.
- `npm test` runs the full suite.
- Record the before and after output in notes.

### Final reply to the user
> **Not fixed yet: no repro.** The plan targets the most likely cause: a busy flag that a failed export never clears.
>
> - **Repro:** `npm test -- ExportButton` with the first `/api/export` call failing. Before the fix, the second click sends no request ("expected fetch to be called 2 times, received 1").
> - **Cause (verified with a debug log):** `isExporting` was reset only when an export succeeded. After one failed or timed-out export, every click hit the early return until the page reloaded. That's why it only happened "sometimes".
> - **Fix:** reset the flag in `finally`, and keep it in component state instead of module scope.
> - **After the fix:** the regression test passes and the full suite is green.
>
> If you have reports where no export had failed earlier, send the browser and any console errors. Safari blocking popups after the `await` is the next suspect.

(The last two bullets of that reply only apply if the assumed cause checks out in steps 2–5. Otherwise the reply reports which suspects were ruled out and asks for the details listed in step 2.)