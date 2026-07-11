# Vulnerability classes

For each: what to look for (source→sink), a quick exploit sketch, and the fix.
Framework-agnostic; map to the language in front of you.

## Injection (SQL / NoSQL / command / LDAP / template)
- **Look for**: untrusted input concatenated into a query, shell command, eval,
  or template. `"... WHERE id=" + req.id`, `exec("ping " + host)`.
- **Exploit**: attacker sends `1 OR 1=1` / `; rm -rf` / `${7*7}` to read/alter
  data or run commands.
- **Fix**: parameterized queries / prepared statements; pass args as a list, not
  a shell string; never `eval` untrusted data; use a sandboxed template mode.

## Broken authentication
- **Look for**: weak/missing session checks, credentials compared non-constant-
  time, no lockout/rate-limit on login, JWT with `alg:none` or unverified
  signature, long-lived or predictable tokens.
- **Exploit**: brute force, token forgery, session fixation.
- **Fix**: vetted auth library; verify signatures and expiry; rate-limit and
  lock out; rotate and scope tokens; constant-time comparison.

## Broken authorization (IDOR / privilege escalation)
- **Look for**: a route that authenticates but doesn't check the caller may act
  on THIS resource: `GET /orders/:id` returning any id; role/permission taken
  from the client; admin action missing an admin check.
- **Exploit**: change `:id` or a hidden field to access/modify another user's
  data or gain admin.
- **Fix**: authorize every access against the authenticated principal AND the
  specific object; derive identity/role server-side, never from client input.

## Secrets management
- **Look for**: hardcoded API keys, passwords, tokens, private keys; secrets in
  source, logs, error messages, URLs (query strings), or client bundles.
- **Exploit**: anyone with repo/log/network access reuses the secret.
- **Fix**: load from env/secret manager; keep out of logs and responses; rotate
  leaked secrets; never ship secrets to the client.

## Sensitive data exposure & crypto misuse
- **Look for**: PII/credentials logged or returned; plaintext or weak hashing
  (MD5/SHA1, unsalted); passwords not hashed with bcrypt/argon2/scrypt; ECB
  mode; static IVs; homegrown crypto; predictable randomness (`Math.random`,
  `rand()`) for tokens.
- **Exploit**: data theft on breach; token prediction; cipher weaknesses.
- **Fix**: TLS in transit; encrypt sensitive data at rest; slow salted password
  hashes; a vetted crypto library with authenticated encryption; a CSPRNG for
  tokens; minimize and redact sensitive data in logs.

## SSRF (server-side request forgery)
- **Look for**: server fetches a user-controlled URL/host (webhooks, image
  proxies, "import from URL").
- **Exploit**: attacker points it at `169.254.169.254` (cloud metadata) or
  internal services to steal credentials or reach the intranet.
- **Fix**: allowlist destinations; resolve and validate the IP (block private/
  link-local ranges); disable redirects to internal hosts; isolate egress.

## Insecure deserialization
- **Look for**: untrusted bytes fed to a native/object deserializer (pickle,
  Java serialization, YAML `load`, PHP `unserialize`).
- **Exploit**: crafted payload triggers remote code execution on deserialize.
- **Fix**: don't deserialize untrusted data with object-constructing
  deserializers; use data-only formats (JSON) with schema validation; YAML
  `safe_load`.

## Path traversal & file upload
- **Look for**: user input used in a filesystem path (`../../etc/passwd`);
  uploads without type/size limits or stored in a web-executable dir.
- **Exploit**: read/write arbitrary files; upload a web shell and execute it.
- **Fix**: canonicalize and confine paths to a base dir; generate server-side
  filenames; validate content type and size; store outside webroot; never
  execute uploads.

## XSS & output encoding
- **Look for**: untrusted data rendered into HTML/JS/attributes without
  encoding; `innerHTML`, `dangerouslySetInnerHTML`, unescaped templates.
- **Exploit**: injected `<script>` runs in victims' browsers, stealing sessions.
- **Fix**: context-aware output encoding; prefer text nodes / auto-escaping
  templates; a strict Content-Security-Policy; sanitize any allowed HTML.

## CSRF
- **Look for**: state-changing requests authenticated only by an ambient cookie,
  no anti-CSRF token or SameSite protection.
- **Exploit**: a malicious page submits a request as the logged-in victim.
- **Fix**: anti-CSRF tokens; `SameSite` cookies; require a custom header for
  state-changing APIs.

## Security misconfiguration & transport
- **Look for**: debug/stack traces in prod, default creds, overly permissive
  CORS (`*` with credentials), missing TLS/HSTS, verbose error leakage, missing
  rate limits on public endpoints, dependencies with known CVEs.
- **Exploit**: info disclosure, credential reuse, cross-origin abuse, DoS.
- **Fix**: harden prod config; least-privilege CORS; enforce TLS; generic error
  messages; rate-limit; patch/pin dependencies.

## Prioritize
Rate by exploitability × impact. RCE, auth bypass, and injection reaching a
dangerous sink are 🔴 Critical. A concrete exploit path is what separates a
real finding from speculation — always state it.
