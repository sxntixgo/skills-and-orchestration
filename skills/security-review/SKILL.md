---
name: security-review
description: Reviews code for security vulnerabilities — injection, broken auth/authz, secrets exposure, crypto misuse, SSRF, deserialization, and more — with an exploit scenario and fix per finding. Use when a change touches auth, input handling, data access, file/network I/O, secrets, or before shipping security-sensitive code.
---

# Security Review

Think like an attacker: nothing from outside the trust boundary is trusted. A complete pass over
every class below (not just the first bug), each finding with severity, `file:line`, exploit,
impact and fix. Severity = exploitability × impact: 🔴 Critical (RCE, auth bypass, injection
into a dangerous sink) · 🟠 High · 🟡 Medium · 🟢 Low.

## Scope
DOES: map the attack surface, trace untrusted data to sinks, check every class, report.
Does NOT: general quality review (→ `code-review`); exploit live systems or write working
payloads (describe the attack); fix the code (the author does).

## Steps (TodoWrite items; findings in `./.claude-skills-work/security-review/<target>/findings.md`)
1. **Attack surface:** request params, body, headers, cookies, uploads, external API
   responses, values read back from the DB or files (stored input is still untrusted), auth
   boundaries, secrets.
2. **Trace** each untrusted source to its sinks: query, shell, filesystem, outbound HTTP, HTML,
   deserializer, redirect, comparison of secrets. An unsanitized path = a finding.
3. **Check every class:**
   | Class | Look for | Fix |
   |---|---|---|
   | Injection (SQL/NoSQL/command/template), incl. second-order | input or DB-sourced values concatenated into a query/shell/eval | parameterize; args as a list; no eval |
   | Authentication | JWT decoded without signature verification, `alg:none`; non-constant-time secret compare (`===`); no rate limit/lockout; predictable or long-lived tokens | verify signature + expiry before trusting claims; `timingSafeEqual`/`hmac.compare_digest`; rate-limit |
   | Authorization | no per-resource check (IDOR); role/price/id from the client; **mass assignment** (whole body bound to a model: `role`, `isVerified`) | check principal × resource; allowlist writable fields |
   | Secrets | hardcoded keys; secrets in logs, errors, URLs, client bundles | env/secret manager; redact; rotate |
   | Data & crypto | PII logged/returned; MD5/SHA1/unsalted passwords; ECB, static IV, homegrown crypto; `Math.random` tokens | bcrypt/argon2; vetted AEAD; CSPRNG |
   | SSRF | server fetches a user-controlled URL | allowlist; block private/link-local IPs (169.254.169.254); no redirects inward |
   | Deserialization | pickle, Java serialization, YAML `load`, `unserialize` on untrusted bytes | JSON + schema; `safe_load` |
   | Path traversal & upload | user input in a path (`../../etc/passwd`); uploads unvalidated or in webroot | canonicalize, confine to base dir, reject `..`/absolute; server-side names |
   | XSS | untrusted data into HTML/JS (`innerHTML`, `dangerouslySetInnerHTML`) | context-aware encoding; auto-escaping; CSP |
   | Open redirect | `redirect(req.query.next)` unvalidated | allowlist or same-origin relative paths only |
   | CSRF | state change authorized by ambient cookie alone | anti-CSRF token; `SameSite`; custom header |
   | Config | debug/stack traces in prod; `*` CORS with credentials; no TLS/HSTS; no rate limits; vulnerable deps | harden; least-privilege CORS; patch |
4. **Verify controls** rather than assuming the framework does it; list the ones confirmed.
5. **Report**, most severe first:
```markdown
## Security Review: <target>
### 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low
1. **<class>** (path:line)
   - Exploit: <concrete source → sink abuse, e.g. "?file=../../etc/passwd">
   - Impact: <what the attacker gains>
   - Fix: <specific remediation>
### ✅ Controls verified
- <control checked and present>
```

## Red flags
| If you notice… | Do this |
|---|---|
| "The framework probably sanitizes this" | Verify it |
| "Safe, it comes from our DB" | Stored input is untrusted (second-order) |
| Auth present but not per-resource | Check IDOR |
| A finding with no exploit path | Show source → sink, or drop it |
| Stopping after the first bug | Finish every class |
| Writing a working payload | Describe; don't weaponize |
| Trusting client role/id/price | Attacker-controlled |

## Done when
Attack surface mapped; every class checked; each finding has severity, `file:line`, exploit,
impact, fix; verified controls listed; most severe first.
