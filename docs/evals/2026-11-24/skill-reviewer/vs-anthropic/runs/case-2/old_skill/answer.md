## What I'd do, in order

1. **Look for the skill. It isn't there.** You described the skill but didn't give a name, path or contents. I wouldn't guess which `SKILL.md` you meant, and I wouldn't run commands, spawn subagents or write files yet.
2. **Log nothing to disk.** The workspace would be `<skill-name>-workspace/` next to the skill directory, and that needs the skill's name first.
3. **Review the three problems you listed**, using the loaded skill's guidance and the house rules in `CLAUDE.md`. Then ask for the path.

(Side issue: the file at `plugins/skill-authoring/skills/skill-reviewer/SKILL.md` has `name: skill-creator` in its frontmatter. Its content is Anthropic's skill-creator. That breaks the house rule that `name` must match the directory name.)

## Reply to the user

The skill fails review on all three points. Send me its path (or paste the `SKILL.md`) and I'll fix it and run the evals.

| # | Problem | Severity | Fix |
|---|---|---|---|
| 1 | Description is `Helps with stuff` | **Blocker.** Claude decides whether to load a skill from the name and description alone. This one has no trigger, so the skill will almost never load, or will load for the wrong requests. | Use the format "<what it does>. Use when <concrete trigger>." in third person. Make it a little pushy: list the phrases and situations where it should load, even when the user doesn't name it. |
| 2 | No scope section | **Major.** Without one, Claude drifts and expands what it does. House rule 7 requires one. | Add sections for what the skill does and does NOT do, a checklist of required steps (tracked as TodoWrite items), STOP points where it pauses for the user, and a short list of common ways it goes wrong. |
| 3 | No `evals/evals.json` | **Blocker.** House rule 8 says a skill isn't done until a baseline comparison shows it helps. | Write 2–3 realistic prompts in `{skill_name, evals:[{id, prompt, expected_output, files}]}`. Add assertions while the eval runs are in progress. |

**Once I have the path:**
1. Copy the current version to `<skill-name>-workspace/skill-snapshot/` before editing anything.
2. Ask what the skill is for and what should trigger it, so I can write a real description.
3. Add the scope section and draft `evals/evals.json`. I'll show you the test prompts before running them.
4. For each test, run two subagents at the same time: one with the new skill, one with the old snapshot. Results go to `iteration-1/<eval-name>/{with_skill,old_skill}/outputs/`.
5. Record tokens and time for each run, grade the results, and combine them into `benchmark.json`. Then open the results viewer for you to review.

What is this skill supposed to do, and when should it trigger?