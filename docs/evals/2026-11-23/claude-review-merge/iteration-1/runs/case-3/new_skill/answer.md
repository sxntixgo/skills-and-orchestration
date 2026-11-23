**Accept.** A naming nit isn't worth a round-trip to opencode: we merge and record the nit. I still run the mechanical checks first, because your read of the code doesn't replace a test run. I won't rename the variable inside the accept commit, because the skill doesn't allow silent fixes on accept.

**Assumptions:** the run is `2026-11-21-csv-export`, `base_branch=main`, the repo merges with `--no-ff`, and T3's worktree is at `.worktrees/2026-11-21-csv-export/T3` with RESULT.md claiming all tests pass.

**Steps, in order:**

1. Collect RESULT.md and read it with the task file:
   ```bash
   cp .worktrees/2026-11-21-csv-export/T3/RESULT.md .orchestra/2026-11-21-csv-export/tasks/T3.result.md
   ```
2. Run the mechanical checks:
   ```bash
   bash <skill-dir>/scripts/review-check.sh 2026-11-21-csv-export T3
   ```
   - I expect `scope=clean task=pass test_cmd=pass lint_cmd=pass`, and I compare that with what RESULT.md claims.
   - If anything fails or a file is out of scope, the verdict changes to reject, and I tell you why.
3. Skim `git -C .worktrees/2026-11-21-csv-export/T3 diff` for TDD, YAGNI and DRY, and to confirm no tests were weakened. You've reviewed the logic already, so this is only a check for red flags.
4. Accept:
   ```bash
   cd .worktrees/2026-11-21-csv-export/T3 && rm RESULT.md
   git add -A && git commit -m "feat: <T3 goal> (orchestra 2026-11-21-csv-export/T3)"   # + repo trailers
   cd /workspaces/<repo> && git checkout main && git merge --no-ff orchestra/2026-11-21-csv-export/T3
   <test_cmd>                                   # one summary line
   git worktree remove .worktrees/2026-11-21-csv-export/T3
   git branch -d orchestra/2026-11-21-csv-export/T3
   ```
5. Log it in `board.md`:
   ```
   - 2026-11-23 T3 MERGED <sha> — task=pass, test_cmd=<N passed>, lint ok. Nit (user): rename `<old>` → `<new>`, not fixed; follow-up.
   ```
6. Reply line: `MERGED T3 <sha> tests=<N passed>`

**My reply to you:**

> If the checks come back green, T3 gets merged into `main` and the variable-name nit is recorded in `board.md`. Tell me which variable and what you'd call it, and I'll rename it in a separate commit on `main`, or you can rename it in your next change. Nothing gets pushed.