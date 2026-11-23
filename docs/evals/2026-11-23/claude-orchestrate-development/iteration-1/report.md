# claude-orchestrate-development — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 3/4 | 3/4 |
| 3 | 4/4 | 4/4 |
| 4 | 3/3 | 3/3 |
| 5 | 3/3 | 2/3 |
| 6 | 4/4 | 4/4 |
| 7 | 6/6 | 1/6 |
| 8 | 3/3 | 0/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.969 | 30/31 | 33999.5 | 25.729 |
| baseline | 0.698 | 21/31 | 36397.5 | 29.113 |
| **delta** | **+0.271** | | -2398.0 | -3.384 |

Failed assertions:

- case 2 new: Serializes T2 and T3 (adds a dependency) instead of running them together — No T2/T3 dependency is added. T3 has depends_on '–' and T2 depends only on T1. The conflict is resolved by moving T3's routes.py edit into T2, so T2 can run while T3 is still running.
- case 2 baseline: Serializes T2 and T3 (adds a dependency) instead of running them together — No T2/T3 dependency is added. The answer moves T3's routes.py edit into T2, and the board has T3 depends_on [] and T2 depends_on [T1]. When T1 merges, T2 can run while T3 is still running.
- case 5 baseline: Sends both back to opencode with review notes (--continue) — Both are sent back with notes ("run `claude-write-task` again with `attempt: 2` and the review notes under `## Notes from review`"). But it re-writes the task and re-dispatches. It never mentions continuing the opencode session via --continue.
- case 7 baseline: Does not read diffs, source files, test output or logs in the orchestrator thread — Orchestrator reads diffs and tests directly: "git -C $W status --porcelain && git -C $W diff" and "uv run pytest tests/export/test_core.py -q # ... run by me"
- case 7 baseline: Delegates specs and reviews to subagents with a named model (spec_model/review_model or sonnet) — No subagent or named model mentioned; review is done inline: "Diff review: I check correctness and edge cases"
- case 7 baseline: Expects or requests one-line replies from the subagents — No subagents are used, and no one-line reply format is requested anywhere
- case 7 baseline: At the end of phase 1 runs a phase-level review on opus over the phase diff — No phase-level review or opus model mentioned; loop continues straight into T3/T4
- case 7 baseline: Stops after phase 1 and tells the user to start a new session to resume the run — Continues through all phases: "keep the loop going through phase 3"; final reply reports all 6 tasks merged
- case 8 baseline: Does not dispatch the MAX_ROWS constant as its own opencode task — Answer dispatches T2 alone: "bash plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh 2026-11-23-row-limit T2" and "T2 ... is with opencode"
- case 8 baseline: Merges it into the task that uses MAX_ROWS (or does it as part of that task) — Explicitly keeps it separate: "Out of scope - Using MAX_ROWS anywhere else (later tasks do that)"; no merging into the consuming task
- case 8 baseline: Gives the size reason: the spec would be as long as the code — Only says "Normally I'd make a one-line change like this myself"; never argues the spec would be as long as the code
