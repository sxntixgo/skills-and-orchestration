# Debugging techniques

## Isolation
- **Binary search the code path** — disable/short-circuit half the pipeline; see
  which half still fails; repeat. Converges fast even in unfamiliar code.
- **`git bisect`** — when it "used to work", bisect commits to the exact change
  that introduced it. A regression's diff usually names the cause.
- **Differential debugging** — compare a working case vs. the failing one and
  minimize the difference until one change flips the outcome. That change points
  at the cause.
- **Shrink the input** — reduce to the smallest input/state that still triggers
  the bug. Small repros make the cause obvious and become the regression test.
- **Read the actual error** — the full message, stack trace, and the *first*
  error (later ones are often fallout). Don't skim it.

## Verifying a cause (before fixing)
- Add a log/assertion that should be true IF your hypothesis holds; run it. Being
  right for the wrong reason is still wrong.
- Predict what changing the suspected cause will do, then change it and check the
  prediction. If reality disagrees, the hypothesis is wrong — revise it.
- Change ONE thing at a time. Multiple simultaneous changes destroy the signal.

## Common bug patterns (candidate causes)
- **Off-by-one / boundary** — empty, first/last, zero, max, inclusive vs exclusive.
- **Null/undefined from async** — reading a value before a promise resolves; an
  un-awaited call; a fetch that failed silently.
- **State leakage** — shared mutable state between calls/tests/requests; a cache
  or module-level variable not reset.
- **Race / ordering** — two operations assuming an order that isn't guaranteed;
  check-then-act (TOCTOU); stale closures capturing old values.
- **Type coercion / comparison** — `"1" == 1`, truthiness of `0`/`""`, `NaN`
  comparisons, float equality.
- **Environment / config** — works locally, fails in CI/prod: different env vars,
  versions, timezone, locale, filesystem case-sensitivity.
- **Off-by-context** — the code is right but runs on the wrong data / wrong
  branch / wrong tenant.

## Heisenbugs (disappears when observed)
Intermittent or timing-dependent bugs: don't paper over with retries/sleeps.
Suspect nondeterminism — real clock, network, random, unordered iteration, test
order, concurrency. Make the source deterministic (inject clock/seed, control
ordering) so the bug becomes reproducible, THEN fix it.

## When truly stuck
- Rubber-duck it: explain the code line by line out loud; the wrong assumption
  usually surfaces mid-explanation.
- Question the assumption you're most sure of — the bug lives where you're not
  looking.
- Check the boundaries you didn't write: the library, the framework, the data.
