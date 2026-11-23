T7 has now been rejected three times, which reaches `max_rejections` (3). So I won't send it back to opencode again. Per `references/takeover.md` I'm handing it to **haiku**: the fix is in one function, and the spec plus the review notes say exactly what to change.

**Assumed:** run `2026-11-20-reminders`; `.orchestra/config.json` uses the defaults (`max_rejections: 3`, `base_branch: main`). T7 may change `src/reminders/schedule.py` and `tests/test_schedule.py`. Its test command is `uv run pytest tests/test_schedule.py -q`, the full suite is `uv run pytest -q`, and lint is `uv run ruff check`. The attempt-3 notes are already in `## Notes from review`.

### 1. Gather context
```bash
cat .orchestra/config.json
cat .orchestra/2026-11-20-reminders/tasks/T7.task.md
cat .orchestra/2026-11-20-reminders/tasks/T7.result.md
git -C /workspaces/reminders/.worktrees/2026-11-20-reminders/T7 diff
```
I'm checking two things:
- The notes really are concrete, in the form `file:line — problem — fix`.
- The function is the only problem. If the notes showed a design flaw in the spec, I'd start at opus instead.

### 2. Log the takeover in `board.md` (before spawning)
```
- 2026-11-23 T7 attempt 3 rejected (3/3) → take over: haiku (one function, notes spell out the fix)
```

### 3. Spawn the subagent (Agent tool, `model: "haiku"`)
```
You are finishing task T7 in an existing git worktree:
/workspaces/reminders/.worktrees/2026-11-20-reminders/T7
Work only there. Do not commit, push, or switch branches. Do not touch .orchestra/ or .git/.

## Task (full T7.task.md)
<pasted verbatim: goal, Context, Files, Steps, Done when, Out of scope, all Notes from review>

## What the previous 3 attempts got wrong
The local model kept mishandling the timezone edge case in <function> in src/reminders/schedule.py.
Attempt 1: <one line>. Attempt 2: <one line>. Attempt 3: <one line>.
The review notes above say exactly what to change. Follow them literally.

## Rules
- TDD: first add or adjust a test in tests/test_schedule.py that fails because of the edge case.
  Run it and confirm it fails. Then make the simplest change in <function> that makes it pass.
- Change only src/reminders/schedule.py and tests/test_schedule.py.
- YAGNI: no new params, options or helpers. DRY: reuse the repo's existing tz helpers.
- Never weaken, skip or delete an existing test.
- Remove the stale RESULT.md if your change makes it wrong. Don't write a new one.

Run `uv run pytest tests/test_schedule.py -q` until it passes. Reply with: files changed,
the test command, the last ~20 lines of its output, and anything you could not do.
```

### 4. Review haiku's work exactly as I would opencode's (steps 2–5)
```bash
cd /workspaces/reminders/.worktrees/2026-11-20-reminders/T7
git status --porcelain && git diff     # only the 2 allowed files; delete __pycache__ etc.
uv run pytest tests/test_schedule.py -q
uv run pytest -q
uv run ruff check
```
- **Read the diff:** the edge case from the spec and the notes is handled, a test would fail without the fix, no tests were weakened, nothing extra was added.
- **If rejected:** move up one model to sonnet, with the same prompt plus haiku's failure. If sonnet fails too, go to opus. If opus fails, stop and report to you. A model never gets two attempts.

### 5. If accepted
```bash
rm -f RESULT.md
git add src/reminders/schedule.py tests/test_schedule.py
git commit -m "fix: handle <tz edge case> in <function> (orchestra 2026-11-20-reminders/T7)"   # + repo trailers
cd /workspaces/reminders && git switch main
git merge --no-ff orchestra/2026-11-20-reminders/T7    # or ff, per repo convention
uv run pytest -q
git worktree remove .worktrees/2026-11-20-reminders/T7
git branch -d orchestra/2026-11-20-reminders/T7
```
I'll also add `taken-over: haiku` to the T7 frontmatter.

### 6. Log in `board.md`
```
| T7 | merged (taken-over: haiku) | attempts: 3 opencode + 1 haiku |
- 2026-11-23 T7 accepted after takeover by haiku: test_schedule 14 passed; full suite 212 passed; ruff clean; merged --no-ff into main, main suite green, worktree + branch removed
```

### Reply to you
> T7 hit the 3-rejection limit, so I handed it to **haiku**: one function, and the review notes spell out the fix. Haiku wrote a failing test for the edge case first, then fixed `<function>`. I reviewed it like any opencode result: the scope is clean, `test_schedule` passes 14/14, the full suite passes 212/212, and ruff is clean. It's merged into `main` and `main` is still green. The worktree and branch are removed, and `board.md` marks it as taken over by haiku. Nothing has been pushed.

If haiku's attempt is rejected, the reply instead says it moved up to sonnet, and why.