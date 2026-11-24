# skill-creator — eval 2026-11-24

new = working tree (57349c7+worktree), baseline = no skill; both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 3/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 1/3 |
| 4 | 3/3 | 2/3 |
| 5 | 4/4 | 3/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 17/17 | 34171.0 | 27.98 |
| baseline | 0.7 | 12/17 | 18529.6 | 22.365 |
| **delta** | **+0.3** | | +15641.4 | +5.615 |

Failed assertions:

- case 1 baseline: Ends by asking for approval and naming skill-reviewer as the next step (does not grade its own skill) — Step 4 runs skill-reviewer and the baseline itself: "**4. Invoke `skill-authoring:skill-reviewer`** on the new skill." The final reply says "Created `skills/summarize-diff/`" and "Run `/reload-plugins`" but never asks for approval or names skill-reviewer as the next step.
- case 3 baseline: Asks a single question rather than a list of questions — Asks five numbered questions: "1. What task should it handle? ... 2. What should trigger it? ... 3. ... 4. ... 5. What should it NOT do?"
- case 3 baseline: Offers 2-3 concrete candidate skills, each with when it would trigger — Lists five bare options ("daily or weekly planning ritual, triaging a TODO or issue backlog, ...") with no trigger per candidate. The only trigger example is generic: "when I paste my task list and ask what to do today."
- case 4 baseline: Does not lecture at length about why evals matter (one or two sentences at most) — Eval justification runs well past two sentences. The opening says "Rule 8 in CLAUDE.md says no skill is finished until a with/without-skill comparison has been run". The final reply adds "CLAUDE.md requires that comparison... tends to score near zero... worth running before release." The security-review 0.00 paragraph adds more.
- case 5 baseline: Removes the 'read references first' step by inlining or dropping the two small reference files — The read-first step is removed, but the files are not inlined or dropped. examples.md is kept and lazy-loaded ("Read `references/examples.md` only if the right type or format is unclear"). conventional-commits.md is deleted only if it "only repeats the public spec".
