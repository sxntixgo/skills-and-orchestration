**Accept.** A variable name is a nit, and the skill says to accept nits and record them. I won't rename it myself. First I'd still run the checks, because your read and RESULT.md aren't proof the tests pass.

**Assumptions:** the run is `r1`, `W=.worktrees/r1/T3`, `base_branch=main`, `.orchestra/config.json` has `test_cmd`/`lint_cmd`, and you'll name the variable (I'll call it `<old>` → `<new>` below).

1. **Collect:**
   `cp .worktrees/r1/T3/RESULT.md .orchestra/r1/tasks/T3.result.md`, then read it along with `.orchestra/r1/tasks/T3.md`.
2. **Check:**
   `bash plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh r1 T3`
   I'm assuming it returns `CHECK T3 scope=ok result=yes task=pass suite=pass lint=pass`. If it shows any `fail` or `N-out`, the verdict becomes reject (or I report a spec bug if `task=none`), whatever you think of the code.
3. **Diff:**
   `git -C .worktrees/r1/T3 diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'` and `git -C .worktrees/r1/T3 ls-files -o --exclude-standard`
   I'd skim it for TDD, YAGNI, DRY and security problems. I'm assuming I find nothing beyond the naming.
4. **Accept:**
   - `rm .worktrees/r1/T3/RESULT.md`
   - `git -C .worktrees/r1/T3 add -A && git -C .worktrees/r1/T3 commit -m "feat: <T3 goal> (orchestra r1/T3)"` plus the repo's trailers
   - `git checkout main && git merge --no-ff orchestra/r1/T3`
   - run `test_cmd` on `main` and keep the one-line result, e.g. `42 passed`
   - `git worktree remove .worktrees/r1/T3 && git branch -d orchestra/r1/T3`
   - Append to `.orchestra/r1/tasks/T3.md`: `## Review nits` → `<file>:<line> — variable \`<old>\` unclear — rename to \`<new>\` (follow-up, not blocking)`
5. **Log** in `.orchestra/r1/board.md`:
   `T3 — MERGED <sha> — task pass, suite 42 passed, lint clean — nit: rename <old>→<new> (not done)`
   Nothing gets pushed.
6. **Reply:**

`MERGED T3 <sha> tests=42 passed (nit noted: rename <old>→<new>)`