# Backend concerns

Read at Stage 2 when the slice touches server-side code (APIs, services, data,
jobs). Apply what's relevant; skip what isn't.

## Shape the slice
- Define the contract first: inputs, outputs, status codes/errors. Types or a
  schema at the boundary beats prose.
- Keep layers thin and separated: transport (route/handler) → domain logic →
  data access. Don't put business rules in the controller or SQL in the handler.
- Follow the codebase's existing patterns (framework idioms, folder layout,
  error conventions) rather than inventing new ones.

## Data
- Validate input at the boundary; never trust the client. Reject early with a
  clear error.
- Make writes idempotent where it matters; use transactions for multi-step
  writes so partial failure doesn't corrupt state.
- Watch for N+1 queries; fetch what you need in one round trip. Index the
  columns you filter/sort on.
- Migrations are forward-only and reversible; never edit data by hand in a way
  code can't reproduce.

## Errors & failure
- Distinguish expected failures (validation, not-found, conflict) from bugs.
  Return meaningful status codes; don't leak stack traces or internals.
- Handle timeouts and retries for outbound calls; a dependency WILL be slow or
  down. Fail closed on auth, fail with a clear message elsewhere.
- Log with enough context to debug (ids, not secrets), structured if the project
  is.

## Security seams (test these)
- AuthN and AuthZ on every protected route — check the caller is who they say
  AND allowed to touch THIS resource (no IDOR).
- Parameterize queries (no string-built SQL); escape/encode outputs.
- Never log or return secrets, tokens, or PII. Read config/secrets from env, not
  literals.
- Rate-limit and size-limit anything public.

## What to test (hand the list to writing-tests)
Happy path per contract; validation failures; authz denials; not-found/conflict;
dependency failure/timeout; boundary values (empty, max, zero, negative).

## Keep it simple
Don't add caching, queues, generic abstractions, or config toggles until a
current requirement needs them (YAGNI). The simplest handler that satisfies the
contract and the security checks is the target (KISS).
