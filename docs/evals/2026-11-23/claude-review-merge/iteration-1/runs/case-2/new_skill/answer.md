T2 is rejected and sent back as attempt 2. The skipped test alone is enough to reject it, and the `App.tsx` change goes back with it.

**Assumptions:**
- The run is `2026-11-23-export` and T2 is on attempt 1. `max_rejections` is 3, so this is not a takeover.
- T2 builds `web/src/components/ExportButton.tsx`. It may change only that file and `ExportButton.test.tsx`.
- Wiring the button into `App.tsx` is a later task's job (T3).

## Steps

1. **Collect the result**
   ```bash
   mkdir -p .orchestra/2026-11-23-export/tasks
   cp .worktrees/2026-11-23-export/T2/RESULT.md .orchestra/2026-11-23-export/tasks/T2.result.md
   ```
   Then read `T2.task.md` and `T2.result.md`. I assume RESULT.md says "7 passed" and lists no deviations.

2. **Run the mechanical checks**
   ```bash
   bash <skill-dir>/scripts/review-check.sh 2026-11-23-export T2
   ```
   Assumed output: `scope=1-out (web/src/App.tsx)`, `task=pass 7 passed, 1 skipped`, `test_cmd=pass`, `lint_cmd=pass`.
   - `App.tsx` isn't a build artifact, so the "delete it and rerun" exception doesn't apply.
   - RESULT.md claimed a clean pass. It left out the skip and the extra file, and that goes in the notes.

3. **Read the diff**
   ```bash
   git -C .worktrees/2026-11-23-export/T2 diff
   git -C .worktrees/2026-11-23-export/T2 diff -- web/src/App.tsx
   git -C .worktrees/2026-11-23-export/T2 diff -U0 | grep -nE '\.(skip|todo)\(|xit\(|xdescribe\('
   ```
   Assumed findings:
   - `App.tsx` imports and mounts `<ExportButton>`. That belongs to T3.
   - Line 41 of `ExportButton.test.tsx` is `it.skip('disables the button while exporting')`. That test covers a "Done when" item.
   - The disable logic doesn't work yet, so the test was skipped instead of the code being fixed. Skipping a test to get a pass is an explicit reject reason.

   If the `App.tsx` change had been needed for T2's own "Done when", the spec would be at fault. I'd report that to the orchestrator instead of blaming the implementer. Here it isn't needed.

4. **Decide: reject.** I don't fix or revert anything myself. In `.orchestra/2026-11-23-export/tasks/T2.task.md`, I change `attempt: 1` to `attempt: 2` and append:
   ```markdown
   ## Notes from review
   - web/src/App.tsx:3,58 — file is outside "may change" (mounting ExportButton is T3's job) — revert all changes to App.tsx (`git checkout -- web/src/App.tsx`).
   - web/src/components/ExportButton.test.tsx:41 — `it.skip('disables the button while exporting')` hides a "Done when" requirement — remove `.skip`, then make it pass in ExportButton.tsx by setting `disabled={isExporting}` and resetting it in `finally`. Never skip, delete or weaken tests.
   - RESULT.md — reported "7 passed" without the skipped test or the extra file — report skips and every changed file under Deviations.
   ```

5. **Log it** in `.orchestra/2026-11-23-export/board.md`:
   ```
   - 2026-11-23 T2 attempt 1 REJECTED: scope 1-out (web/src/App.tsx), task tests 7 passed / 1 skipped (ExportButton.test.tsx:41 it.skip); test_cmd+lint pass. 3 notes. → attempt 2
   ```
   I also set T2's status in the table to `rejected (1/3)`.

6. **Reply** to the orchestrator, which sends T2 back with `claude-dispatch --continue`:
   ```
   REJECTED T2 attempt=2 notes=3
   ```

Nothing is committed, merged or pushed. The worktree and branch stay in place for attempt 2.