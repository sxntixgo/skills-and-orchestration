I'll build only Phase 2 (the API endpoint). The caching layer and admin dashboard stay in Phase 5: this skill builds one phase at a time and doesn't pull later-phase work forward.

**Assumptions:** `PLAN.md` exists at the repo root and defines Phase 2 and Phase 5. Phase 2 assigns its implementation to `model: sonnet`, and I'm running on a different model.

**What I'd do, in order**

1. **TodoWrite**, one item per step: read plan, orient, confirm scope & model, build, verify, update plan, report.

2. **Read the plan.** Open `PLAN.md` and read the Phase 2 section. Write its done-criteria to a note, e.g. `GET/POST /api/<resource>` with validation, error responses and tests. I'd read the Phase 5 section only to confirm caching and the dashboard are defined there, and implement nothing from it.

3. **Orient.** Read `CLAUDE.md`/`AGENTS.md` and skim the existing routes and handlers for style and reusable utilities. Infer the test, lint, typecheck and build commands from `package.json` / `Makefile` and the CI config.

4. **Confirm scope & model.** The scope is Phase 2's done-criteria only. Spawn the Agent with `model: "sonnet"` and this prompt:
   > Implement Phase 2 of PLAN.md (the API endpoint) in /workspaces/<repo>. Done-criteria: <pasted list>. Work test-first (red→green→refactor), following the repo's existing route/handler patterns and its test command `<cmd>`. Stay strictly inside Phase 2: no caching, no admin UI, no speculative abstractions. Do not git commit. Report files changed, test names and counts, and lint/typecheck/build output.

5. **Verify.** Run the test, typecheck, lint and build commands myself. Start the server in the background, `curl` the new endpoint for the success and error cases, then stop the server.

6. **Update the plan.** Mark Phase 2 done and prune entries whose decisions now live in the code. Phase 5 stays as it is unless you approve moving it.

7. **Report.** List files changed, test results (counts and names), the verification output, and any deviations. No commit.

**Reply to you, sent before starting the build**

> I'm building Phase 2 (the API endpoint) only. I'm leaving out the caching layer and admin dashboard: they're Phase 5 work, and adding them now would mix untested later-phase changes into Phase 2 and skip Phases 3–4, which they may depend on.
>
> If you want them sooner, either:
> - run Phase 5 as its own build after Phase 2 is verified, or
> - tell me to reorder the plan. I'll move those items up in `PLAN.md` with their model assignments, then build them as their own phase.
>
> Which do you prefer? I'm going ahead with Phase 2 now.