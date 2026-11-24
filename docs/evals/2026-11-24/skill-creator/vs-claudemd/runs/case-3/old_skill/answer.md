**What I'd do:**

1. Invoke `skill-authoring:skill-creator`, as CLAUDE.md requires for creating a skill.
2. Add TodoWrite items: Intake/scope (in progress), Draft frontmatter + trigger, Write SKILL.md body, Write evals/evals.json, Run baseline comparison, Run skill-reviewer.
3. Write a checkpoint file so intake can be resumed later. I'd create no skill directory or `SKILL.md` yet. File `.claude-skills-work/skill-creator/productivity/00-intake.md`:
   ```markdown
   # Intake: "productivity" skill
   Request (verbatim): "Make me a skill for productivity."
   Status: BLOCKED at the scope gate. The request is too broad to pick a trigger or process.
   Open questions: see reply to user (workflow, trigger, process, scope, location).
   Resume: answer the questions, then continue at step "Draft frontmatter + trigger".
   ```
4. Stop at the scope gate and reply. I wouldn't guess. "Productivity" doesn't give a concrete trigger. A generic productivity-tips skill would only restate things the model already knows, and this repo has found that kind of skill adds nothing (for example, `security-review` measured 0.00 lift).

**Reply to user:**

"Productivity" is too broad for me to build a skill that helps. A skill is worth its token cost when it encodes a specific process I wouldn't follow by default, not general advice. Before I draft anything, I need these answers:

1. **Workflow:** What exact task do you want help with? For example: triaging a backlog into a daily plan, writing a weekly status report from git log, turning meeting notes into action items, or timeboxing a coding session.
2. **Trigger:** What would you say or do just before you'd want this skill to load? (This becomes the "Use when …" part of the description.)
3. **Process:** What steps or rules should I follow that I currently miss or do inconsistently? For example: a fixed output format, a prioritization rule, or a check before finishing.
4. **Inputs/outputs:** What goes in (files, a git repo, pasted notes), and what should come out, and where (a file path, a chat reply)?
5. **Scope:** What should the skill explicitly not do?
6. **Location:** Should it go in `frugal-skills` (`skills/`), the `skill-authoring` plugin, or a separate personal `.claude/skills/`? Productivity doesn't obviously fit the repo's areas: authoring, research, building, and review.

Once you answer, I'll draft the frontmatter and 3–5 eval cases for your approval before writing the body.