# claude-skills — Plan

A collection of reusable Claude Code skills, packaged as a Claude Code plugin.

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
- [ ] Add plugin scaffolding: `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`
      (set an explicit `version` in plugin.json; bump on releases, don't rely on SHA-based versioning)
- [ ] Add `LICENSE` (and mirror in plugin.json `license` field)
- [x] Add `README.md` (what it is, install, skill index)
- [ ] Verify dev loading works: `claude --plugin-dir .`, `/reload-plugins`, invoke a namespaced skill

### Phase 1 — Skill tooling (build first, cross-validate)
- [x] `skills/skill-creator/SKILL.md` — enforces rules 1–8; 5-stage gated workflow
- [x] `skills/skill-creator/scripts/new_skill.sh` — deterministic scaffold (tested)
- [x] `skills/skill-creator/references/{writing-descriptions,skill-body,writing-evals,examples}.md`
- [x] `skills/skill-creator/evals/evals.json` — 4 cases
- [x] `skills/skill-reviewer/SKILL.md` — 3-stage flow: rubric + gated baseline evals + verdict
- [x] `skills/skill-reviewer/references/{rubric,running-evals}.md`
- [x] `skills/skill-reviewer/evals/evals.json` — 4 cases
- [ ] Use `skill-reviewer` on `skill-creator` and vice versa; run baseline evals; refine both

### Phase 2 — Core development loop
- [x] `skills/software-development/SKILL.md` (5-stage lifecycle: understand→plan→TDD→refactor→verify)
- [x] `skills/software-development/references/backend.md`
- [x] `skills/software-development/references/frontend.md`
- [x] `skills/software-development/evals/evals.json` — 4 cases
- [x] `skills/writing-tests/SKILL.md` (enumerate cases → author them)
- [x] `skills/writing-tests/references/test-design.md`
- [x] `skills/writing-tests/evals/evals.json` — 4 cases
- [x] Static rubric cross-check (both clean, self-contained)
- [ ] Baseline eval runs with `skill-reviewer` (gated; deferred for token cost)

### Phase 3 — Review skills
- [ ] `skills/code-review/SKILL.md`
- [ ] `skills/security-review/SKILL.md`
- [ ] Review both with `skill-reviewer`

### Phase 4 — Research
- [ ] `skills/online-research/SKILL.md`
- [ ] Review with `skill-reviewer`

### Phase 5 — Finalize
- [ ] Update `README.md` skill index
- [ ] Final pass with `skill-reviewer` across all skills
- [ ] `claude plugin validate .` passes
- [ ] End-to-end local install test: `/plugin marketplace add ./` then install + invoke a skill
- [ ] Commit; push to `github.com/sxntixgo/claude-skills` (only when asked)

## Out of scope (YAGNI)

- Automated CI/testing harness for skills (revisit if the set grows large)
- Non-skill tooling, dashboards, or web UI
- Pushing to GitHub / creating the remote (done only on explicit request)
