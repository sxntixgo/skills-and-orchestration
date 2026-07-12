---
name: security-review
description: Reviews code for security vulnerabilities — injection, broken auth/authz, secrets exposure, crypto misuse, SSRF, deserialization, and more — with an exploit scenario and fix per finding. Use when a change touches auth, input handling, data access, file/network I/O, secrets, or before shipping security-sensitive code.
---

# Security Review

Find vulnerabilities and explain how they're exploited. Think like an attacker:
trust nothing from outside the trust boundary. Report each finding with a
severity, location, a concrete exploit scenario, and a remediation.

Severity: 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low (rate by exploitability ×
impact).

## Where this skill adds value
Be honest about what this buys you. On a strong model, this skill does **not**
find *more* bugs than an unaided review — evals showed no detection lift. Its
value is **consistency and coverage**: it works through the *full* vuln-class
checklist so nothing is skipped, rates every finding on one severity scale, and
always emits the exploit→impact→fix structure. That reliability matters most for
a team standard, a review of record, a large/real codebase, or a weaker model.
So: don't just report the one obvious bug — deliver a *complete, uniformly
rated, well-structured* pass.

## Scope
This skill DOES:
- Review for the vulnerability classes in `references/vuln-classes.md`.
- For each finding: exploit scenario, impact, and a specific fix.

This skill does NOT:
- Do general quality/readability review (that's a separate concern).
- Exploit live systems or write working exploit payloads — describe the attack,
  don't weaponize it.
- Silently "fix" code — report findings; the author remediates.

## Steps
Surface as TodoWrite items. Checkpoint findings to
`./.claude-skills-work/security-review/<target>/findings.md` as you go.

1. **Map the attack surface.** Identify every point where untrusted data or an
   attacker interacts with the change: request inputs, params, headers, file
   uploads, external API responses, deserialized data, auth boundaries, and
   anything touching secrets or sensitive data.
2. **Trace the data.** Follow untrusted input from entry (source) to dangerous
   operation (sink): query, shell, filesystem, HTTP call, HTML, deserializer.
   An unsanitized source-to-sink path is a finding.
3. **Check each relevant vuln class** against the surface, using
   `references/vuln-classes.md`.
4. **Verify the controls, don't assume them.** Confirm authz on THIS resource,
   parameterized queries, output encoding, secret handling — don't assume the
   framework does it.
5. **Report**, most severe first, in the output format below.

## High-value checks (see vuln-classes.md for the full set)
- **Injection** — SQL/NoSQL/command/LDAP: untrusted input reaching a query or
  shell without parameterization/escaping.
- **AuthN/AuthZ** — missing auth on a route; missing per-resource authorization
  (IDOR); privilege escalation; trusting client-supplied identity/role.
- **Secrets** — hardcoded keys/passwords/tokens; secrets in logs, errors, URLs,
  or client code.
- **Sensitive data** — PII/credentials logged, returned, or stored unencrypted;
  weak/rolled-your-own crypto; predictable tokens.
- **SSRF / injection of URLs** — user-controlled URLs fetched server-side.
- **Deserialization / path traversal / file upload** — untrusted data driving
  object construction, file paths, or executable content.
- **XSS / output encoding** — untrusted data rendered without encoding.
- **Config & transport** — debug on in prod, permissive CORS, missing TLS,
  missing rate limits on public endpoints.

## Output format
```markdown
## Security Review: <target>

### 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low
1. **<vuln class>** (path:line)
   - Exploit: <how an attacker abuses this, concretely>
   - Impact: <what they gain>
   - Fix: <specific remediation>

### ✅ Controls verified
- <control you checked and confirmed present>
```

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| "The framework probably sanitizes this" | Verify it; don't assume a control exists |
| Auth present, but not checked per-resource | Confirm this user may touch THIS object (IDOR) |
| Reporting a vuln with no exploit path | Show the concrete source→sink; else it's noise |
| Writing a working exploit/payload | Describe the attack; don't weaponize |
| Only checking the classic OWASP list | Also check secrets, logging, SSRF, deserialization |
| Trusting client-supplied role/id/price | Treat all client input as attacker-controlled |

## Done when
- The attack surface of the change is mapped.
- Each finding has severity, `file:line`, an exploit scenario, impact, and a fix.
- Controls you verified are noted; findings ordered most-severe-first.

## References (load only when needed)
- `references/vuln-classes.md` — vulnerability classes with what to look for,
  an exploit sketch, and the fix for each.
