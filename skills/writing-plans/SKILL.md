---
name: writing-plans
description: Turns a spec or design into a phased implementation plan with verifiable steps and review gates, before any code is written. Use when you have requirements or a design for a multi-step task and need a plan, or before starting implementation.
---

# Writing Plans

Produce a plan someone could execute without you. Every task says what to change,
where, and how to verify it. Plan on paper first — don't start coding.

## Scope
This skill DOES:
- Read the spec/design and the relevant code, then produce a phased plan where
  each phase is independently verifiable and ordered by dependency.
- Give each task a concrete verification step and mark review/STOP gates.

This skill does NOT:
- Write the implementation code → that's `software-development`.
- Invent requirements from a vague ask → if the spec is unclear, stop and
  clarify the requirements first, before planning.
- Pad the plan with speculative future work → YAGNI; list it as out-of-scope.

## Steps
Surface these as TodoWrite items. The plan file itself is the checkpoint — write
it incrementally to `docs/plans/YYYY-MM-DD-<topic>-plan.md` so work resumes.

### 1. Ground the plan  ⛔ STOP if the spec is unclear
Read the spec/design AND the relevant existing code. Restate the goal and the
observable success criteria in a sentence or two. If the ask is ambiguous or
under-specified, STOP and clarify — do not invent requirements.

### 2. Decompose into phases
Break the work into small phases, each **independently verifiable** and, ideally,
independently shippable. Order them by dependency so each builds on the last.
Prefer the smallest slice that delivers real behavior first.

### 3. Detail each task
For every task write: **what** to change, **where** (file/seam), and **how to
verify** it — a test to write/run, or a behavior to observe. A task with no
verification step is not a real task. See `references/plan-structure.md`.

### 4. Mark gates, risks, and out-of-scope
Insert review/STOP checkpoints between phases. List risks and assumptions, an
explicit **Out of scope (YAGNI)** section, and any open questions.

### 5. Write the plan and hand off
Write the finished plan to `docs/plans/YYYY-MM-DD-<topic>-plan.md`. Point the
user to `software-development` to execute it phase by phase.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| A task with no verification ("improve X", "handle errors") | Make it concrete + add how to verify |
| A giant phase | Split into smaller independently verifiable slices |
| Planning without reading the code | Read the actual code first (Step 1) |
| Speculative "future-proofing" in the plan | Move it to Out of scope (YAGNI) |
| Phases in arbitrary order | Order by dependency; smallest real slice first |
| Planning from a vague spec | STOP and clarify the requirements before planning |
| Starting to write implementation code | Stop — this skill plans; `software-development` builds |

## Done when
- Every phase is independently verifiable and ordered by dependency.
- Every task states what, where, and how to verify.
- Risks, assumptions, out-of-scope, and open questions are listed.
- The plan is written to `docs/plans/`.

## References (load only when needed)
- `references/plan-structure.md` — anatomy of a good plan: phase/task format,
  verification, gates, and out-of-scope.
