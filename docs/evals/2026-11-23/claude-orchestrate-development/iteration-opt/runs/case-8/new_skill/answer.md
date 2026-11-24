I won't dispatch that task to opencode by itself. Writing a spec for a one-line constant takes as long as just adding the constant, so the skill says to fold it into the neighbouring task that uses `MAX_ROWS`.

What I'd do, in order:

1. **Plan gate (step 0).** You didn't name a plan path, so I'd run `ls docs/plans/`. I'm treating the plan as not found. Without it I can't see the tasks next to this one, so I can't tell which one reads `MAX_ROWS` or who else changes `config.py`.
2. **Stop before setting anything up.** No `.orchestra/` run, no `board.md`, no spec subagent and no dispatch. Nothing gets logged because no run exists yet.

Once I have the plan, the task graph handles it:
- **If a planned task uses `MAX_ROWS`** (e.g. pagination or the export limit): I add the constant to that task's goal and add `config.py` to its files. That task gets a spec and goes to opencode as normal, with its test command covering the limit.
- **If nothing uses it:** I drop it under YAGNI and log the reason in `board.md`.
- **If you want it as a separate commit anyway:** a `haiku` subagent adds it in a worktree, and it's reviewed like any other task. Spinning up opencode for one line isn't worth it.

Reply: what's the plan's path (e.g. `docs/plans/<name>-plan.md`)? Or, if this one constant is all you need, should I just add it?