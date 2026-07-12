# Asking questions and framing approaches

## One question at a time
Asking five questions at once overwhelms the user and produces shallow answers.
Ask ONE, use the answer to inform the next. The conversation should feel like a
dialogue, not a form.

- **Prefer multiple-choice** when the space is known — it's far easier to answer
  than an open prompt, and it surfaces options the user hadn't considered.
  ("For auth, do you want: (a) email+password, (b) OAuth only, (c) both?")
- **Open-ended** when you need their world in their words ("What problem does
  this solve for the user?"). Use sparingly.
- **Lead with your guess** when you have one: "I'm assuming X — correct?" is
  faster than an open question and still lets them redirect.

## What to draw out (roughly in order)
1. **Purpose** — what problem, for whom, why now.
2. **Success criteria** — how you'll both know it's done and good. Pin down
   vague answers ("fast" → "p95 under 200ms?", "simple" → "one screen, no config?").
3. **Constraints** — stack, existing patterns, deadlines, must-nots.
4. **Scope** — what's explicitly in, and (just as important) out.

Stop asking when you can restate what's being built, its constraints, and its
success criteria without guessing. More questions past that point is stalling.

## Exploring approaches
Once intent is clear, put 2–3 real options on the table — not a single design
presented as inevitable.

- Make them genuinely different (not three flavors of the same thing).
- Give each a concrete trade-off tied to THIS context: cost, complexity, time,
  risk, reversibility, fit with existing patterns.
- **Lead with a recommendation and the reason** — "I'd go with B because your
  main constraint is X." Then let the user decide; don't just dump options.

| Weak | Better |
|------|--------|
| "We could use a queue." | "Option A: in-process — simplest, but lost on restart. Option B: Redis queue — durable, one more service. I'd start with A since volume is low; revisit if it grows." |

## Validating the design in sections
Present the design in small pieces and check each before moving on:
- ~200–300 words per section (architecture → components → data flow → errors →
  testing). A wall of text hides disagreement.
- End each section with "does this look right so far?" and actually wait.
- When the user pushes back, go back and revise — don't defend the first draft.
- Incremental agreement beats a big reveal at the end that unravels.
