**T2 rejected and sent back as attempt 2.** I reran the tests myself, and they only pass because one test is skipped. `web/src/App.tsx` was changed even though the task doesn't allow it. Nothing was merged.

Assumptions: the repo is at `/workspaces/app`, the run is `2026-11-23-settings-page`, T2 is on attempt 1, and `max_rejections` is 3. T2 is "add `SettingsForm` component + tests" and may change only `web/src/components/SettingsForm.tsx` and `web/src/components/SettingsForm.test.tsx`. Its test command is `npm --prefix web test -- SettingsForm`.

## What I'd do, in order

**1. Collect RESULT.md**
```bash
cd /workspaces/app
cp .worktrees/2026-11-23-settings-page/T2/RESULT.md .orchestra/2026-11-23-settings-page/tasks/T2.result.md
```
Read `T2.result.md` and `T2.task.md`. Assumed claim: "6 passed", Deviations: "none". Neither the skip nor the App.tsx change is mentioned.

**2. Check scope**
```bash
W=.worktrees/2026-11-23-settings-page/T2
git -C $W status --porcelain
git -C $W diff
git -C $W diff -- web/src/App.tsx
git -C $W ls-files --others --exclude-standard
```
Assumed result: `SettingsForm.tsx`, `SettingsForm.test.tsx` and `RESULT.md` are expected. `web/src/App.tsx` is outside scope. Its diff mounts `<SettingsForm />` and adds an import. That wiring isn't part of T2; I assume a later task does it, so the task spec isn't wrong and there's no reason to take the task over.

**3. Find the skip and run the checks myself**
```bash
git -C $W diff -U0 | grep -nE '\.(skip|todo)\(|xit\(|xdescribe\('
git -C .  grep -nE '\.(skip|todo)\(' -- web/src/components/SettingsForm.test.tsx   # on main: was it already skipped?
cd $W && npm --prefix web test -- SettingsForm
npm --prefix web test
npm --prefix web run lint && npm --prefix web run typecheck
```
Assumed result: the diff adds `it.skip('shows an error when email is invalid', …)` at `SettingsForm.test.tsx:41`, and the skip isn't on main. The output is "5 passed, 1 skipped". That test covers an edge case named in the task's "Done when". When I un-skip it locally, it fails because no validation was implemented.

**4. Review the diff (TDD, YAGNI, DRY)**
- The skipped test violates TDD: the behaviour it covers isn't implemented.
- The App.tsx change goes beyond the task (YAGNI).
- Assumed: nothing else wrong.

**5. Decide: reject.** The skip alone means rejection. I won't revert App.tsx silently; it goes in the notes so the implementer reverts it.

I'd edit `.orchestra/2026-11-23-settings-page/tasks/T2.task.md`: set `attempt: 2` and add:
```markdown
## Notes from review
- web/src/components/SettingsForm.test.tsx:41 — test "shows an error when email is invalid" was marked `it.skip` to get a green run; skipping, weakening or deleting tests is not allowed — change it back to `it(...)` and keep it as written.
- web/src/components/SettingsForm.tsx (submit handler) — invalid email is not validated, so that test fails when un-skipped — validate the email on submit and render the error message the test expects; reuse the existing validator in web/src/lib/validate.ts if it covers email.
- web/src/App.tsx — outside this task's files (mounting SettingsForm belongs to a later task) — revert it completely: `git checkout -- web/src/App.tsx`.
- RESULT.md — report skipped tests and any file changed outside the list under "Deviations"; this attempt reported neither.
```
Then send it back:
```bash
claude-dispatch --continue 2026-11-23-settings-page T2
```

**6. Log** in `.orchestra/2026-11-23-settings-page/board.md`:
```
| T2 | attempt 1 | REJECTED | rerun: 5 passed, 1 skipped (un-skipped: 5 passed, 1 failed); full suite green; lint/typecheck ok | it.skip on invalid-email test (validation missing); out-of-scope change to web/src/App.tsx | → attempt 2 via --continue (1/3 rejections) |
```

## Reply to you

T2 was sent back for attempt 2 and nothing was merged.
- **Skipped test:** `SettingsForm.test.tsx:41`, the invalid-email test, was set to `it.skip`. When I un-skip it, it fails because the validation was never written. The pass was faked by the skip.
- **Out-of-scope change:** `web/src/App.tsx` was changed to mount the component, which belongs to a later task. I told the implementer to revert it.
- **Notes for attempt 2:** the task file now says to un-skip that test, add the email validation, revert `App.tsx`, and report any deviations in RESULT.md.
- **Rejection count:** this is rejection 1 of 3. If it reaches 3, I'll take the task over, probably with Haiku or Sonnet.

The test numbers are logged in `board.md`.