---
name: implement-task
description: Steps for implementing one orchestration task from an attached task.md inside a git worktree — read, test first, change only the listed files, run the task's test command until it passes. Use when you are the implementer and have been given a task.md.
---

# Implement a task

## Steps
1. **Read the whole task.md.** Note: files you may change/create, the exact test command in
   "Done when", what is out of scope, and any "Notes from review" (attempt ≥ 2: those come first).
2. **Read before writing.** Open every file you will change and the pattern file named in
   Context. Copy its style: naming, error handling, test layout.
3. **Run the test command once** before changing anything, to see where you start.
   If it fails for a reason unrelated to the task (missing tool, broken setup), stop: report
   `blocked` with the error.
4. **Tests first** when the task lists tests: write them, run them, see them fail for the right
   reason.
5. **Make the smallest change** that satisfies the steps. Only the listed files.
6. **Run the test command.** Fix and rerun until it passes. If after 3 honest attempts it still
   fails, stop and report `blocked` with the failing output.
7. **Self-check the diff** (`git diff`, `git status`): only listed files changed, no debug prints,
   no commented-out code, no unrelated formatting.
8. Hand over to `report-result`.

## Don't
- Edit files outside the list, add dependencies, or "fix" other things you notice
  (mention them under Questions instead).
- Change a test so it passes instead of fixing the code.
- Commit, push, switch branches, or use the network.
