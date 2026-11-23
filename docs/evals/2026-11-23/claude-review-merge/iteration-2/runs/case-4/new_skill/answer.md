Your merge isn't finished until the T4 review is done, `test_cmd` passes on `main`, the worktree and branch are removed, and `board.md` records the result. You merged it yourself, so here is what I'd run to close it out (`<run>` = the active run in `.orchestra/`, `W=.worktrees/<run>/T4`).

**1. Confirm the merge and check whether T4 was reviewed**
```bash
git log --oneline -3 main
git branch --merged main | grep T4
grep -n 'T4' .orchestra/<run>/board.md
```
I'm assuming `board.md` has no review verdict for T4, meaning you merged straight from the implementer's result.

**2. Review it now, since RESULT.md alone isn't evidence**
```bash
cp $W/RESULT.md .orchestra/<run>/tasks/T4.result.md   # if still there
bash plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh <run> T4
git -C $W diff main~1..main -- . ':!*.lock' ':!*-lock.*' ':!go.sum'
```
I'd read the diff against the task spec, checking:
- that it meets the "Done when" criteria and covers the edge cases
- TDD: each behaviour change has a test that would fail without it, and no tests were weakened or skipped
- YAGNI and DRY
- files outside the task's allowed list
- secrets

**3. Clean up anything that came in with the merge**
```bash
git ls-files | grep -E '(^|/)RESULT\.md$'
```
If RESULT.md was committed to `main`, I'd remove it with `git rm RESULT.md` and commit `chore: drop RESULT.md (orchestra <run>/T4)`.

**4. Run the tests on `main`**
I'd run `test_cmd` from `.orchestra/config.json`. I'm assuming it's `pytest -q`, which gives one summary line.

**5. Remove the worktree and branch**
```bash
git worktree remove $W
git branch -d orchestra/<run>/T4
```

**6. Log it in `.orchestra/<run>/board.md`**
```
- T4 MERGED (by user) <commit> — post-merge review: scope ok, task=pass, suite=142 passed, lint ok; worktree/branch removed
```

**Reply:**
`MERGED T4 <commit> tests=142 passed`

If the review finds a real problem, I won't rewrite the code on `main`. I'll add `file:line — problem — fix` notes to a follow-up task and tell you before we move on. I won't push; you push when you're ready.