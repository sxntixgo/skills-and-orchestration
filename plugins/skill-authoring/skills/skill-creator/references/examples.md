# Examples: one strong skill, one weak (calibration)

Use these to calibrate. The difference is almost always: a concrete trigger,
explicit scope, and guardrails vs. vague prose.

## Strong

```markdown
---
name: writing-tests
description: Designs and writes test cases for a change — happy path, edge and boundary cases, error paths. Use when adding tests, or before implementing a feature or bugfix (TDD).
---

# Writing Tests

## Scope
This skill DOES: enumerate cases (happy/edge/error), then write them in the
project's test framework.
This skill does NOT: refactor production code, or fix failing tests it didn't
write — report those instead.

## Steps
1. Read the change/spec; list behaviors to cover (surface as TodoWrite items).
2. For each behavior, enumerate happy path, boundaries, and error paths.
3. Write the tests; run them; confirm they fail for the right reason first (TDD).

## Red flags (stop and correct)
| If you notice… | Do this |
| Testing implementation details, not behavior | Test observable behavior |
| Only the happy path | Add boundary + error cases before finishing |

## Done when
- Every listed behavior has a test; the suite runs; TDD order was followed.
```

**Why it's strong:** trigger names real situations (adding tests, before a
feature, TDD); scope's "does NOT" blocks creep; steps are imperative and become
todos; red-flags catch the usual drift; success is observable.

## Weak

```markdown
---
name: tests
description: Helps with testing.
---

# Tests

Testing is important. This skill helps you write good tests that cover your
code. It follows best practices and makes sure quality is high. Write tests
for the important parts and try to cover edge cases when you can.
```

**Why it's weak:**
- Description has no trigger — Claude can't tell when to load it, and it collides
  with any other testing skill.
- Body is prose *about* testing, not instructions Claude can act on.
- No scope, no steps, no guardrails, no success criteria — nothing stops drift
  and nothing says when it's done.
- No `evals/evals.json`, so there's no way to prove it helps.

## The fix pattern
Turn every weak skill into a strong one by adding: a concrete `Use when`
trigger, a Scope block with a "does NOT" line, numbered imperative Steps, a
Red-flags table, a Done-when list, and 3–5 eval cases.
