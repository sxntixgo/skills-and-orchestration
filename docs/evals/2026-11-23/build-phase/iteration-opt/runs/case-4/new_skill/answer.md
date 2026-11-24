**Assumption:** earlier in this session I built Phase 2 from `PLAN.md`, which I'd already read, and its done-criteria are in my note (`.claude/phase-2-criteria.md`). If no plan was ever read this session, I'd stop and ask which plan and phase you mean rather than wrap up.

Passing tests don't finish the phase. The skill still needs a full verify, a plan update and a report, and it doesn't commit.

**What I'd do, in order**

1. **TodoWrite:** mark "Build" complete and add three items: "Verify", "Update plan" and "Report".
2. **Verify** using the repo's own commands from `CLAUDE.md` or `package.json`, adding no new tools:
   - `npm test`: record the pass/fail counts and test names.
   - `npm run typecheck` and `npm run lint`: both must be clean.
   - `npm run build`: must be green.
   - Exercise the real behaviour, not just the types. For example, run the CLI or endpoint the phase added (`node dist/cli.js <phase-2 command>` or `curl localhost:3000/<new route>`) and compare the output with each done-criterion.
   - Stop any dev server I started (`kill %1`, then `lsof -i :3000` to confirm the port is free).
   - If anything fails, debug it and re-run before going further. "Tests pass" alone isn't enough to report done.
3. **Check each done-criterion against the evidence.** If a criterion has no test that I wrote first, or no observed behaviour, it's a gap. I'd fix it or list it as a deviation.
4. **Update `PLAN.md`:**
   - Mark the Phase 2 tasks done.
   - Remove finished entries whose decisions now live in code or `CLAUDE.md`.
   - Add any follow-up work agreed during the phase, with its assigned model, under the phase it belongs to. Any Phase 3 requests I turned down go under Phase 3 and aren't built now.
5. **No `git commit`.** You handle commits.

**Final message (template, filled from the real outputs):**

> Phase 2 is done and verified. Nothing is committed.
>
> **Files changed:** `src/…` (new), `src/…` (modified), `tests/…` (new), `PLAN.md`
>
> **Tests:** N passed, 0 failed. New tests: `test_a`, `test_b`, …
>
> **Verification:** typecheck clean, lint clean, build green. Real behaviour: `<command>` returned `<output>`, which meets criteria 1–K. No dev servers left running.
>
> **Plan:** Phase 2 is marked done and its finished entries are pruned. Follow-ups were added under Phase 3, each with its assigned model.
>
> **Deviations:** `<item: reason>`, or none.
>
> The changes are ready for you to review and commit.