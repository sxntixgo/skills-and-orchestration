---
name: software-development
description: Builds a backend or frontend feature end-to-end with a test-driven loop and DRY/YAGNI/KISS discipline. Use when implementing a feature, endpoint, component, or bugfix, or when asked to write/change production code.
---

# Software Development

Build the smallest correct slice, test-first, then keep it simple. Follow the
five stages in order; each is a checkpoint you can resume from.

## Scope
This skill DOES:
- Take a feature/bugfix from understanding → plan → TDD implementation →
  refactor → verify it runs.
- Apply DRY, YAGNI, KISS at the refactor step.
- Use the TDD red→green→refactor loop (this skill owns the loop).

This skill does NOT:
- Enumerate or author the actual test cases → delegate that to `writing-tests`.
- Add features nobody asked for (YAGNI) or design for hypothetical futures.
- Skip running the code — "compiles" is not "works" (that's `verify`/`run`).

## Workflow

Create a TodoWrite item per stage. Checkpoint each stage to
`./.claude-skills-work/software-development/<task>/` (plan, decisions, progress)
so work resumes if interrupted.

### Stage 1 — Understand  ⛔ STOP if unclear
Restate the task in one or two sentences: inputs, outputs, and the observable
behavior that means "done". List unknowns. If a requirement is ambiguous or
you'd be guessing at intent, STOP and ask — do not invent requirements (YAGNI).

### Stage 2 — Plan the smallest slice
Pick the smallest end-to-end slice that delivers real behavior. Identify the one
or few files to touch and the seams. Write the plan to the checkpoint file.
Prefer extending existing patterns in the codebase over introducing new ones.
For stack-specific guidance read `references/backend.md` or
`references/frontend.md` now.

### Stage 3 — TDD loop (red → green → refactor)
Repeat per behavior in the slice:
1. **Red** — write a failing test for the next behavior. For WHICH cases to
   write (happy path, edges, boundaries, error paths), use `writing-tests`.
   Run it; confirm it fails for the right reason.
2. **Green** — write the simplest code that makes it pass. No extra
   abstraction, no speculative options (KISS, YAGNI).
3. **Refactor** — with tests green, clean up (see Stage 4 principles). Rerun
   tests. Commit-sized, behavior-preserving.

### Stage 4 — Refactor for DRY / YAGNI / KISS
Apply after green, never at the cost of a failing test:
- **DRY** — remove real duplication of *knowledge*. Don't over-DRY: two things
  that look alike but change for different reasons should stay separate.
- **YAGNI** — delete anything not needed by a current requirement (unused
  params, config, hooks, "just in case" branches).
- **KISS** — prefer the simplest thing that works; fewer moving parts, clear
  names, shallow nesting. If a reviewer would ask "why so complex?", simplify.

### Stage 5 — Verify it runs
Run the tests AND exercise the actual behavior (invoke the endpoint, render the
component, run the CLI) — not just a typecheck. If a project `verify`/`run`
skill exists, use it. Report what you ran and what you observed.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Writing code before a failing test | Stop; write the test first (Stage 3) |
| Building for a future requirement | Delete it — YAGNI; add it when needed |
| A clever/complex solution | Prefer the simplest that passes (KISS) |
| Copy-pasting logic a third time | Extract the shared knowledge (DRY) |
| DRY-ing two things that just look alike | Leave them separate — coincidental duplication |
| Guessing an ambiguous requirement | STOP and ask |
| "It compiles / types pass, so it works" | Actually run it (Stage 5) |

## Done when
- The slice's behavior is covered by tests written test-first, and they pass.
- Code satisfies DRY/YAGNI/KISS (no speculative or duplicated logic).
- You ran the real behavior and observed it working.

## References (load only when needed)
- `references/backend.md` — backend concerns (APIs, data, errors, security seams).
- `references/frontend.md` — frontend concerns (state, components, a11y, UX).
