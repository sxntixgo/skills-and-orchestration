# claude-orchestrate-development — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 6 | 4/4 | 4/4 |
| 7 | 6/6 | 1/6 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 10/10 | 28175.0 | 19.848 |
| baseline | 0.584 | 5/10 | 31985.5 | 25.594 |
| **delta** | **+0.416** | | -3810.5 | -5.746 |

Failed assertions:

- case 7 baseline: Does not read diffs, source files, test output or logs in the orchestrator thread — Orchestrator itself runs "git -C .worktrees/2026-11-23-export/<id> diff        # + read untracked files" and "uv run pytest -q && uv run ruff check ."
- case 7 baseline: Delegates specs and reviews to subagents with a named model (spec_model/review_model or sonnet) — No subagent or model is named for spec writing or review. Reviews run inline via claude-review-merge, and specs via "Run `claude-write-task` for T3". No spec_model, review_model or sonnet appears.
- case 7 baseline: Expects or requests one-line replies from the subagents — No subagents are used, and the answer never asks for one-line replies.
- case 7 baseline: At the end of phase 1 runs a phase-level review on opus over the phase diff — There is no phase-level review and opus is never mentioned. The answer goes straight from per-task merges to continuing into phases 2–3.
- case 7 baseline: Stops after phase 1 and tells the user to start a new session to resume the run — It says the opposite: "continue the loop through phase 3 without asking for approval" and "I'll keep going and report per task at the end."
