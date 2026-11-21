# Orchestration contract (v1)

Shared by the Claude-side skills (`orchestrate`, `write-task-spec`, `dispatch-opencode`,
`review-and-merge`) and the opencode side (`implementer` agent, `implement-task`, `report-result`).
Change it only with a version bump here and in every file that cites it.

## Files (all inside the target repo, never committed)
```
.orchestra/
  config.json                 settings for this repo (below)
  <run>/                      one run = one feature/plan, e.g. 2026-11-21-csv-export
    board.md                  the run's state: task table + log (orchestrate owns it)
    tasks/<id>.task.md        what to build (write-task-spec)
    tasks/<id>.result.md      what was built (copied from the worktree by review-and-merge)
    logs/<id>.<n>.jsonl       opencode's event log, one per attempt (dispatch-opencode)
.worktrees/<run>/<id>/        one git worktree per dispatched task, branch orchestra/<run>/<id>
```
`.orchestra/` and `.worktrees/` go in `.git/info/exclude` (not `.gitignore`: nothing to commit).

## config.json
```json
{ "implementer": "opencode", "model": "atlas/qwen3.8-flash-next", "concurrency": 1,
  "task_timeout_min": 30, "max_sendbacks": 2, "base_branch": "main" }
```
`concurrency` = how many opencode tasks may run at once (atlas serves one request at a time
until tested otherwise). Missing file = these defaults.

## <id>.task.md
```markdown
---
id: T3                 # unique in the run; T<n>
run: 2026-11-21-csv-export
depends_on: [T1]       # ids that must be merged first ([] if none)
attempt: 1             # bumped on each send-back
---
# <one-line goal>

## Context
2–6 lines: why, where it fits, the existing pattern to copy (file:line).

## Files
- may change: path/a.py, path/test_a.py
- may create: path/b.py
- must NOT touch: everything else (and never .orchestra/, .git/)

## Steps
1. … (small, ordered; test-first when tests are listed)

## Done when
- `<exact test command>` passes (e.g. `uv run pytest tests/test_a.py -q`)
- <observable behavior>

## Out of scope
- …

## Notes from review (attempt ≥ 2 only)
- …
```

## <id>.result.md (written by the implementer at the worktree root as `RESULT.md`)
```markdown
---
id: T3
attempt: 1
status: done | blocked
---
## Changed
- path/a.py: what and why (one line each)

## Tests
command: `<exact command run>`
outcome: N passed, M failed
```text
<last ~20 lines of the test output>
```

## Deviations
- none | what differed from the task and why

## Questions
- none | what blocked or needs a decision
```

## Rules both sides keep
- The implementer edits only the task's files, runs only the task's test command (plus the
  repo's formatter/linter if the task names it), never commits, pushes, deploys, or touches
  `.git/`, `.orchestra/`, other worktrees, secrets or the network.
- Claude never trusts RESULT.md alone: it reads the diff and runs the test command itself.
- After `max_sendbacks` rejected attempts, Claude implements the task itself.
