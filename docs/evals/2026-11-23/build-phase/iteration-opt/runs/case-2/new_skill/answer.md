T3.2 goes to a subagent on the model the plan assigns. I won't build it on the small model. I assume `PLAN.md` exists and its Phase 3 section assigns T3.2 to `model: opus`.

## Steps, in order

**1. Read the plan (TodoWrite: "Read plan / T3.2 done-criteria")**
- Look for `PLAN.md`, `SPEC.md`, `docs/plans/*`, or a plan file named in `CLAUDE.md`. I assume I find `PLAN.md` with a Phase 3 section.
- Assumed T3.2 entry: "Design and implement the caching layer for `ApiClient` (`src/client/cache.ts`). Model: opus. Done when: GET responses are cached with a TTL, writes invalidate the cache, and tests cover hit/miss/expiry/invalidation."
- Write the done-criteria to `.notes/phase3-T3.2.md`:
  ```
  # T3.2 done-criteria (from PLAN.md §Phase 3)
  - GET responses cached with configurable TTL
  - POST/PUT/DELETE invalidate affected keys
  - Tests: hit, miss, expiry, invalidation
  Assigned model: opus
  Out of scope: anything in T3.3+ / Phase 4
  ```
- ⛔ I would stop and ask in two cases:
  - The plan only says "stronger/design model" without naming a model. That's ambiguous, and I won't guess.
  - T3.2 isn't in the plan.

**2. Orient (TodoWrite: "Orient")**
- Read `CLAUDE.md`/`AGENTS.md`, the code style in `src/client/`, and the repo's test/lint/typecheck/build commands. I assume `npm test`, `npm run lint`, `npm run typecheck` and `npm run build`.
- Check for project rules on who writes tests.

**3. Scope & model (TodoWrite: "Delegate T3.2 to opus")**
- I'm on a different model from the one assigned, so I spawn one subagent for this one task, with the exact model. I won't downgrade to save time.

**Agent call:** `model: "opus"`, prompt:
```
Implement task T3.2 from PLAN.md (Phase 3) in /workspaces/<repo>. Do ONLY T3.2.
Done-criteria (see .notes/phase3-T3.2.md):
- GET responses cached with configurable TTL
- POST/PUT/DELETE invalidate affected keys
- Tests cover hit, miss, expiry, invalidation
Rules:
- Test-first: write a failing test, run it to see it fail, then the simplest code that passes, then refactor (DRY/YAGNI/KISS).
- Follow CLAUDE.md/AGENTS.md and the existing style/helpers in src/client/. Add no new tools or dependencies.
- Don't touch T3.3+ or Phase 4 work; list anything you think belongs there instead of doing it.
- Verify with: npm test, npm run lint, npm run typecheck, npm run build. Exercise the real behaviour
  (e.g. a small script showing a cache hit, expiry and invalidation), not just the types.
- Don't leave servers running. Do NOT git commit.
Report: files changed, test counts + names, verification output, deviations with reasons.
```

**4–5. Build and verify**
- The subagent builds T3.2 test-first.
- When it reports back, I rerun `npm test && npm run lint && npm run typecheck && npm run build` myself to confirm the result. I don't take the report on trust.
- If something fails, I send it back to an `opus` subagent. I don't fix it on the small model.

**6. Update `PLAN.md`**
- Mark T3.2 done.
- Add any follow-up work the subagent flagged, with its model, under the phase it belongs to.
- Remove finished entries whose decisions now live in code or `CLAUDE.md`.

**7. Report (no commit)**

## Final message to you

> T3.2 was implemented by an `opus` subagent, as `PLAN.md` assigns. I didn't build it on the small model.
> - **Files:** `src/client/cache.ts`, `src/client/ApiClient.ts`, `tests/client/cache.test.ts`, `PLAN.md`
> - **Tests:** `cache.test.ts` 4/4 passed (`returns cached GET within TTL`, `fetches on miss`, `refetches after TTL expiry`, `invalidates on write`). The full suite passed when I reran it myself.
> - **Verification:** lint, typecheck and build are clean. A script showed a cache hit, expiry and invalidation against the real behaviour.
> - **Deviations:** none. Follow-up items the subagent flagged went into `PLAN.md` under their own phases.
> - **Not committed:** the changes are ready for you to review and commit.