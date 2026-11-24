The full eval comparison can't run yet. `skills/online-research/` has no `evals/evals.json`, and CLAUDE.md rule 8 requires one. I've written the static review and stopped there, because test cases would have to be invented to run the benchmark. I need your go-ahead before I draft any.

**Assumptions:** `SKILL.md` matches `case-files/4/SKILL.md`. I found no `evals.json` and no `evals/files/` under `case-files/4/`, so I'm treating it as not found.

**What I did, in order**
1. Added TodoWrite items: static review, check evals, draft cases (blocked), with/without runs, benchmark, report.
2. Read `skills/online-research/SKILL.md` (56 lines) and checked it against the house rules.
3. Looked for `skills/online-research/evals/evals.json` and didn't find it. No benchmark has run.
4. Wrote the review to `./.claude-skills-work/skill-reviewer/online-research/review.md`. A later session can pick up from there.

**Static review**

| Rule | Result | Note |
|---|---|---|
| 1 Frontmatter | ✅ | `name` matches the directory name. The description is third person and has a concrete "Use when…" trigger. |
| 2 Self-contained | ✅ | It falls back to "label unverified" when no web tool exists. |
| 3 Progressive disclosure | ✅ | 56 lines, so it doesn't need `references/`. |
| 4 Single context | ✅ | It doesn't use subagents. |
| 5 Imperative | ✅ | |
| 6 Checkpointed | ⚠️ | The path to `notes.md` is given, but there's no instruction to resume from an existing `notes.md`. It also doesn't say how to build the `<topic>` slug. |
| 7 Guardrails | ⚠️ | Scope, todos and red flags are good. The only gate is Clarify. There's no stop when sub-questions grow beyond what was asked. |
| 8 Eval-backed | ❌ | `evals/evals.json` is missing. |

**Proposed fixes (one line each)**
- Step 1: "If `notes.md` exists, read it and resume at the first unfinished step."
- Step 2: "If the plan needs more than about 5 sub-questions or goes beyond the asked scope, ⛔ confirm with the user first."
- Formatting: the Answer template's code fence starts at column 0 inside a numbered list, which breaks the list. Indent it.

**Lift risk**
A frontier model usually cites sources on its own when it has web tools. That puts this skill at the same risk as `security-review` (0.00 lift). The value is probably in the process rules:
- requiring 2 *independent* sources, where wire reprints count as one
- citing only pages that were actually opened
- tracing claims back to primary sources
- giving dates on time-sensitive facts

The evals should test those rules, not whether the answer has citations.

**Draft evals I'd write once you approve** (about 6 cases, each with assertions)
1. A time-sensitive fact, like the current version of a library. Checks: a dated source and the year in the query.
2. A claim that spread from one press release. Checks: the reprints counted as one source and the claim flagged single-source.
3. A contested health or statistics claim. Checks: a disagreements section and confidence not set to high.
4. A request for a quote. Checks: the quote comes from an opened primary source and nothing is fabricated.
5. A scenario with no web tool. Checks: it says so up front and labels claims unverified.
6. An ambiguous scope, like "research Rust". Checks: it asks a question at Clarify.

**After approval, the run would be:**
- Each case run twice, with the skill and with it disabled, in fresh sessions with web access (Agent tool, same model on both sides).
- Grading against the assertions.
- Results aggregated into `.claude-skills-work/evals/online-research/iteration-1/benchmark.json`: pass rate, tokens and time, with vs. without.
- A verdict: keep, trim, or fold.

Shall I draft `evals/evals.json` with those 6 cases and run the comparison? The live web runs cost tokens on both sides.