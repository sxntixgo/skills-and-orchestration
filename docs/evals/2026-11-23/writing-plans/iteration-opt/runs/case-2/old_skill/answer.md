**What I'd do, in order:**

1. TodoWrite with the skill's five steps: Ground the plan (⛔ STOP if the spec is unclear), Decompose into phases, Detail each task, Mark gates/risks/out-of-scope, Write the plan and hand off.
2. Look for a spec or design for "the new dashboard", for example `docs/specs/*dashboard*`, `docs/plans/*dashboard*` or a design doc linked from an issue. You didn't name or provide one, so I treat it as **not found**.
3. Stop at Step 1. "Plan out the new dashboard" has no requirements, and the skill says to stop and clarify rather than make them up. I write no plan file, read no code to guide decomposition and spawn no subagents. Nothing is logged except that the Step 1 todo is blocked on clarification.

**Reply to the user:**

> I haven't written a plan yet because I couldn't find a spec or design for the new dashboard, and I'd have to guess the requirements. Can you point me to a spec/design doc, or answer these?
>
> 1. **Users and purpose:** Who uses it, and what decisions or tasks should it support?
> 2. **Content:** Which metrics, widgets or views does it show, and where does the data come from (existing APIs, DB tables, a new endpoint)?
> 3. **Behavior:** Does it need filters or date ranges, refresh or real-time updates, drill-downs, or export?
> 4. **Access:** Who can see it? Does it need auth or role checks?
> 5. **Placement:** Is it a new route in the existing frontend or a separate app? Is there a mockup?
> 6. **Done when:** What observable result makes v1 a success? Is there a deadline, or anything explicitly out of scope?
>
> Once I have this, I'll read the relevant code and write a phased plan to `docs/plans/2026-11-23-dashboard-plan.md`. Each task will say what to change, where, and how to verify it, with review gates between phases. You can then run the plan with `software-development`.