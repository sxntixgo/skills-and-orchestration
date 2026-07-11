# Skill validation report — 2026-07-11

Honest results of running the skills through evaluation. Eval workspaces are in
the gitignored `.claude-skills-work/`; this report is the committed record.

**Method:** isolated subagents, fresh context each. "with-skill" = the subagent
reads and follows the actual skill files in this repo; "without-skill" = the
same task with no skill (baseline). Nothing was installed to global config.
Base model: Opus (a frontier model) — this matters for interpreting the results.

**Session note:** a session usage limit interrupted the run. skill-reviewer
case 4 and a batch of online-research runs did not finish; those rows are marked
incomplete and can be re-run after reset.

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
| 4. "run the full eval comparison" | incomplete (session limit) | incomplete |
| **Aggregate (cases 1–3)** | **9/9 = 1.00** | **3/9 = 0.33** |

**Delta: pass-rate +0.67 for +44% tokens.** Clearly worth it. The baselines gave
competent *generic* reviews but consistently:
- did NOT apply the 8-rule rubric or severity scale,
- did NOT know skills need `evals/evals.json` (missed rule 8 entirely),
- did NOT enforce the STOP gate before eval runs — the with-skill run literally
  paused and asked "Approve the 8-run baseline eval?",
- did NOT know the edit→blind-A/B-vs-previous-version convention.

## The general principle this validates
**A skill earns its token cost when it encodes a specific process/discipline the
base model does not already perform — not when it restates knowledge a frontier
model already has.**

- `skill-reviewer` (novel rubric + gate + eval methodology) → strong lift.
- `security-review` (general security knowledge Opus already has) → no detection
  lift; value is only consistency.

Likely implications for the suite (to verify by eval later):
- **Process/discipline skills** — `skill-creator`, `skill-reviewer`,
  `software-development` (TDD ordering + checkpoints), `online-research`
  (triangulation/citation discipline) — most likely to show real lift. Early
  partial online-research runs support this: the with-skill run triangulated
  primary sources (oauth.net, IETF datatracker) and flagged draft/non-final
  status, while the baseline leaned on vendor blogs.
- **Knowledge-restating skills** — `security-review`, `code-review` — lift on a
  strong model is likely small; their value is consistency/format/coverage
  guarantees, and evals should measure THAT, not raw detection.

## Recommended follow-ups
1. Re-run skill-reviewer case 4 and the online-research baseline after the limit
   resets, to complete the numbers.
2. Re-scope security-review / code-review value claims around consistency and
   coverage, and grade evals on format/breadth rather than "found the one bug".
3. Consider whether the knowledge-restating skills are worth their token cost on
   frontier models, or should be slimmed to just the process/format guarantees.
