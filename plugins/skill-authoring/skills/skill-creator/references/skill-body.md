# Writing the SKILL.md body (Stage 3)

Write instructions TO Claude, not prose about the topic. Prefer checklists,
tables, and short examples over paragraphs. Every line costs tokens on every
turn the skill is active, so keep it lean and push detail into `references/`.

## Standard body sections

```markdown
# <Title>

<1–2 line statement of what to do and the core stance.>

## Scope
This skill DOES: …
This skill does NOT: …          <!-- the "does NOT" line prevents scope creep -->

## Steps / Workflow
1. …                            <!-- surface these as TodoWrite items -->
   (mark STOP gates where Claude must pause for the user)

## Checkpoints
Write intermediate output to ./.claude-skills-work/<name>/ at each step.

## Red flags (stop and correct)
| If you notice… | Do this |

## Done when
- observable success criteria

## References (load only when needed)
- references/<file>.md — <when to read it>
```

Not every skill needs every section, but Scope, Steps, Red flags, and Done-when
are the guardrail backbone — include them unless there's a clear reason not to.

## The 8-rule checklist (from CLAUDE.md)

Verify the finished skill against every rule:

1. **Frontmatter** — `name` (kebab-case == dir) + a concrete `description`.
2. **Self-contained** — no dependency outside this plugin; cross-references to
   sibling skills go through the trigger description, not a hard "invoke X".
3. **Progressive disclosure** — SKILL.md < ~500 lines; detail in `references/`.
4. **Token-frugal** — runnable in one context window; no mandated subagents
   (except dev-time evals).
5. **Imperative & concrete** — instructions, checklists, tables, examples.
6. **Checkpointed / resumable** — writes intermediate output to disk each step
   and says where, so work resumes.
7. **Guardrails** — explicit scope, TodoWrite step checklist, STOP gates, and a
   red-flags list; stop-and-ask over guessing.
8. **Eval-backed** — ships `evals/evals.json`; validated by baseline comparison.

## Reasoning beats rigidity
Instructions that explain WHY ("do X because Y causes Z") are followed more
reliably than bare "ALWAYS do X / NEVER do Y". Reserve hard MUST/NEVER language
for real invariants (safety, correctness gates), not stylistic preferences.
