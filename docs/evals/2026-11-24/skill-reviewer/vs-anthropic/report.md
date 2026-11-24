# skill-reviewer — eval 2026-11-24

new = working tree (369cdd8+worktree), baseline = another skill (/Users/santiago/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator); both with the repo's CLAUDE.md; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 3/3 | 1/3 |
| 2 | 4/4 | 2/4 |
| 3 | 2/3 | 2/3 |
| 4 | 3/3 | 2/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.917 | 12/13 | 54989.5 | 33.128 |
| baseline | 0.542 | 7/13 | 101593.75 | 35.652 |
| **delta** | **+0.375** | | -46604.25 | -2.524 |

Failed assertions:

- case 1 baseline: Applies the 8-rule rubric with severity-rated findings and file:line references — The rubric table has severity markers (✅/⚠️/❌, e.g. "❌ No evals/evals.json. The skill isn't done under rule 8"), but there are no file:line references anywhere.
- case 1 baseline: Does not edit the target skill (reports findings only) — Step 3, placed before the confirmation checkpoint, writes into the target skill: "Write `skills/debugging/evals/evals.json` with prompts only." Step 6 then adds assertions "to `evals.json`".
- case 2 baseline: Flags the missing evals/evals.json (Rule 8) and notes Stage B cannot run — Flags it: "No `evals/evals.json` | Blocker. House rule 8 says a skill isn't done until a baseline comparison shows it helps." Never says Stage B (or the baseline comparison) cannot run now.
- case 2 baseline: Verdict is ITERATE — No ITERATE verdict. The only verdict-like statement is "The skill fails review on all three points."
- case 3 new: Describes a blind A/B comparison between the two versions — It compares old vs new, but never says the comparison is blind. The trigger eval is graded mechanically ("pass/fail on whether the skill loaded, so no judge calls"), and the optional run mentions "8 judge calls" without saying the judge can't tell which version produced which output.
- case 3 baseline: Describes a blind A/B comparison between the two versions — It compares old and new trigger rates on the same eval set, but never mentions blinding: no hidden version labels and no blind grader or comparator.
- case 4 baseline: Reports the run count (cases x 2) and token/time cost — It gives the run count ("Spawn all 6 subagents in one turn") but no token or time cost estimate. It only says the benchmark will later report "time and tokens per configuration."
