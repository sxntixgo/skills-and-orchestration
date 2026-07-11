# Frontend concerns

Read at Stage 2 when the slice touches UI (components, pages, client state).
Apply what's relevant; skip what isn't.

## Shape the slice
- Follow the codebase's component patterns, styling system, and state approach.
  Don't introduce a new state library or CSS methodology for one feature.
- Separate presentation from logic: dumb components render props; hooks/services
  hold behavior and data-fetching. Keep components small.
- Derive state; don't duplicate it. One source of truth — computing from props
  beats copying into local state that can drift.

## State & data
- Model the real states explicitly: loading, empty, error, and success — not
  just the happy path. Every fetch has at least these four.
- Handle async correctly: cancel/ignore stale responses, avoid setting state
  after unmount, debounce user-driven fetches.
- Keep server state and UI state distinct; don't jam everything into one global
  store.

## Errors & UX
- Show actionable feedback on failure (a message the user can act on), never a
  silent catch. Preserve the user's input on error.
- Disable/guard controls during in-flight actions to prevent double-submit.
- Validate on the client for UX, but never rely on it for correctness — the
  server validates too.

## Accessibility (test these)
- Semantic HTML first (button is a `<button>`); ARIA only to fill gaps.
- Everything operable by keyboard; visible focus; labels tied to inputs.
- Sufficient color contrast; don't encode meaning in color alone. Respect
  reduced-motion.

## What to test (hand the list to writing-tests)
Renders each state (loading/empty/error/success); user interactions produce the
right calls/output; validation and error messages appear; keyboard/a11y paths;
boundary inputs (empty, very long, special chars).

## Keep it simple
No premature memoization, no generic "flexible" components with ten props, no
abstraction until a second real use exists (YAGNI, KISS). Optimize only after
you measure a real problem.
