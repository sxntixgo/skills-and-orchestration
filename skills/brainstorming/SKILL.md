---
name: brainstorming
description: Turns a vague idea into a validated design through dialogue — clarifies intent one question at a time, explores 2-3 approaches with trade-offs, and validates the design in sections before implementation. Use before building a feature, component, or system when the requirements or approach aren't nailed down yet.
---

# Brainstorming

Design before building. Draw the requirements out of the user through dialogue,
explore alternatives, and validate the design incrementally — don't jump to a
solution or start coding.

## Scope
This skill DOES:
- Understand the idea, clarify intent one question at a time, explore approaches
  with trade-offs, and validate the design in small sections.

This skill does NOT:
- Write implementation code or a task breakdown → hand off to `writing-plans`
  (to phase it) and `software-development` (to build it).
- Barrel ahead once it knows "enough" without validating with the user.
- Add features nobody asked for → keep the design minimal (YAGNI).

## Steps
Surface these as TodoWrite items. Checkpoint the evolving design to
`./.claude-skills-work/brainstorming/<topic>/design.md` so a long session resumes.

### 1. Understand the context
Read the current project state (files, docs, recent commits) before asking
anything. Restate the idea in your own words so the user can correct you.

### 2. Clarify intent — one question at a time  ⛔
Ask ONE question per turn (multiple-choice when you can — it's easier to answer).
Cover purpose, constraints, success criteria, and scope. Keep going until you can
state plainly what's being built and what "done/good" means. Prefer stop-and-ask
over assuming. See `references/questioning.md`.

### 3. Explore approaches
Propose 2–3 distinct approaches with concrete trade-offs. Lead with your
recommendation and *why*; let the user choose. Don't present a single option as
if it's the only one.

### 4. Present the design in sections
Present the design in small sections (~200–300 words each): architecture,
components, data flow, error handling, testing. After each, ask "does this look
right?" and adjust before continuing. Go back if something doesn't fit.

### 5. Write it down and hand off
Write the validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`. Point
the user to `writing-plans` to turn it into a phased implementation plan.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Asking several questions at once | One question per turn |
| Jumping to a design/solution before intent is clear | Clarify intent first (step 2) |
| Dumping a whole design wall | Present in sections; validate each |
| Offering only one option | Propose 2–3 approaches with trade-offs |
| Starting to write implementation code | Stop — design here; `software-development` builds |
| Designing for hypothetical futures | Keep it minimal (YAGNI); design the real need |
| Accepting a vague "make it good" | Pin down concrete success criteria |

## Done when
- You can state what's being built, its constraints, and its success criteria.
- The user chose among explored alternatives, and the design was validated
  section by section.
- The design is written to `docs/plans/` and handed off to `writing-plans`.

## References (load only when needed)
- `references/questioning.md` — asking good one-at-a-time questions
  (multiple-choice vs open, when to stop) and framing approach trade-offs.
