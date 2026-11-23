Verdict: **reject T2.** It changed a file the task didn't allow, and it skipped a test. Passing tests don't cancel either problem.

Assumptions: the run is `r1` and `W=.worktrees/r1/T2`. T2 is on attempt 1 of 3, so a takeover isn't due. The task allows `web/src/components/TodoFilter.tsx` and `web/src/components/TodoFilter.test.tsx`.

**1. Collect**
```bash
cp .worktrees/r1/T2/RESULT.md .orchestra/r1/tasks/T2.result.md
```
I'd read `T2.result.md` and `.orchestra/r1/tasks/T2.md`.

**2. Check** (the script runs the tests; I don't rerun them by hand)
```bash
bash plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh r1 T2
```
Assumed last line:
`CHECK T2 scope=1-out result=yes task=pass suite=pass lint=pass`

`App.tsx` is source code, not a build artifact. That makes `scope=1-out` a rejection, so I wouldn't delete anything and rerun.

**3. Read the diff**
```bash
git -C .worktrees/r1/T2 diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'
git -C .worktrees/r1/T2 ls-files -o --exclude-standard
```
Assumed findings:
- `web/src/App.tsx:14-22`: wires `<TodoFilter>` into the app. That's outside T2's scope; the wiring belongs to another task or a follow-up.
- `web/src/components/TodoFilter.test.tsx:38`: `it.skip("shows empty state when no todos match", …)`. This is the spec's edge case, so it may be untested or broken. Suites are green only because the test is skipped.

**4. Decide: reject.** I'd append this to `.orchestra/r1/tasks/T2.md` and bump the attempt:
```markdown
## Notes from review
- web/src/App.tsx:14-22 — file not in "may change" list; T2 must not wire the component into App — revert all App.tsx changes (`git checkout -- web/src/App.tsx`).
- web/src/components/TodoFilter.test.tsx:38 — `it.skip` disables the spec's empty-state test; skipped tests are not allowed — remove `.skip`, make TodoFilter render the empty state when no todos match, and keep the test's assertions unchanged.
```
Frontmatter: `attempt: 1` → `attempt: 2`.

The orchestrator then sends T2 back with `claude-dispatch --continue`. I wouldn't fix the code or push anything.

**5. Log** to `.orchestra/r1/board.md`:
```
- T2 REJECTED attempt=1→2 — tests task=pass suite=pass lint=pass (1 skipped) — scope=1-out (web/src/App.tsx) + skipped edge-case test TodoFilter.test.tsx:38
```

**6. Reply**
```
REJECTED T2 attempt=2 notes=2
```