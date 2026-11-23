T4 is out of opencode attempts. It doesn't get a fourth dispatch. `claude-review-merge` now takes it over by having a Claude subagent implement it in the same worktree. I review that work exactly like opencode's and merge it as `taken-over`.

**Assumptions** (nothing exists on disk):
- Run `2026-11-21-csv-export`, `base_branch` is `main`, worktree `/workspaces/app/.worktrees/2026-11-21-csv-export/T4`.
- T4 is "CSV export endpoint + tests". It may change `app/export.py`, `app/routes.py` and `tests/test_export.py`. Its test command is `uv run pytest tests/test_export.py -q`.
- Across the three attempts, opencode got close each time but kept missing edge cases: empty result set, commas and quotes in fields, and a missing `Content-Disposition` header.
- T5 depends on T4. T6 is independent and has no files in common with T4.

### 1. Record rejection #3
- Add the third review's notes to `.orchestra/2026-11-21-csv-export/tasks/T4.task.md` under `## Notes from review`, one per line in the form `file:line — problem — fix`. Leave `attempt` at 3, since there's no send-back.
- Update `board.md`: set T4's status to `review` and add this Log line:
  `2026-11-23 14:05 T4 rejected (3/3): 11 passed, 2 failed (quoted fields, empty export) → takeover`

### 2. Pick the model (`references/takeover.md`)
I'd use **`sonnet`**. This is normal feature work across three files with real logic and tests, and opencode came close but kept missing edge cases.
- `haiku` doesn't fit. The fix is more than one listed assertion and touches more than 2 files.
- `opus` isn't justified. The spec has no design flaw, and the change isn't cross-cutting or security-related.

### 3. Spawn the subagent
`Agent(model: "sonnet")`, prompt:

```
Implement one task in an existing git worktree. Work ONLY in
/workspaces/app/.worktrees/2026-11-21-csv-export/T4 — don't commit, push, or switch branches,
and don't touch .orchestra/, .git/ or other worktrees.

Task (full text of T4.task.md, including all "Notes from review" from attempts 1–3):
<pasted verbatim>

What the previous 3 attempts (a local model) got wrong:
- Fields with commas/quotes were joined by hand instead of using csv.writer → broken rows.
- Empty result set returned 500 instead of a header-only CSV.
- Response lacked Content-Disposition: attachment; filename="export.csv".
The current worktree has that last attempt's code; keep what's correct, fix the rest.

Rules: TDD (write the failing test first, then the simplest code that passes), YAGNI (nothing
beyond the task: no extra params/options), DRY (reuse existing helpers, e.g. app/db.py query
helpers), follow the repo's existing style. Change only the files the task lists.

Run `uv run pytest tests/test_export.py -q` until it passes. Reply with: files changed (one
line each), the test command, the last ~20 lines of its output, anything you could not do.
```

While it runs, opencode can keep working on T6 in the other `concurrency` slot, since T6 has no files in common with T4. T5 waits.

### 4. Review its work (`claude-review-merge` steps 2–5)
I don't take the subagent's reply on trust.

```bash
cd /workspaces/app/.worktrees/2026-11-21-csv-export/T4
git status --porcelain && git diff          # only the 3 allowed files; no RESULT.md, no artifacts
uv run pytest tests/test_export.py -q       # task command
uv run pytest -q && uv run ruff check .     # full suite + lint
```

Then I read the diff:
- Every edge case from the notes has a test that would fail without the fix.
- No tests were weakened or skipped.
- There's no extra code or copy-pasted logic, and no new dependencies.

I'd also run `security-review`, because the change touches file output and user-controlled field values.

### 5a. If it passes, accept and merge
```bash
rm -f RESULT.md
git add -A && git commit -m "feat: CSV export endpoint (orchestra 2026-11-21-csv-export/T4)"
cd /workspaces/app && git checkout main && git merge --no-ff orchestra/2026-11-21-csv-export/T4
uv run pytest -q                            # green on main again
git worktree remove .worktrees/2026-11-21-csv-export/T4
git branch -d orchestra/2026-11-21-csv-export/T4
```

`board.md` gets T4 → `taken-over (sonnet)` and this Log line:
`2026-11-23 14:31 T4 taken over by sonnet, accepted: 14 passed; main 87 passed → merged`

T5 is then ready, so it goes through `claude-write-task` → `claude-dispatch` to opencode as normal.

### 5b. If it fails, escalate one model
- If I reject sonnet's work, the same task goes to **`opus`** with my new notes added. A model never gets two attempts.
- If opus is rejected too, I stop the loop and bring it to you with the test output and notes. At that point the spec itself is probably wrong.

**Reply to you:**
> T4 hit 3 rejections, so I've taken it over: a Sonnet subagent is finishing it in the same worktree (opencode kept missing CSV quoting, the empty export and the download header). I'll review and run the tests on it myself before merging, just as I did for opencode. If Sonnet's version also fails review, it goes to Opus. Meanwhile T6 keeps running on opencode, and T5 starts once T4 is merged. Nothing needed from you.