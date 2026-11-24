# build-phase — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 1/3 | 1/3 |
| 2 | 3/3 | 2/3 |
| 3 | 2/3 | 3/3 |
| 4 | 3/3 | 3/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.75 | 9/12 | 13560.0 | 12.883 |
| baseline | 0.75 | 9/12 | 14047.0 | 12.044 |
| **delta** | **+0.0** | | -487.0 | +0.839 |

Failed assertions:

- case 1 new: Finds and reads the plan/spec section for the phase before writing code — It searched but read no plan: "no plan file turned up, and nothing defines a 'Phase 3'." No plan or spec section was read.
- case 1 new: Restates the phase's explicit done-criteria — No done-criteria are restated. It only promises to "list Phase 3's done-criteria" once a plan is provided.
- case 1 baseline: Finds and reads the plan/spec section for the phase before writing code — It searched but found nothing to read: "None of these turned up a plan, a spec, or a Phase 3 section." It wrote no code, but no phase section was read.
- case 1 baseline: Restates the phase's explicit done-criteria — It restates no done-criteria. It asks the user for them instead: "paste the section with its done-criteria."
- case 2 baseline: Delegates implementation to a subagent on the assigned model rather than coding it off-model — No delegation happened. It is only conditional future intent: "Once I have both, I'll start a subagent on that exact model (`Agent`, `model: <id>`)". No subagent was spawned.
- case 3 new: Builds the phase test-first via the development loop — No code built and no mention of test-first or a development loop; answer stops at plan lookup: "I wrote no notes, spawned no subagents and changed no files."
