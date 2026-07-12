# Skill validation report — 2026-07-11

Honest results of running the skills through evaluation. Eval workspaces are in
the gitignored `.claude-skills-work/`; this report is the committed record.

**Method:** isolated subagents, fresh context each. "with-skill" = the subagent
reads and follows the actual skill files in this repo; "without-skill" = the
same task with no skill (baseline). Nothing was installed to global config.
Base model: Opus (a frontier model) — this matters for interpreting the results.

**Session note:** a session usage limit interrupted the first attempt; the runs
were completed after the reset. All rows below are final.

## Stage A — static rubric (all 7 skills)
PASS. No 🔴/🟡; a few 🟢 nits (e.g. skill-creator/writing-descriptions say the
description is "the ONLY thing Claude sees" — the `name` is seen too). Details in
`.claude-skills-work/review/rubric-all.md`.

## Stage B — baseline comparisons (with-skill vs without-skill)

### security-review — NO detection lift (2 iterations + a multi-file test)
| Iteration | Cases | with-skill pass | without-skill pass | tokens Δ |
|-----------|-------|:---:|:---:|:---:|
| 1 (canonical vulns) | SQLi, IDOR, SSRF, secrets/MD5 | 100% | 100% | +41% |
| 2 (non-obvious vulns) | JWT decode≠verify, 2nd-order SQLi, mass-assignment, open-redirect+timing | 100% | 100% | +42% |
| 3 (multi-file codebase) | cross-file IDOR in a 3-file bank app | caught | caught | +29% |

Even a deliberately subtle **cross-file** IDOR (transfer trusts a client `from`
without an ownership check, spanning auth.js→routes.js→accounts.js) was caught by
the **unaided** baseline — which also independently found the un-awaited-Promise
dead-check bug. The frontier base model already knows security review. The skill
only added token overhead; its sole observable benefit was output-format
consistency (severity buckets, "Controls verified").

### skill-reviewer (on itself + sibling skills) — REAL, LARGE lift
| Case | with-skill | without-skill |
|------|:---:|:---:|
| 1. review writing-tests | 3/3 | 0/3 |
| 2. review a weak skill | 4/4 | 2/4 |
| 3. confirm an edit is better | 2/2 | 1/2 |
| 4. "run the full eval comparison" | 2/2 | 0/2 |
| **Aggregate (cases 1–4)** | **13/13 = 1.00** | **3/11 = 0.27** |

**Delta: pass-rate +0.73.** Clearly worth it. The baselines gave competent
*generic* reviews but consistently:
- did NOT apply the 8-rule rubric or severity scale,
- did NOT know skills need `evals/evals.json` (missed rule 8 entirely),
- did NOT enforce the STOP gate before eval runs — the with-skill run literally
  paused and asked "Approve spawning the 8 eval runs?", while the **baseline for
  case 4 charged ahead and ran an entire 85k-token nested benchmark without ever
  asking** (exactly the runaway the gate prevents),
- did NOT know the edit→blind-A/B-vs-previous-version convention.

### online-research — real, modest lift (measured)
Produced as a by-product of the case-4 baseline runaway, which ran a full
with/without comparison of online-research (4 cases × 2, live web research):

| Config | pass rate | tokens (mean) | time (mean) |
|--------|:---:|:---:|:---:|
| with-skill | 1.00 | 30,794 | 165s |
| without-skill | 0.81 | 23,088 | 90s |
| **delta** | **+0.19** | +33% | +1.8× |

No regressions. Gains concentrated exactly where the skill targets: with-skill
fetched **primary sources** (IETF draft, vendor pricing pages) and flagged
**source non-independence** (SEO aggregators, an oauth.net editor who co-authors
the spec); the baseline leaned on aggregators and presented non-independent
numbers as corroborated. A process/discipline skill showing genuine lift.

## The general principle this validates
**A skill earns its token cost when it encodes a specific process/discipline the
base model does not already perform — not when it restates knowledge a frontier
model already has.**

- `skill-reviewer` (novel rubric + gate + eval methodology) → strong lift.
- `security-review` (general security knowledge Opus already has) → no detection
  lift; value is only consistency.

Likely implications for the suite (to verify by eval later):
- **Process/discipline skills** show real lift — now measured for two:
  `skill-reviewer` (+0.73) and `online-research` (+0.19). `skill-creator` and
  `software-development` (TDD ordering + checkpoints) are expected to behave the
  same (untested).
- **Knowledge-restating skills** — `security-review` (measured 0.00), and by
  extension `code-review` — show little/no detection lift on a strong model;
  their value is consistency/format/coverage guarantees, and evals should
  measure THAT, not raw detection.

## Scoreboard (measured)
| Skill | Type | pass-rate delta |
|-------|------|:---:|
| skill-reviewer | process/discipline | **+0.73** |
| online-research | process/discipline | **+0.19** |
| security-review | knowledge-restating | **0.00** |

## Recommended follow-ups
1. Re-scope security-review / code-review value claims around consistency and
   coverage, and grade their evals on format/breadth rather than "found the one
   bug". (code-review still untested — expected to mirror security-review.)
2. Add objective `assertions` to every skill's eval cases, and give the
   online-research placeholder cases (2 & 4) concrete subjects so they measure
   the skill's discipline rather than tying at 1.0.
3. Decide whether the knowledge-restating skills earn their token cost on
   frontier models, or should be slimmed to just the process/format guarantees.
