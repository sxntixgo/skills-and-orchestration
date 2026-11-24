---
name: code-review
description: Reviews a diff or file for correctness, security, readability, maintainability, and consistency with project patterns, giving actionable feedback with line references (and an exploit scenario for each vulnerability). Use when reviewing code, a diff, or a PR, before merging a change, or when a change touches auth, input handling, data access, file/network I/O or secrets.
---

# Code Review

A complete, uniformly rated review: every dimension checked, every finding anchored to
`file:line` with a concrete fix. Ratings: 🔴 Must fix · 🟡 Should fix · 🟢 Consider · ✅ Good.
Security findings also get an exploit scenario.

## Scope
DOES: review correctness, security, readability, complexity, error handling, duplication,
consistency and test adequacy; give actionable, line-anchored fixes.
Does NOT: rewrite the code (suggest; the author decides); nitpick what a formatter/linter
enforces; exploit live systems or write working payloads (describe the attack).

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
   - **Security** (whenever the code takes outside input or touches auth, data, files, network,
     secrets): trace each untrusted source (params, body, headers, uploads, API responses, and
     values read back from the DB) to its sinks. Check: injection incl. second-order
     (parameterize); JWT decoded without signature check, non-constant-time secret compare,
     missing rate limit; missing per-resource authz (IDOR), client-supplied role/price,
     mass assignment (allowlist fields); hardcoded/logged secrets; weak hashing or
     `Math.random` tokens; SSRF; unsafe deserialization; path traversal (canonicalize, confine
     to base dir); XSS; open redirect; CSRF; debug/CORS config. Verify controls, don't assume
     the framework does it.
3. **Rate and order.** Within a severity, order by impact: silently wrong results or corrupted
   data for plausible inputs first (e.g. a discount > 1 making totals negative), then crashes,
   then design, naming, style. A pile of 🟢 never buries a 🔴. Exploitable vulnerabilities
   (auth bypass, injection, RCE, traversal) are 🔴. Every finding gets a fix.
4. **Report** in this format, most severe first:
```markdown
## Code Review: <target>
### 🔴 Must fix
1. **<issue>** (path:line) — <problem> → <fix>
2. **<vuln class>** (path:line) — Exploit: <concrete source → sink abuse> · Impact: <gain> → <fix>
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
| "The framework probably sanitizes this" / "it comes from our DB" | Verify; stored input is untrusted |
| A vulnerability without an exploit path | Show source → sink, or drop it |
| Stopping at the first bug | Finish every dimension |

## Done when
Every finding has severity, `file:line` and a fix (vulnerabilities also exploit + impact); ordered by severity then impact; the report
follows the format.
