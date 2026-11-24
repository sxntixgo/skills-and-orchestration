"Productivity" is too broad to build a skill from yet, so I'd stop and ask a few questions before writing anything.

**What I'd do, in order**

1. Invoke `skill-authoring:skill-creator`, as CLAUDE.md requires for creating a skill.
2. Write the intake checkpoint to `./.claude-skills-work/skill-creator/intake.md` so the work can be resumed later:
   ```markdown
   # Intake: new skill (requested: "a skill for productivity")
   Status: BLOCKED, waiting for scope from user
   - Trigger: unknown
   - Process the model doesn't already follow: unknown
   - Inputs/outputs: unknown
   - Does NOT do: unknown
   Next: once the user answers, fill these in, then pick the name/dir and draft SKILL.md + evals/evals.json
   ```
3. Stop here. I wouldn't create `skills/<name>/`, a SKILL.md, evals or a `plan.md` entry until the scope is clear.

**Reply to the user**

> A skill only pays for its tokens if it adds a specific process the model wouldn't follow on its own. General productivity advice would score close to zero against the baseline, like `security-review` did before it was folded into `code-review`. To turn this into something that helps, tell me:
>
> 1. **What task should it handle?** Some options: a daily or weekly planning ritual, triaging a TODO or issue backlog, splitting a vague goal into next actions, writing standup or status updates, or a focused work-session loop. Or something else.
> 2. **What should trigger it?** What would you type or be doing when it should load? For example: "when I paste my task list and ask what to do today."
> 3. **What steps or rules do you follow that a generic assistant gets wrong?** For example: a cap on WIP, a time-boxing rule, or a set output format. This is what the skill is really for.
> 4. **What does it work on?** Plain text, a file such as `TODO.md`, or a tracker like GitHub issues? And where should results go?
> 5. **What should it NOT do?** For example: it shouldn't reschedule your calendar or touch external services.
>
> Once you answer, I'll draft the SKILL.md, a few eval cases and a test against the no-skill baseline.