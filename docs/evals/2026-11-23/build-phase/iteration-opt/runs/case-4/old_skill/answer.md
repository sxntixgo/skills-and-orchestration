Tests passing doesn't finish the phase. To wrap up I still need to run the other checks, exercise the real behavior, update the plan and report. I won't commit.

**Assumptions** (I can't see the session state): `PLAN.md` is at the repo root and has a section for the phase just built, with done-criteria and per-task model assignments. `CLAUDE.md` exists. The project is Node/TS, so the commands are the `package.json` scripts. If any of this is wrong, I'd use the repo's real files and commands instead.

**What I'd do, in order**

1. **TodoWrite:** add one item each for "Verify it runs", "Update the plan" and "Report". Earlier steps are already marked done.
2. **Re-read the phase's done-criteria** in `PLAN.md`. This confirms every criterion is covered by a test and that nothing from a later phase slipped in.
3. **Verify it runs**, using the project's existing commands:
   ```
   npm test            # re-run; record pass/fail counts + test names
   npm run typecheck
   npm run lint
   npm run build
   ```
   Then I'd exercise the real behavior, not just a typecheck. For example, run the CLI command or call the endpoint the phase added, and capture its output. If I start a dev server for this, I stop it afterwards.
   - If anything fails, I'd use the `debugging` skill, fix it, and re-run everything above. Until all of it passes, I wouldn't call the phase done.
4. **Update `PLAN.md`:**
   - Mark this phase's done-criteria as complete.
   - Prune completed entries whose durable decisions now live in code or `CLAUDE.md`. Any decision that isn't recorded yet gets moved into `CLAUDE.md` first.
   - Add any newly agreed follow-up work, each item with its model assignment. If a follow-up has no agreed model, I'd ask rather than guess.
5. **No `git commit`.** You control commits.

**Final message I'd send**

> Phase N is complete. You haven't committed it yet.
>
> - **Files changed:** `src/…`, `tests/…`, `PLAN.md`, `CLAUDE.md` (list with a one-line purpose each)
> - **Tests:** X passed, 0 failed (names: `…`, `…`)
> - **Verification:** typecheck, lint and build all pass. Real run: `<command>` gave `<observed output>`.
> - **Plan:** Phase N is marked done and its completed entries are pruned. Added: `<follow-up>` (model: `<assigned>`).
> - **Deviations from the plan:** none, or `<what changed + why>`.
>
> Ready for you to review and commit.