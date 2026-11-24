---
name: code-review
description: Reviews a diff or file for correctness, readability, maintainability, and consistency with project patterns, giving actionable feedback with line references. Use when reviewing code, a diff, or a PR, or before merging a change.
---

# Code Review

A complete, uniformly rated review: every dimension checked, every finding anchored to
`file:line` with a concrete fix. Ratings: 🔴 Must fix · 🟡 Should fix · 🟢 Consider · ✅ Good.
Quality review, not a security audit (→ `security-review`).

## Scope
DOES: review correctness, readability, complexity, error handling, duplication, consistency and
test adequacy; give actionable, line-anchored fixes.
Does NOT: rewrite the code (suggest; the author decides); audit security; nitpick what a
formatter/linter enforces.

## Steps (TodoWrite items; findings in `./.claude-skills-work/code-review/<target>/findings.md`)
1. **Context:** read the change and enough surrounding code (callers, nearby patterns) to judge
   it; note its intent.
2. **Check every dimension:**
   - **Correctness** (first): does it do what it claims? Inputs at and past their valid range
     (empty, null, zero, negative, one, max, > 1 for ratios), off-by-one, error paths,
     concurrency/check-then-act, resource cleanup, return types vs callers.
   - **Readability:** intent-revealing names (flag `data`, `tmp`, `handle`, `process`),
     predicates for booleans, comments say why, no commented-out code.
   - **Complexity:** one job per function; guard clauses over deep nesting.
   - **Errors:** no empty/catch-all swallow; messages with context (ids, not secrets).
   - **Duplication & simplicity:** DRY for knowledge in 3+ places (not look-alikes); YAGNI
     (unused params, one-caller abstractions); KISS.
   - **Consistency** with the module's structure, naming, error format, idioms.
   - **Tests:** changed behaviour covered, including one edge and one error case; behaviour,
     not implementation; no real time/network/order dependence.
3. **Rate and order.** Within a severity, order by impact: silently wrong results or corrupted
   data for plausible inputs first (e.g. a discount > 1 making totals negative), then crashes,
   then design, naming, style. A pile of 🟢 never buries a 🔴. Every finding gets a fix, also
   ones outside this review's scope (a suspected injection: "parameterize the query; run
   `security-review`").
4. **Report** in this format, most severe first:
```markdown
## Code Review: <target>
### 🔴 Must fix
1. **<issue>** (path:line) — <problem> → <fix>
### 🟡 Should fix
### 🟢 Consider
### ✅ Good
- <real strength>
```

## Red flags
| If you notice… | Do this |
|---|---|
| Commenting without reading the context | Read callers and nearby code first |
| Vague feedback ("could be cleaner") | Name the problem and a concrete fix |
| A finding without `file:line` | Anchor it |
| Lint-level style nits | Skip them |
| Only negatives | Add real strengths under ✅ |
| Rewriting the change | Suggest; the author owns it |

## Done when
Every finding has severity, `file:line` and a fix; ordered by severity then impact; the report
follows the format.
