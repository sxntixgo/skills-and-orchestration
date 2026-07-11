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
- [ ] Add `README.md` (what it is, install, skill index)

### Phase 1 — Skill tooling (build first, cross-validate)
- [ ] `skills/skill-creator/SKILL.md`
- [ ] `skills/skill-reviewer/SKILL.md`
- [ ] Use `skill-reviewer` on `skill-creator` and vice versa; refine both

### Phase 2 — Core development loop
- [ ] `skills/software-development/SKILL.md` (TDD red→green→refactor + DRY/YAGNI/KISS + workflow)
- [ ] `skills/software-development/references/backend.md`
- [ ] `skills/software-development/references/frontend.md`
- [ ] `skills/writing-tests/SKILL.md`
- [ ] Review both with `skill-reviewer`

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
- [ ] Commit; push to `github.com/sxntixgo/claude-skills` (only when asked)

## Out of scope (YAGNI)

- Automated CI/testing harness for skills (revisit if the set grows large)
- Non-skill tooling, dashboards, or web UI
- Pushing to GitHub / creating the remote (done only on explicit request)
