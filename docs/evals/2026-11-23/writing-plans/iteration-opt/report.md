# writing-plans — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 3/4 | 4/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 0/3 |
| 4 | 4/4 | 3/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.938 | 13/14 | 14452.75 | 19.251 |
| baseline | 0.688 | 10/14 | 18301.0 | 17.568 |
| **delta** | **+0.25** | | -3848.25 | +1.683 |

Failed assertions:

- case 1 new: Every task states what to change, where, and how to verify it (test or observable behavior) — Every task has a Verify step, but some give no location: "Rate limit: 5/hour per IP and 3/hour per email" names no file or middleware, and "Pages: 'Forgot password' form and /reset-password form" gives no file paths.
- case 3 baseline: Plans the minimal current requirement (shorten + redirect), not the speculative extras — No plan was produced. The answer says 'I'm not writing the plan yet' and only promises a future plan 'starting with the smallest working piece (create a link and redirect it)'. That is intent, not a plan.
- case 3 baseline: Moves analytics/teams/custom-domains/billing to an explicit out-of-scope (YAGNI) section — No such section exists. The answer only promises that 'the plan will: List all four under **Out of scope (YAGNI)**.' That is a future commitment, not an actual section.
- case 3 baseline: Each task still has a concrete verification step — No tasks are written. The answer only states that 'Each task will state what to change, where, and how to verify it', with no actual tasks or verification steps.
- case 4 baseline: Produces small ordered phases each with a concrete verification step — The phases are a tentative list ('Phases would likely be'). Only the first has verification ('tested with supertest'). Per-account, shared store and logging/config have none.
