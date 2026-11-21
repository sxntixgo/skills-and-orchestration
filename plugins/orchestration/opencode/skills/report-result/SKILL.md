---
name: report-result
description: Writes RESULT.md at the worktree root in the orchestration contract format (status, changed files, exact test command and output tail, deviations, questions). Use when you are the implementer and have finished or are blocked on a task.md.
---

# Report the result

Write `RESULT.md` at the root of the worktree. Claude will check every claim against the diff
and by rerunning the tests, so report exactly what happened.

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

Rules:
- `status: done` only if the task's test command passed in your last run.
- Paste real output; never summarize it as "all tests pass".
- Blocked: say what you tried and the exact error.
- Don't commit RESULT.md (don't commit anything).
