# Skill validation report — 2026-11-23

Second formal round (first: `validation-2026-07-11.md`). Every number below comes from
`scripts/evals/abeval.py`; the full record of each run (answer, tokens/time, the judge's
per-assertion evidence) is in `docs/evals/2026-11-23/<skill>/iteration-N/`.

**Method (changed since July).** Each run is a fresh `claude -p --safe-mode` process with Opus
(no CLAUDE.md, installed plugins, hooks or memory), tools limited to `Read`, in a snapshot of the
skill's plugin root with every `evals/` folder removed. Baseline = the skill at `HEAD` (an edit
A/B) or no skill (the same repo snapshot without the skill). Runs are dry runs: the model writes
what it would do. Grading is blind: one Opus judge call per run sees only the prompt, the
assertions and the answer; a PASS needs quoted evidence. "Tokens" = input + output + cache reads
+ cache writes per run.

The July method spawned subagents inside the user's session, so "without skill" baselines could
still see CLAUDE.md and the installed plugin, and tokens were copied by hand; numbers from the two
rounds are not directly comparable.

## Results

| Skill | Baseline | New | Baseline | Δ pass rate | Tokens new / base | $ per run new / base |
|---|---|:---:|:---:|:---:|:---:|:---:|
| claude-orchestrate-development (it. 1, all 8 cases) | HEAD | 30/31 | 21/31 | **+0.27** | 34.0k / 36.4k | 0.142 / 0.142 |
| claude-orchestrate-development (it. 2, cases 6–7 after the Rule 2 fix) | HEAD | 10/10 | 5/10 | **+0.42** | 28.2k / 32.0k | 0.119 / 0.130 |
| claude-review-merge (it. 1) | HEAD | 29/30 | 26/30 | +0.09 | 28.7k / 26.2k | 0.118 / 0.111 |
| **claude-review-merge (it. 2, token-trimmed)** | HEAD | **30/30** | 26/30 | **+0.12** | **14.5k** / 24.1k | **0.070** / 0.105 |
| claude-write-task | HEAD | 21/22 | 20/22 | +0.03 | 23.8k / 23.5k | 0.112 / 0.107 |
| skill-creator (it. 1) | none | 8/13 | 4/13 | +0.29 | 15.7k / 6.1k | 0.071 / 0.043 |
| **skill-creator (it. 2, token-trimmed)** | none | 8/13 | 6/13 | +0.15 | **12.8k** / 9.7k | **0.064** / 0.064 |
| skill-reviewer | none | 11/13 | 6/13 | **+0.38** | 52.6k / 24.9k | 0.144 / 0.099 |

## What the numbers say

**claude-orchestrate-development** — the token-budget changes (subagents for specs/reviews,
one session per plan phase, no tiny tasks) are what moved: case 7 6/6 vs 1/6, case 8 3/3 vs 0/3.
The rest ties. Case 2 fails on both: instead of adding a dependency between two tasks that
share `api/routes.py`, both versions move the shared edit into one task — arguably better than
the assertion; the assertion should accept either.

**claude-review-merge** — the new behaviour (use `review-check.sh`, one-line verdict, skip
lockfiles) is where the baseline loses (case 7: 2/5). Trimming the skill so it never opens
`contract.md` or the script (each extra file read is one more turn re-reading the whole context)
halved its cost: **28.7k → 14.5k tokens (−49%), $0.118 → $0.070 per run**, now cheaper than the
old version, with 30/30 instead of 29/30. This is the most frequently used skill, so this is the
saving that matters.

**claude-write-task** — small lift (+0.03): the new "point to the plan, don't copy it" case 5
(4/4 vs 2/4) is the only difference.

**skill-creator** — lifts over no skill (+0.15 to +0.29; the baseline varied 4/13 → 6/13 between
two runs, so treat the delta as ±0.15). Trimming cut 15.7k → 12.8k tokens (−18%) at the same
8/13. Its remaining failures are the eval, not the skill: cases 1, 2 and 4 expect a finished skill
in one reply, but the skill correctly stops at its Stage 1 approval gate. Rewrite those cases as
two turns (brief, then "approved") before reading more into its score.

**skill-reviewer** — still a strong process skill (+0.38 over no skill), at twice the tokens
(it reads the rubric and the target skill).

## Changes made in this round (orchestration plugin 0.4.0, frugal-skills 1.4.1)
- `claude-orchestrate-development`: plan gate; context budget (subagents for specs/reviews with
  one-line replies, one session per plan phase, end-of-phase Opus review, no inline fixes, no
  tiny tasks); sibling-plugin skills are "if installed" with an inline fallback (Rule 2).
- `claude-review-merge`: `scripts/review-check.sh` (scope + task test + suite + lint, summaries
  only; tests in `scripts/tests/test_review_check.sh`); self-contained page; lockfile-free diff;
  one-line verdict; reject/takeover handed back to the orchestrator.
- `claude-write-task`: point to the plan instead of copying it; reply with the path only.
- `contract.md` v1.1: `test_cmd`, `lint_cmd`, `spec_model`, `review_model`.
- `skill-creator`: batch-read references; assertions required with every case; trimmed.
- Objective `assertions` for all 20 cases of the three orchestration skills (the other 31
  orchestration cases still have none).

## Follow-ups
1. Rewrite skill-creator cases 1, 2, 4 as two-turn cases; relax orchestrate-development case 2's
   assertion to accept "move the shared edit into one task".
2. Assertions + runs for claude-dispatch, claude-fix-dependabot, claude-orchestrate-research;
   an opencode runner for opencode-develop / opencode-research.
3. Point skill-reviewer's Stage B at `scripts/evals/abeval.py` (see `docs/review-2026-11-23.md`).
4. Measure the frugal skills still missing from the scoreboard: software-development,
   writing-tests, build-phase, code-review.
5. A live check of the orchestrator: these are dry runs; the first real phase with the new
   flow should confirm that subagent replies stay one line and the session stops per phase.
