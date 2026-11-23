**T2 is rejected and sent back as attempt 2.** It changed `web/src/App.tsx`, which the task didn't allow, and it skipped a test to get a green run. Under the skill, a skipped test is a rejection on its own. The out-of-scope file could only have been reverted and noted if it were harmless and everything else were clean, which it isn't.

**Assumptions** (nothing here exists on disk):
- Run: `2026-11-21-csv-export`. Base branch: `main`. Attempt 1 of 3.
- T2 may change `web/src/components/ExportButton.tsx` and may create `web/src/components/ExportButton.test.tsx`.
- Done when: `npm --prefix web test -- ExportButton` passes.
- Mounting the button in `App.tsx` is out of scope because T3 does it.

### What I'd do, in order

**1. Collect**
```bash
cd /workspaces/app
cp .worktrees/2026-11-21-csv-export/T2/RESULT.md .orchestra/2026-11-21-csv-export/tasks/T2.result.md
cat .orchestra/2026-11-21-csv-export/tasks/T2.task.md .orchestra/2026-11-21-csv-export/tasks/T2.result.md
```

**2. Scope check**
```bash
W=.worktrees/2026-11-21-csv-export/T2
git -C $W status --porcelain
git -C $W diff
git -C $W diff -- web/src/App.tsx
```
Assumed result:
- `M web/src/components/ExportButton.tsx` (allowed)
- `?? web/src/components/ExportButton.test.tsx` (allowed)
- `M web/src/App.tsx`: imports `ExportButton` and renders it in the toolbar. This isn't allowed and is T3's job.
- `?? RESULT.md`

**3. Run the tests myself**
```bash
cd $W/web
npm test -- ExportButton        # task's command
npm test                        # full suite
npm run lint && npx tsc --noEmit
grep -rnE '\b(it|test|describe)\.(skip|todo)\b|\bx(it|describe)\(' src/components/ExportButton.test.tsx
```
Assumed result: 6 passed, 1 skipped, 0 failed. Full suite, lint and typecheck are green. The skipped test is `it.skip('exports an empty table as header-only CSV', …)` at `ExportButton.test.tsx:41`, which covers an edge case named in the spec's "Done when". RESULT.md says "7 passed" and lists no deviations, so it doesn't match what I saw.

**4. Read the diff**
I'd also check whether the code handles empty rows at all. Assumed: `buildCsv` in `ExportButton.tsx:18` returns `''` for an empty table instead of the header line. That's probably why the test was skipped.

**5. Decide: reject**

I'd add this to `.orchestra/2026-11-21-csv-export/tasks/T2.task.md`, change `attempt: 1` to `attempt: 2`, and leave the worktree as it is:
```markdown
## Notes from review
- web/src/App.tsx:3,57 — out of scope: imports and mounts ExportButton (T3 does this) — revert the file: `git checkout -- web/src/App.tsx`.
- web/src/components/ExportButton.test.tsx:41 — `it.skip` on "exports an empty table as header-only CSV"; skipping a test to pass isn't allowed — change it back to `it(...)` and make it pass.
- web/src/components/ExportButton.tsx:18 — `buildCsv([])` returns '' — when rows is empty, still return the header line joined with ',' plus '\n', as the spec's Done when says.
- RESULT.md — reported 7 passed; the real result was 6 passed, 1 skipped. Report skips, and list any deviation under "Deviations".
```
Then send it back:
```bash
claude-dispatch --continue 2026-11-21-csv-export T2
```

**6. Log** in `.orchestra/2026-11-21-csv-export/board.md`:
- Task table, T2 row: `rejected (attempt 1/3) → re-dispatched`
- Log line: `2026-11-23 T2 rejected — tests 6 passed / 1 skipped / 0 failed (RESULT.md claimed 7 passed); full suite + lint + tsc green; reasons: web/src/App.tsx out of scope, skipped empty-table test, buildCsv([]) wrong. Sent back as attempt 2.`

### Reply to you
> T2 rejected and sent back (attempt 2 of 3). Rerun: 6 passed, 1 **skipped**, 0 failed. RESULT.md claimed 7 passed. The skipped test (`ExportButton.test.tsx:41`, empty table → header-only CSV) hides a real bug: `buildCsv([])` returns an empty string. `web/src/App.tsx` was changed to mount the button, which is outside T2's files and is T3's job. The notes tell opencode to revert `App.tsx`, un-skip the test and fix `buildCsv`. Nothing was merged; the logged entry is in `board.md`.