Stage A rubric is done: no 🔴 findings, two 🟡, three 🟢. Stage B is ready but stopped at the approval gate, so no eval runs have been spawned.

**Assumptions:** The skill's `SKILL.md` is the one in `case-files/4/` (56 lines, no `references/`). I couldn't see `evals/evals.json`, so I assumed a valid file with 5 realistic cases.

### What I'd do, in order
1. **TodoWrite:** add three items: Stage A rubric, Stage B evals (gated), Stage C verdict.
2. **Read:** `skills/online-research/SKILL.md` and `skills/online-research/evals/evals.json`. Neither `references/` nor `scripts/` exists.
3. **Write** `./.claude-skills-work/online-research/review/rubric.md`:
```
🟡 Rule 6 — Checkpointing is underspecified (SKILL.md:18): the notes.md path is named, but no step says to write to it after each stage, and nothing says how to resume from it. Make it explicit, e.g. "append sources after Gather, claim/source matrix after Triangulate".
🟡 Rule 8 — Verify evals cover the skill's distinctive behaviors: the no-web-tool fallback (SKILL.md:10), wire-story duplicates counting as one source (:28), and a time-sensitive question (:20). If they only cover a plain "research X" prompt, the baseline delta will be weak.
🟢 Rule 1 — Trigger may overlap the sibling opencode-research skill ("research, investigate"). Add a disambiguating clause to one of the two descriptions.
🟢 Rule 7 — Mixed signal on Step 1: it's marked ⛔ (STOP), but the text says "Ask only if ambiguous" (SKILL.md:19-20). Keep one. There's also no stop-and-ask when the research scope balloons or key sources are paywalled.
🟢 Rule 5 — The Answer template's code fence (SKILL.md:32-39) isn't indented under step 5, which breaks the numbered list. `<topic>` slug format is undefined.
```
Rules 2, 3 and 4 have no findings: the skill is self-contained, lean, and needs no subagents.

4. **Stage B gate (stop here):**

### Eval run count: needs your approval
- 5 cases × 2 configs (with the skill vs. with it disabled) = **10 runs**.
- Each run is a fresh isolated subagent with its own token and time cost. Web research runs are the expensive kind, since each one searches and opens several pages.
- Outputs, `timing.json` and `benchmark.json` would go in `./.claude-skills-work/evals/online-research/iteration-1/`.
- This is the baseline comparison against no skill. If you'd rather benchmark against the previous version (git status shows `SKILL.md` was modified and `references/source-evaluation.md` deleted), I'd run a blind A/B against the snapshot from `HEAD` instead. It's the same 10 runs.

**Run all 10, run the A/B against `HEAD`, or skip evals?** If you skip, the verdict rests on the rubric alone, and it can't be a PASS.