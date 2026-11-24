I can't start Phase 3 yet because I couldn't find a plan that defines it. I won't make up a plan or a phase.

**What I'd do, in order:**

1. Create the todo list with TodoWrite: Read plan → Orient → Scope & model → Build (test-first) → Verify → Update plan → Report. I'd mark "Read plan" as in progress.
2. Look for the plan in these places:
   - `PLAN.md` and `SPEC.md` at the repo root
   - `docs/plans/*`
   - any plan file named in `CLAUDE.md` or `AGENTS.md`
3. **Result:** no plan file turned up, and nothing defines a "Phase 3". The skill says to stop and ask in this case, so I stop at step 1. I write no files, spawn no subagents, run no builds and make no commits.

**Reply to user:**

> I couldn't find a plan that defines Phase 3. I looked for `PLAN.md` and `SPEC.md` at the repo root, `docs/plans/*`, and any plan file named in `CLAUDE.md` or `AGENTS.md`.
>
> Could you point me to the plan, either by giving its path or pasting the Phase 3 section? Once I have it, I'll:
> - list Phase 3's done-criteria
> - run each task on its assigned model
> - build test-first, staying inside Phase 3
> - verify with the repo's own test, lint and build commands
> - update the plan and report back
>
> I won't commit unless you ask.