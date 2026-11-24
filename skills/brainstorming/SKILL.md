---
name: brainstorming
description: Turns a vague idea into a validated design through dialogue — clarifies intent one question at a time, explores 2-3 approaches with trade-offs, and validates the design in sections before implementation. Use when about to build a feature, component, or system whose requirements or approach aren't nailed down yet.
---

# Brainstorming

Design before building: draw the requirements out through dialogue, compare real alternatives,
validate the design in pieces. No code, no task breakdown.

## Scope
DOES: understand the idea, clarify intent one question at a time, explore approaches with
trade-offs, validate the design in sections, write it to `docs/plans/`.
Does NOT: write code or a task plan (→ `writing-plans`, then `software-development`); push on
without the user's agreement; add features nobody asked for (YAGNI).

## Steps (TodoWrite items; work-in-progress design in `./.claude-skills-work/brainstorming/<topic>/design.md`)
1. **Context.** Read the project state (files, docs, recent commits) first.
2. **Every reply until intent is clear** has three parts, in this order:
   - **Restate** the idea in a sentence, with your assumptions ("I'm assuming X"), and what is
     still unknown about purpose and success criteria (they come before any solution).
   - **Candidate approaches (2–3, genuinely different)**, one line each with a trade-off tied to
     THIS context (cost, complexity, risk, reversibility, fit with what exists), and your
     **current recommendation + why** ("I'd lean to A because …, unless …"). Include the simplest
     option that meets today's need; for "make it handle anything in the future" requests, say
     what's needed now and why the general version can wait.
   - **ONE question**, the one whose answer decides between them, multiple-choice when you can
     ("(a) … (b) … (c) …"). Cover over the turns: purpose (what problem, for whom), success
     criteria (pin "fast" → "p95 < 200 ms?"), constraints (stack, deadlines, must-nots), scope
     (in and out). Never a batch of questions.
   Stop asking once you can state what's built, its constraints and success criteria without
   guessing; more questions is stalling.
3. **Choose.** The user picks (or confirms your recommendation).
4. **Design in sections** (~200–300 words: architecture → components → data flow → errors →
   testing); end each with "does this look right?" and wait; revise on pushback.
5. **Write** the validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`; hand off to
   `writing-plans`.

## Red flags
| If you notice… | Do this |
|---|---|
| Several questions at once | One per turn |
| A full design before intent is clear | Restate + candidates + one question |
| Approaches promised "later", or no recommendation | Show 2–3 now, with trade-offs and a lean |
| Only one option | 2–3 real alternatives, the simplest included |
| A design wall | Sections, validated one by one |
| Writing implementation code | Stop: `software-development` builds |
| Designing for hypothetical futures | Design today's need (YAGNI) |
| "Make it good" accepted as a criterion | Pin concrete success criteria |

## Done when
What's built, its constraints and success criteria are stated; the user chose among explored
alternatives; the design was validated section by section, written to `docs/plans/` and handed
to `writing-plans`.
