# Takeover: pick the cheapest Claude model that can do it

After `max_rejections` (default 3) rejected attempts, or when the task is beyond the local model,
Claude implements the task. To save tokens, delegate the implementation to a subagent on the
**cheapest model likely to succeed** (Agent tool, `model` parameter), not the orchestrator's own
model by default. The orchestrator still reviews the result.

| Model | Use for | Examples |
|---|---|---|
| `haiku` | Mechanical, fully specified, ≤ 2 files; the spec + review notes say exactly what to change | rename/move, fix the listed failing assertion, add a validation the notes spell out, bump versions + fix lockfile |
| `sonnet` (default) | Normal feature work: a few files, real logic, tests to write; opencode got close but kept missing edge cases | new endpoint + tests, component with state, a refactor inside one module |
| `opus` | Needs judgment: design flaw in the spec, cross-cutting change, concurrency/security, a bug nobody has located after 3 attempts | auth flow, migration with data risk, flaky/race failures, untangling a wrong abstraction |

Start at the lowest row that fits. If that model's result is rejected once, go up one row (never
two attempts on the same model). If even `opus` fails, stop and report to the user.

## Prompt for the subagent
Give it everything it needs; it has no other context:
- Absolute path of the worktree; "work only there; don't commit, push, or switch branches".
- The full task.md (goal, files, steps, Done when, out of scope) and all `Notes from review`.
- A short summary of what the previous attempts got wrong.
- The rules: TDD (failing test first, then the simplest code), YAGNI, DRY, the repo's style.
- "Run `<exact test command>` until it passes; reply with: files changed, test command, last
  ~20 lines of its output, anything you could not do."

Then run steps 2–5 of `claude-review-merge` on the worktree as usual. Log the model used and the
outcome in `board.md`.
