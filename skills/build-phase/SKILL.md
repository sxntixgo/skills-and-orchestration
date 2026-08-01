---
name: build-phase
description: Builds ONE planned phase/milestone of a project from a written spec — reading the plan, honoring a per-task model assignment, staying in scope, verifying, and reporting. Use when implementing a discrete phase or work package from a PLAN.md/SPEC.md, especially when the plan assigns models to tasks.
---

# Build a Phase

Orchestrates building ONE phase of a planned project. This skill owns *which*
phase, *which model*, scope control, plan hygiene, and reporting; it leans on the
sibling build skills for the actual loop. Read the plan first — this is the _how_,
the plan is the _what_.

## Scope

This skill DOES:
- Locate the spec, scope the phase to its explicit done-criteria, and build it.
- Honor a per-task **model assignment** from the plan: run that work on the
  assigned model — delegating to a subagent when you are on a different one.
- Keep the plan current (add newly-agreed work with its model; prune completed
  entries once their durable decisions live in code/`CLAUDE.md`).
- Report what changed, the test results, and the verification output.

This skill does NOT:
- Re-derive the build loop. The red→green→refactor TDD loop with DRY/YAGNI/KISS
  and "verify it runs" is owned by `software-development`; test-case selection by
  `writing-tests`; failure diagnosis by `debugging`; review by `code-review` /
  `security-review`. Use those rather than restating them here.
- Pull later-phase work forward, add speculative abstractions, or invent
  requirements the plan does not state.
- `git commit` — the human controls commits.

## Works with (same plugin — load as the phase needs)

`brainstorming` and `writing-plans` (turn a vague phase into a design/plan),
`software-development` (the build loop), `writing-tests` (which test cases),
`debugging` (failures), `code-review` / `security-review` (review). Each triggers
on its own description; this skill degrades gracefully if one is absent.

## Required steps (make a TodoWrite item per step)

1. **Read the plan.** Find the spec (commonly `PLAN.md`/`SPEC.md`, or a file named
   in `CLAUDE.md`). Read the section for THIS phase; write its done-criteria to a
   note. ⛔ STOP and ask if no plan/spec exists or the phase is undefined.
2. **Orient.** Read `CLAUDE.md`/`AGENTS.md`; skim the target code for style and
   reusable utilities; infer the test / lint / typecheck / build commands from the
   repo. Use the project's existing commands; don't add tools without reason.
3. **Confirm scope & model.** Restate the done-criteria. If the plan assigns a
   model to the task, run the implementation on that model — spawn a subagent with
   that exact `model:` when you are on a different one, and split the work if the
   phase lists more than one. Honor any project rule about who authors tests.
   ⛔ STOP if the assigned model or the scope is ambiguous.
4. **Build the slice** with the `software-development` loop (test-first
   red→green→refactor; `writing-tests` picks the cases). Stay strictly inside this
   phase — no later-phase work, no speculative abstractions.
5. **Verify it runs.** Tests pass, typecheck/lint clean, build green, and the real
   behavior exercised — not just a typecheck. Don't leave dev servers running for
   automated checks.
6. **Update the plan.** Add newly-agreed work with its model assignment; prune
   completed entries once their durable decisions live in code/`CLAUDE.md`.
7. **Report.** Files changed, test results (counts + names), verification output,
   and any deviation from the plan with the reason. Do NOT `git commit` unless asked.

## Red flags (stop and correct)

| If you notice… | Do this |
|----------------|---------|
| Coding before reading the plan section | Stop; read it, restate done-criteria |
| Implementing on a cheaper model than assigned | Switch to the assigned model / subagent |
| Building Phase N+1 while Phase N is unmet | Stop — one phase at a time |
| Writing code before a failing test | Defer to `software-development` — test first |
| Restating TDD / DRY / KISS rules here | Defer to `software-development` / `writing-tests` |
| About to `git commit` | Don't — the human owns commits |

## Done when

- The phase's done-criteria are met and covered by tests written test-first.
- You ran the real behavior and observed it working (not just a typecheck).
- The plan reflects reality (new work added with its model, completed work pruned).
- You reported files changed, results, verification output, and any deviation.
