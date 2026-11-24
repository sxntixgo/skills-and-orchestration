# brainstorming — eval 2026-11-23

new = working tree (ec26d7e+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 3/4 | 3/4 |
| 2 | 4/4 | 3/4 |
| 3 | 3/3 | 2/3 |
| 4 | 3/3 | 1/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.938 | 13/14 | 13630.75 | 13.848 |
| baseline | 0.625 | 9/14 | 22006.5 | 15.625 |
| **delta** | **+0.313** | | -8375.75 | -1.777 |

Failed assertions:

- case 1 new: Focuses on purpose, constraints, and success criteria before proposing a solution — It proposes approaches and a recommendation ("My lean is A") before purpose is known. Constraints and success criteria appear only in the internal WIP file, not in questions to the user.
- case 1 baseline: Explores 2-3 approaches with trade-offs and a recommendation before finalizing — Three approaches with brief trade-offs appear only as a plan for later turns ("In-app table plus polling (simplest)…"). None is recommended; "with a recommendation" is stated intent only. The user is not shown any approaches.
- case 2 baseline: Proposes 2-3 approaches with trade-offs and a recommendation — Lists three approaches with trade-offs (e.g., "In-process LRU per instance: simplest. Copies can disagree across instances") but never picks one; it says only "I'd lay out three approaches and recommend one."
- case 3 baseline: Explores simpler alternatives alongside the plugin approach, with trade-offs — The approaches listed ('compile-time modules with a registry', 'runtime-loaded packages', 'out-of-process plugins over RPC') are all plugin variants, deferred to a later turn, and come with no trade-offs. No non-plugin alternative, such as plain modular code, is weighed.
- case 4 baseline: Presents both options with concrete trade-offs tied to the user's context — The final reply only asks a clarifying question about consumers. It gives no REST vs GraphQL trade-offs.
- case 4 baseline: Leads with a reasoned recommendation rather than declaring unilaterally or staying neutral — No recommendation is given. The reply defers with "the answer depends on who will use the API" and asks a question instead.
