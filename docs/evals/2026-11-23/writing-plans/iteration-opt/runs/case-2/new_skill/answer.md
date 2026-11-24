**What I'd do:**

1. Look for a dashboard spec or design: `ls docs/ docs/specs docs/plans` and `grep -ril dashboard docs/`. **Assumption:** none is found, because you didn't name or provide one.
2. Stop at the skill's step 1 gate. I can't name the dashboard's core behaviour (what data, for whom, what done means), and the skill says not to invent a plan from nothing.
3. Write nothing: no `docs/plans/` file, no TodoWrite items, no subagents.

**Reply:**

I can't plan this yet because I don't know what the dashboard should do, and I didn't find a spec for it. Please answer these, or point me to a spec or design doc:

1. **Who uses it?** For example: internal admins, end customers, or ops/on-call.
2. **What does it show?** Which data or metrics, and where that data comes from now (which DB tables, APIs or services).
3. **What can users do on it?** Only view, or also filter, export, drill down or take actions?
4. **What does "done" look like?** For example: "an admin can see daily signups and revenue for the last 30 days, filterable by plan."
5. **Constraints:** Does it go in an existing app or frontend (which one)? Does it need auth or roles? Does it need real-time data or is periodic refresh fine?
6. **Is "new" replacing something?** If there's an old dashboard being replaced, I need to know what has to carry over.

Once I know the core behaviour, I'll write a phased plan to `docs/plans/2026-11-23-dashboard-plan.md`. Each task will say what to change, in which file, and how to verify it, with gates between phases and a list of risks and out-of-scope items.