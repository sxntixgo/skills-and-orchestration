---
name: writing-plans
description: Turns a spec or design into a phased implementation plan with verifiable steps and review gates, before any code is written. Use when you have requirements or a design for a multi-step task and need a plan, or before starting implementation.
---

# Writing Plans

A plan someone could execute without you: every task says **what** to change, **where**, and
**how to verify** it. Plan, don't code.

## Scope
DOES: read the spec/design and the relevant code; write a phased plan, ordered by dependency,
each phase independently verifiable, with gates, risks and an explicit out-of-scope list.
Does NOT: write implementation code (→ `software-development`); invent requirements for a vague
ask; plan speculative future work (YAGNI → out of scope).

## Steps (TodoWrite items; the plan file is the checkpoint)
1. **Ground it.** Read the spec and the code it touches (name the files you read or would read).
   Restate the goal and observable success criteria in 1–2 sentences.
   - **Plan now** when you can name the feature's core behaviour and where it lives ("rate-limit
     POST /login", "password reset by email", "a URL shortener"), even if details are open:
     record the open details as assumptions/questions in the plan.
   - ⛔ **STOP and ask** only when you can't even name the behaviour ("plan out the new
     dashboard": which data, for whom, what done means). Don't invent a plan from nothing.
   - Extras the user adds "for the future" (analytics, teams, billing…) → plan today's core,
     list the extras under Out of scope (YAGNI) with one line on how the design leaves room.
2. **Phases:** small, ordered by dependency, the smallest slice with real behaviour first; one
   you can't verify in a sitting is too big.
3. **Tasks:** each with what, where (file/seam), and Verify (a test to write/run or a behaviour
   to observe — "it works" isn't one). E.g. "In `handlers/user.py` return 400 on missing email;
   Verify: a test posting `{}` asserts 400".
4. **Gates, risks, scope:** a gate between phases (what to run/show, what it unblocks; always
   before migrations, deletes, outward-facing changes); risks with mitigations (data loss,
   breaking callers, races, abuse/false positives); assumptions; **Out of scope (YAGNI)**; open
   questions.
5. **Write** `docs/plans/YYYY-MM-DD-<topic>-plan.md` (incrementally; it's the checkpoint) and
   hand off to `software-development`.

## Format
```markdown
# <topic> plan
Goal: … · Success: … · Context: spec link, key files, constraints
### Phase 1 — <smallest slice with real behaviour>
- [ ] <what> in `<file>` — Verify: <test/behaviour>
Gate: <what to check before Phase 2>
## Risks · Assumptions · Out of scope (YAGNI) · Open questions
```

## Red flags
| If you notice… | Do this |
|---|---|
| A task without what/where/verify ("improve X") | Make it concrete with a Verify |
| A giant phase | Split it |
| Planning without reading the code | Read it first |
| Future-proofing in the phases | Move it to Out of scope |
| Stopping to ask when the core behaviour is clear | Plan; put the open details in Assumptions/Questions |
| Planning a request you can't even name | STOP and ask |
| Writing implementation code | Stop: `software-development` builds |

## Done when
Phases are ordered and independently verifiable; every task has what, where, verify; risks,
assumptions, out-of-scope and questions are listed; the plan is in `docs/plans/`.
