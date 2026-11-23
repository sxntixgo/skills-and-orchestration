T7 has been rejected 3 times, which is the `max_rejections` limit, so it moves to a takeover. The spec and review notes already say exactly what to change, and the fix is in one function, so I'd hand it to **haiku**. That's the lowest model that fits in `references/takeover.md`.

**Assumptions:** the run is `2026-11-21-scheduling` and the repo is `/workspaces/app`. T7 may change `src/app/schedule.py` and `tests/test_schedule.py`. Its test command is `uv run pytest tests/test_schedule.py -q`. `config.json` uses the defaults (`max_rejections: 3`, `base_branch: main`), and `test_cmd`/`lint_cmd` are already set. The third rejection's notes are already in `tasks/T7.task.md`, and `attempt` is now 4.

### 1. Log the takeover
Append to `.orchestra/2026-11-21-scheduling/board.md`:
```
- 2026-11-23 T7 REJECTED attempt=3 (timezone edge case in next_run_at still wrong) → TAKEOVER haiku: max_rejections reached; fix fully specified in spec + notes, 1 function, ≤2 files
```
Set T7's status in the task table to `taken-over (haiku)`.

### 2. Start the haiku subagent
Agent tool, `model: "haiku"`, with this prompt:
```
Work ONLY in /workspaces/app/.worktrees/2026-11-21-scheduling/T7. Don't commit, push, or switch branches. Touch only the files the task allows.

Task (full text of tasks/T7.task.md follows, including all "Notes from review"):
<paste T7.task.md verbatim>

What went wrong before: three attempts by a local model kept getting the timezone edge case in
next_run_at wrong (see the review notes: e.g. a DST transition or a non-UTC tzinfo being turned into naive
or UTC time before the comparison). The notes say exactly what to change. Do that and nothing else.

Rules: TDD. First add or keep a test for the edge case the notes describe and confirm it fails. Then make the
smallest change that makes it pass. YAGNI: no new params, options or helpers. DRY: reuse the existing tz
helpers in the module. Match the repo's style. Don't weaken, skip or delete existing tests.

Run `uv run pytest tests/test_schedule.py -q` until it passes.
Reply with: files changed, the test command, the last ~20 lines of its output, and anything you could not do.
```

### 3. Review haiku's work
Same steps 2–4 as any implementer result:
- `bash <skill-dir>/scripts/review-check.sh 2026-11-21-scheduling T7` checks scope, the task's tests, `test_cmd` and `lint_cmd`. I'd compare its results with what haiku said.
- I'd read `git -C .worktrees/2026-11-21-scheduling/T7 diff`. The edge-case test has to fail without the fix and contain real assertions. The change must stay inside that one function, existing tz helpers must be reused, and no tests may be weakened.

### 4. Decide
- **Accept:**
  1. Remove `RESULT.md` if it exists.
  2. Commit in the worktree with `fix: <goal> (orchestra 2026-11-21-scheduling/T7)` plus the repo's trailers.
  3. Merge into `main` and run `test_cmd` there (one summary line).
  4. Run `git worktree remove .worktrees/2026-11-21-scheduling/T7` and delete branch `orchestra/2026-11-21-scheduling/T7`.
  5. Log in `board.md`: `T7 MERGED <commit> taken-over model=haiku tests=<summary>`.
- **Reject:** write the new notes into T7, log it, and rerun the takeover on **sonnet**. A model never gets a second try. If sonnet's result is also rejected, go to opus, and if opus fails, stop and report to you.
- Nothing gets pushed; you do that.

### Reply line (now)
```
TAKEOVER T7 haiku max_rejections reached; spec+notes fully specify the timezone fix in one function
```