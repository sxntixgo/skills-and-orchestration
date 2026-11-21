---
name: opencode-develop
description: Steps for implementing one development task from an attached task.md inside a git worktree — read, test first, change only the listed files, run the task's test command until it passes — and the RESULT.md report. Use when you are the implementer and have been given a task.md.
---

# Develop a task

## Steps
1. **Read the whole task.md.** Note: files you may change/create, the exact test command in
   "Done when", what is out of scope, and any "Notes from review" (attempt ≥ 2: those come first).
2. **Read before writing.** Open every file you will change and the pattern file named in
   Context. Copy its style: naming, error handling, test layout.
3. **Run the test command once** before changing anything, to see where you start.
   If it fails for a reason unrelated to the task (missing tool, broken setup), stop: report
   `blocked` with the error.
4. **TDD, one behaviour at a time.** Write the test for the next behaviour, run it, see it fail
   for the right reason (not an import or syntax error). Then step 5. Repeat per behaviour.
   No test-after: every behaviour change needs a test that would fail without it.
5. **Simplest code that passes (YAGNI).** Only the listed files. No extra parameters, options,
   config, abstractions, or "just in case" branches the task doesn't ask for.
   **DRY:** before writing a helper, search the repo for one that exists and reuse it; don't
   copy-paste logic. But don't merge two things that only look alike.
6. **Run the test command.** Fix and rerun until it passes. If after 3 honest attempts it still
   fails, stop and report `blocked` with the failing output.
7. **Self-check the diff** (`git diff`, `git status`): only listed files changed, no debug prints,
   no commented-out code, no unrelated formatting, nothing unused (YAGNI), no duplicated logic (DRY).
   Changed a file that isn't listed? Revert it, and say so under Deviations. One exception: an
   empty support file the test command needs to find the tests at all (e.g. `tests/__init__.py`)
   — keep it, and list it under Deviations with why.
8. **Write RESULT.md** (below). Always, also when blocked.

## RESULT.md (at the worktree root)
Claude checks every claim against the diff and by rerunning the tests: report exactly what happened.

```markdown
---
id: <id from task.md>
attempt: <attempt from task.md>
status: done            # or: blocked
---
## Changed
- path/file.py: what changed and why (one line per file)

## Tests
command: `<the exact command you ran last>`
outcome: <N passed, M failed>   # copy the numbers from the output
```text
<last ~20 lines of that command's output, verbatim>
```

## Deviations
- none            # or: what you did differently from the task, and why

## Questions
- none            # or: what blocked you or needs a decision; things you noticed but left alone
```

- `status: done` only if the task's test command passed in your last run.
- Paste real output; never summarize it as "all tests pass".
- Blocked: say what you tried and the exact error.

## Don't
- Edit files outside the list, add dependencies the task doesn't name, or "fix" other things
  you notice (mention them under Questions instead).
- Change a test so it passes instead of fixing the code.
- Commit (not even RESULT.md), push, or switch branches. Use the network only when a task step
  needs it (e.g. `npm install`).
