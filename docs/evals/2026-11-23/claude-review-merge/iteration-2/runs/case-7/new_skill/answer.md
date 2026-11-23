**Assumptions**
- Task file is `.orchestra/2026-11-23-csv/tasks/T2.md`. It contains: goal "Add CSV export of job runs (`jobs export --csv`)", "may change/create" `src/jobs/export.py`, `src/jobs/cli.py` and `tests/test_export.py`, task test `pytest -q tests/test_export.py`, `attempt: 1`, and edge cases: empty list, commas/quotes/newlines in fields, header row always present.
- `.orchestra/config.json` has `base_branch: main`, `test_cmd: pytest -q`, `lint_cmd: ruff check .` and `max_rejections: 3`.
- `W=.worktrees/2026-11-23-csv/T2` is on branch `orchestra/2026-11-23-csv/T2`.
- The checks pass and the diff is clean (the accept path). The other outcomes are at the end.

**1. Collect**
```bash
cd /workspaces/jobs
W=.worktrees/2026-11-23-csv/T2
cp $W/RESULT.md .orchestra/2026-11-23-csv/tasks/T2.result.md
cat .orchestra/2026-11-23-csv/tasks/T2.md .orchestra/2026-11-23-csv/tasks/T2.result.md
```

**2. Check** (I won't rerun tests by hand)
```bash
bash <skill-dir>/scripts/review-check.sh 2026-11-23-csv T2
```
Assumed last line: `CHECK T2 scope=ok result=yes task=pass suite=pass lint=pass`.
- If it reported `scope=N-out` and the extra files were only `__pycache__/`, I'd delete them and rerun the script.
- If it reported `task=none`, the spec is broken and I'd report that.

**3. Read the diff**
```bash
git -C $W diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'
git -C $W ls-files -o --exclude-standard   # ignore RESULT.md
```
What I check:
- **Edge cases:** it uses `csv.writer` rather than joining strings by hand, so quoting is handled. An empty list still writes the header row.
- **Tests (TDD):** each edge case has a test that asserts exact output. No tests are skipped or weakened.
- **YAGNI:** no unused `--delimiter` option.
- **DRY:** it reuses the existing job-listing query instead of copying it.
- **No new dependencies.**
- **Security:** this is input parsing and file writing, so I check that the `--out` path only goes where the CLI already writes files and that nothing user-supplied reaches a shell. If the `security-review` skill is installed, I run it on the diff.

Assumed result: correct, with one nit: `export.py:12` has a vague variable name `r`.

**4. Decide: accept**
```bash
rm $W/RESULT.md
git -C $W add -A
git -C $W commit -m "feat: add CSV export of job runs (orchestra 2026-11-23-csv/T2)"   # plus repo trailers
git checkout main
git merge --no-ff orchestra/2026-11-23-csv/T2
pytest -q 2>&1 | tail -1          # assumed: 142 passed
git worktree remove $W
git branch -d orchestra/2026-11-23-csv/T2
```
I don't push.

**5. Log** (append to `.orchestra/2026-11-23-csv/board.md`)
```
- T2 MERGED a1b2c3d — CHECK scope=ok task=pass suite=pass lint=pass; main after merge: 142 passed. Done-when met. Nit: export.py:12 rename `r` → `row`.
```

**6. Reply**
```
MERGED T2 a1b2c3d tests=142 passed
```

---
**Other outcomes:**
- **Reject:** if a check fails or the diff has a real problem, I add `## Notes from review` to `T2.md`. Each note is one line in the form `file:line — problem — fix`, for example `src/jobs/export.py:20 — fields joined with "," so embedded commas break rows — use csv.writer`. I then set `attempt: 2`, log it, and reply `REJECTED T2 attempt=2 notes=<n>`.
- **Takeover:** this happens on the 3rd rejection or for a problem beyond the implementer. I'd then read `references/takeover.md` to choose the model, spawn it in `W`, review its work with steps 2–4, mark the task `taken-over`, and reply `TAKEOVER T2 <model> <reason>`.