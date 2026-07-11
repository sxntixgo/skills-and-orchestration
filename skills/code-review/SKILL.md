---
name: code-review
description: Reviews a diff or file for correctness, readability, maintainability, and consistency with project patterns, giving actionable feedback with line references. Use when reviewing code, a diff, or a PR, or before merging a change.
---

# Code Review

Review for correctness and quality. Report findings with `file:line` and a fix,
rated: 🔴 Must fix · 🟡 Should fix · 🟢 Consider · ✅ Good (call out real
strengths too). This is a quality review, not a security audit.

## Scope
This skill DOES:
- Review correctness, readability, maintainability, simplicity, and consistency
  with the codebase's existing patterns.
- Give specific, actionable feedback anchored to lines, each with a concrete fix.

This skill does NOT:
- Rewrite the code for the author — suggest; the author decides.
- Perform a security audit (vuln classes, authz, secrets) — out of scope here.
- Nitpick style a formatter/linter already enforces.

## Steps
Surface as TodoWrite items. Checkpoint findings to
`./.claude-skills-work/code-review/<target>/findings.md` as you go.

1. **Get the diff/context.** Read the change and enough surrounding code to
   judge it. Note the change's intent and the patterns already used nearby.
2. **Review each dimension** (see `references/checklist.md` for detail):
   correctness, naming/readability, function/complexity, error handling,
   duplication & simplicity, consistency, and test adequacy.
3. **Rate and locate.** For each finding: severity, `file:line`, the problem,
   and a concrete fix. Prioritize correctness over style.
4. **Report** in the output format below, most severe first.

## Review dimensions (quick reference)
- **Correctness** — does it do what it claims? Edge cases, off-by-one, null/empty
  inputs, error paths, concurrency, resource cleanup. Highest priority.
- **Naming & readability** — intent-revealing names; avoid `data`/`tmp`/`handle`;
  code reads top-to-bottom without puzzle-solving.
- **Function & complexity** — small focused units; shallow nesting; guard
  clauses over deep `if` trees.
- **Error handling** — no silent swallow; failures surface with useful context;
  the unhappy path is handled.
- **Duplication & simplicity** — no copy-paste of real logic (DRY); no
  speculative generality (YAGNI); simplest thing that works (KISS).
- **Consistency** — matches existing project idioms, structure, conventions.
- **Tests** — do tests cover the new/changed behavior, including edges? (Assess
  adequacy; authoring cases is a separate concern.)

## Output format
```markdown
## Code Review: <target>

### 🔴 Must fix
1. **<issue>** (path:line) — <problem> → <fix>

### 🟡 Should fix
1. **<issue>** (path:line) — <problem> → <fix>

### 🟢 Consider
1. **<suggestion>** (path:line)

### ✅ Good
- <genuine strength worth keeping>
```

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Reviewing without reading surrounding context | Read enough to judge before commenting |
| Vague feedback ("could be cleaner") | Name the problem and give a concrete fix |
| Findings with no line reference | Anchor every finding to `file:line` |
| Bikeshedding formatter/lint style | Skip it; focus on correctness and design |
| Only listing negatives | Note real strengths in ✅ Good too |
| Rewriting the whole change yourself | Suggest; the author owns the code |

## Done when
- Each finding has a severity, a `file:line`, and a concrete fix.
- Findings are ordered most-severe-first, correctness prioritized.
- Report follows the output format.

## References (load only when needed)
- `references/checklist.md` — per-dimension checks with good/bad examples.
