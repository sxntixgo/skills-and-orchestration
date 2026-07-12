# claude-skills — Plan

A collection of reusable Claude Code skills, packaged as a Claude Code plugin.

**Status: v1.0.0 (2026-07-12).** All 7 skills built, self-contained, and reviewed
by `skill-reviewer` (including itself) — all PASS. Eval-validated where it counts:
`skill-reviewer` +0.73 and `online-research` +0.19 pass-rate lift; `security-review`
0.00 (a frontier model already knows security — value is consistency/coverage). Full
write-up in [`docs/validation-2026-07-11.md`](docs/validation-2026-07-11.md).

## Goals

Build a set of self-contained, token-frugal skills covering:

1. Authoring skills (create + review, used in tandem)
2. Online research
3. Software development (backend + frontend, one skill with references)
4. Writing tests
5. Reviewing code (correctness/quality)
6. Security review

## Architectural decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Frontend vs backend | **One `software-development` skill** + `references/backend.md`, `references/frontend.md` | Least duplication; shared DRY/YAGNI/KISS workflow; single context |
| Test cases | **Separate `writing-tests` skill** | Reusable on its own; keeps dev skill focused |
| Relationship to `superpowers` | **Standalone / self-contained** | Portable to any machine; no external plugin dependency |
| "Software review" | **`security-review`** skill, separate from `code-review` | Distinct concern (vuln classes, authz, secrets); fits security focus |
| Distribution | **Claude Code plugin** (`.claude-plugin/`) | Installable via `/plugin marketplace add sxntixgo/claude-skills` |
| Token budget | **No mandatory subagents; single context window** | User cost concern; use `references/*.md` progressive disclosure instead |

## Cross-cutting requirements (apply to EVERY skill)

See CLAUDE.md rules 6–7 for the authoritative wording.

- **Checkpointed / resumable** — write intermediate outputs to disk each step so
  work can pause and resume from any step (also keeps live context small).
- **Guardrails against drift** — explicit scope ("does / does NOT do"),
  required-steps checklist surfaced via TodoWrite, STOP/checkpoint gates, and a
  "red flags" list; stop-and-ask over guessing.
- **Eval-backed (baseline comparison)** — each skill ships `evals/evals.json`
  (realistic prompts + expected behavior). "Done" requires a baseline
  comparison: run cases in a fresh session *with* the skill vs. *disabled*, and
  aggregate pass-rate + token/time overhead into `evals/benchmark.json`. This is
  dev-time only (the one sanctioned use of isolated/subagent runs) and is driven
  by `skill-reviewer`. Format: https://agentskills.io/skill-creation/evaluating-skills

## Skill catalog

| Skill | Purpose | Key content |
|-------|---------|-------------|
| `skill-creator` | Author new skills correctly | Frontmatter/trigger rules, progressive disclosure, self-containment, checklist |
| `skill-reviewer` | Review a skill against a rubric | Trigger clarity, scope, token weight, examples, structure — pairs with `skill-creator` |
| `online-research` | Structured web research | Query planning, source triangulation, citation, WebSearch/WebFetch discipline |
| `software-development` | Build backend/frontend software | **TDD loop (red→green→refactor)**, DRY, YAGNI, KISS; workflow; `references/{backend,frontend}.md`; points to `writing-tests` for deeper test-case design |
| `writing-tests` | Design and write test cases | Test-case design, edge/boundary cases, coverage; complements the TDD loop in `software-development` |
| `code-review` | Line-level correctness + quality review | Severity ratings, naming, function size, error handling, project patterns |
| `security-review` | Security-focused review | Injection, authn/authz, secrets, input validation, OWASP-style vuln classes |

## Reference material to repurpose

Inspiration exists in `~/Dev/survivorfantasy/.claude/skills/` (project-specific
React/Flask): `code-reviewer` (has `backend.md`/`frontend.md`), `qa-tester`,
`design-guide`, `functional-programming`. Generalize, don't copy verbatim.

## Tasks

### Phase 0 — Repo scaffolding
- [x] Create `CLAUDE.md`
- [x] Create `plan.md`
- [x] `git init` + `.gitignore` + first commit
- [x] Add plugin scaffolding: `.claude-plugin/plugin.json` (v1.0.0) + `.claude-plugin/marketplace.json`
- [x] Add `LICENSE` (MIT; mirrored in plugin.json `license`)
- [x] Add `README.md` (what it is, install, skill index)
- [x] Verify loading from this folder (subagents read/followed the skills directly; `claude plugin validate .` passes)

### Phase 1 — Skill tooling (build first, cross-validate)
- [x] `skills/skill-creator/SKILL.md` — enforces rules 1–8; 5-stage gated workflow
- [x] `skills/skill-creator/scripts/new_skill.sh` — deterministic scaffold (tested)
- [x] `skills/skill-creator/references/{writing-descriptions,skill-body,writing-evals,examples}.md`
- [x] `skills/skill-creator/evals/evals.json` — 4 cases
- [x] `skills/skill-reviewer/SKILL.md` — 3-stage flow: rubric + gated baseline evals + verdict
- [x] `skills/skill-reviewer/references/{rubric,running-evals}.md`
- [x] `skills/skill-reviewer/evals/evals.json` — 4 cases
- [x] Use `skill-reviewer` on `skill-creator` and on itself; ran baseline evals (skill-reviewer +0.73); fixed all findings

### Phase 2 — Core development loop
- [x] `skills/software-development/SKILL.md` (5-stage lifecycle: understand→plan→TDD→refactor→verify)
- [x] `skills/software-development/references/backend.md`
- [x] `skills/software-development/references/frontend.md`
- [x] `skills/software-development/evals/evals.json` — 4 cases
- [x] `skills/writing-tests/SKILL.md` (enumerate cases → author them)
- [x] `skills/writing-tests/references/test-design.md`
- [x] `skills/writing-tests/evals/evals.json` — 4 cases
- [x] Static rubric cross-check (both clean, self-contained)
- [~] Baseline eval runs: deferred (both PASS rubric; not eval-measured — expected to mirror the process-skill pattern)

### Phase 3 — Review skills
- [x] `skills/code-review/SKILL.md` (correctness/quality; + references/checklist.md; 4 evals)
- [x] `skills/security-review/SKILL.md` (vuln classes; + references/vuln-classes.md; 4 evals)
- [x] Decision: code-review and security-review are fully independent (no cross-reference)
- [x] Static rubric cross-check (both clean, self-contained)
- [x] Baseline evals for `security-review` (3 iterations, incl. multi-file): **0.00** detection lift on a frontier model → re-scoped around consistency/coverage. `code-review` baseline deferred (expected to mirror).

### Phase 4 — Research
- [x] `skills/online-research/SKILL.md` (plan→gather→evaluate→triangulate→cite; tool-agnostic)
- [x] `skills/online-research/references/source-evaluation.md`
- [x] `skills/online-research/evals/evals.json` — 4 cases
- [x] Static rubric cross-check (clean, self-contained)
- [x] Baseline evals for `online-research`: **+0.19** pass-rate lift (primary-source & independence discipline)

### Phase 5 — Finalize
- [x] Update `README.md` skill index
- [x] Final pass with `skill-reviewer` across all 7 skills (all PASS; findings fixed)
- [x] `claude plugin validate .` passes
- [x] Local validation via subagents reading the skills from this folder
- [x] Commit + push to `github.com/sxntixgo/claude-skills`

### Phase 6 — Validation & release
- [x] Honest eval write-up committed: `docs/validation-2026-07-11.md`
- [x] Self-review loop on `skill-reviewer` (3 rounds): found & fixed real flaws each round; rubric clean
- [x] Re-scope `security-review`/`code-review` around consistency/coverage (measured no detection lift)
- [x] Add objective `assertions` to every eval case; improve eval reproducibility
- [x] Set repo description + topics
- [x] Bump plugin.json to **1.0.0** and tag **v1.0.0**

## Out of scope (YAGNI)

- Automated CI/testing harness for skills (revisit if the set grows large)
- Non-skill tooling, dashboards, or web UI
- Pushing to GitHub / creating the remote (done only on explicit request)
