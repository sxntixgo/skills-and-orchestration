Assumptions: one active run, `auth-api`, found as the only directory under `.orchestra/`. T1 is "add `parse_token()` in `src/auth/token.py`". It may change `src/auth/token.py` and may create `tests/test_token.py`. The task's test command is `pytest tests/test_token.py`. `.orchestra/config.json` has `base_branch=main`, `test_cmd="pytest -q"` and `lint_cmd="ruff check ."`. `W=.worktrees/auth-api/T1`, on branch `orchestra/auth-api/T1`.

The "status: done, 12 passed" in RESULT.md is the implementer's claim, so I check it before merging.

**1. Collect**
```bash
cp .worktrees/auth-api/T1/RESULT.md .orchestra/auth-api/tasks/T1.result.md
```
Then read `T1.result.md` and `.orchestra/auth-api/tasks/T1.md` (goal, allowed files, "Done when", edge cases).

**2. Check**
```bash
bash plugins/orchestration/skills/claude-review-merge/scripts/review-check.sh auth-api T1
```
Assumed last line: `CHECK T1 scope=ok result=yes task=pass suite=pass lint=pass`. `task=pass` covers 12 tests and `suite=pass` covers 148. I don't rerun any tests by hand.

**3. Read the diff**
```bash
git -C .worktrees/auth-api/T1 diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'
git -C .worktrees/auth-api/T1 ls-files -o --exclude-standard   # → tests/test_token.py (+ RESULT.md, ignored)
```
I check:
- **Edge cases:** the spec's expired, malformed and empty-token cases are each handled and tested.
- **Tests:** each test would fail without the change. None are skipped, have no assertion, or just copy the current output.
- **Scope:** no unused params, no new deps, the existing `AuthError` is reused, no secrets.
- **Security:** this is input parsing, so I also check for injection, signature bypass and missing exception handling. I use the `security-review` skill if it's installed.

Assumed finding: clean, apart from one nit: `tok` in `token.py:41` should be named `token`.

**4. Accept**
```bash
rm .worktrees/auth-api/T1/RESULT.md
git -C .worktrees/auth-api/T1 add -A
git -C .worktrees/auth-api/T1 commit -m "feat: add parse_token for bearer tokens (orchestra auth-api/T1)"   # + repo trailers if CLAUDE.md defines any
git checkout main && git merge --no-ff orchestra/auth-api/T1
pytest -q 2>&1 | tail -1          # → 148 passed
git worktree remove .worktrees/auth-api/T1
git branch -d orchestra/auth-api/T1
```
No push.

**5. Log** (append to `.orchestra/auth-api/board.md`)
```
- T1 MERGED a1b2c3d — review-check: scope ok, task 12 passed, suite 148 passed on main, lint ok. Nit: token.py:41 rename `tok`→`token` (not blocking).
```

**6. Reply**

MERGED T1 a1b2c3d tests=12 task / 148 suite passed