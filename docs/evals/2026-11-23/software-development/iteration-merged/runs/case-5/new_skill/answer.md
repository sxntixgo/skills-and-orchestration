I'd stop before building: I couldn't find a Phase 3 plan.

**Steps I'd take, in order:**

1. TodoWrite item: "Stage 0: find the plan and read Phase 3."
2. Look for the plan in the places the skill names. These are read-only checks:
   ```bash
   ls PLAN.md SPEC.md docs/plans/ 2>/dev/null
   grep -niE 'plan|phase' CLAUDE.md 2>/dev/null
   grep -rniE '^#+ .*phase 3' --include='*.md' . 2>/dev/null | head
   ```
   I'm assuming none of these exists, and that `CLAUDE.md` doesn't point to any plan file.
3. Stop there. I wouldn't write code, start subagents, create files or commit. Making up Phase 3 isn't allowed.

**My reply to you:**

> I can't start Phase 3 because I couldn't find a plan that defines it. I checked:
> - `PLAN.md` and `SPEC.md` in the repo root
> - everything under `docs/plans/`
> - `CLAUDE.md`, for any link to a plan
> - all Markdown files, for a "Phase 3" heading
>
> Where is the plan? You can give me a file path or paste the Phase 3 section. Once I have it, I'll:
> 1. Repeat the phase's done-criteria back to you.
> 2. Run each task on the model it's assigned to, using a subagent when that model isn't the one I'm on.
> 3. Build only Phase 3, test-first.
> 4. Update the plan when I'm done.
>
> I won't commit unless you ask.