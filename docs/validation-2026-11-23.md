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

## Round 2 — fewer tokens, higher pass rate, all Claude-side skills (frugal-skills 1.5.0, orchestration 0.5.0)

Method: profile each skill at HEAD (`abeval.py run --only new_skill`), fix what failed and what
cost turns, then A/B the new version against HEAD (blind judge, Opus, 1 run per case). Records:
`docs/evals/2026-11-23/<skill>/iteration-opt/`.

The main token lever: **every file a skill tells the model to read is one more turn that
re-reads the whole context.** So each skill now carries what it needs on its page (references
merged in or dropped; `contract.md` and sibling scripts no longer opened), with short output
formats.

| Skill | HEAD pass | HEAD tokens | new pass | new tokens | Δ pass |
|---|:---:|---:|:---:|---:|:---:|
| brainstorming | 9/14 | 22.0k | 13/14 | 13.6k | +0.31 |
| writing-plans | 10/14 | 18.3k | 13/14 | 14.5k | +0.25 |
| software-development | 7/13 | 22.1k | 13/13 | 14.8k | +0.50 |
| build-phase | 9/12 | 14.0k | 9/12 | 13.6k | 0 |
| code-review | 12/13 | 25.7k | 13/13 | 15.7k | +0.06 |
| security-review | 20/20 | 26.7k | 20/20 | 15.3k | 0 |
| debugging ¹ | 20/21 | 48.8k | 21/21 | 47.4k | +0.04 |
| online-research ¹ | 12/13 | 73.6k | 13/13 | 56.5k | +0.08 |
| writing-tests | 13/13 | 22.6k | 13/13 | 14.1k | 0 |
| skill-reviewer | 12/13 | 48.8k | 13/13 | 45.7k | +0.08 |
| claude-dispatch | 10/10 | 25.1k | 10/10 | 13.5k | 0 |
| claude-fix-dependabot | 23/24 | 31.1k | 24/24 | 24.0k | +0.04 |
| claude-orchestrate-research | 22/23 | 24.4k | 23/23 | 15.8k | +0.04 |
| claude-write-task | 22/22 | 25.1k | 21/22 | 14.6k | −0.03 |
| claude-orchestrate-development | 27/31 | 31.6k | 31/31 | 17.1k | +0.17 |
| **all 15** | **228/256** | **460k** | **250/256** | **356k** | **+0.09** |

¹ real tools (Bash/Edit on fixtures, WebSearch/WebFetch), so most tokens are tool output.

Tokens per run fell 23% overall and 35–46% on skills that used to load a reference.
Remaining failures: build-phase cases 1 and 3 (the eval gives no plan, so "stop and ask" — the
right behaviour — fails the "read the plan / build test-first" assertions; eval design);
brainstorming case 1 (offers options before purpose is known; judged against "purpose first");
claude-write-task case 1 (no `page_size` cap; judge noise between runs, the HEAD version
failed a different assertion of this case in the profile).

Changes besides the rewrites:
- `dispatch.sh` printed no `DISPATCH` line on early exits (2/3/4) although the skill reads it;
  fixed, test `scripts/tests/test_dispatch.sh`.
- `abeval.py`: `--only`, per-case `eval_tools`/`eval_allowed` (real tool runs), resumable runs
  and fail-fast on usage limits; the run prompt treats unnamed inputs as missing.
- Evals: assertions for claude-dispatch, claude-fix-dependabot, claude-orchestrate-research;
  fixtures for code-review case 4 and debugging case 4 (a real order-dependent flaky test);
  orchestrate-development case 2 accepts moving the shared edit into one task.

## Follow-ups
1. Rewrite skill-creator cases 1, 2, 4 and build-phase cases 1, 3 so the eval supplies the
   plan/brief (or asserts the gate).
2. An opencode runner for opencode-develop / opencode-research.
3. No-skill baselines for code-review, security-review, writing-tests, build-phase to decide
   the consolidation proposed in `docs/review-2026-11-23.md` §8.
4. A live check of the orchestrator: these are dry runs; the first real phase with the new
   flow should confirm that subagent replies stay one line and the session stops per phase.
