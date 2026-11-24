**I haven't started T3.2. There's no plan to build it from, and "stronger/design model" doesn't name a specific model.**

What I'd do, in order:

1. **TodoWrite:** one item for each of the 7 build-phase steps.
2. **Step 1, read the plan:** look for `PLAN.md` or `SPEC.md` at the repo root, and for a spec file named in `CLAUDE.md` or `AGENTS.md`. You didn't name or provide a plan, so I assume none is found. The skill says to stop and ask at this point, so I write no code, spawn no subagent and change no files.
3. **Step 3, check the model:** even with the plan, "stronger/design model" isn't a model ID. The skill says to stop when the assigned model is ambiguous, not guess. Small-model-only work would stay off this task either way: building it on a weaker model than assigned is a red flag in the skill. (This session is actually on Opus 5.5, not a small model, but that doesn't change anything until the assignment is clear.)

**Reply to you:**

> I can't start T3.2 yet. Two things are missing:
>
> 1. **The plan.** There's no `PLAN.md` or `SPEC.md`, and `CLAUDE.md` doesn't point to a spec. Which file contains T3.2? I need its done-criteria before writing any code.
> 2. **The exact model.** "Stronger/design model" doesn't say which model. Which ID should it be (for example `claude-opus-5-5` or `claude-fable-5-2`)?
>
> Once I have both, I'll start a subagent on that exact model (`Agent`, `model: <id>`) to build T3.2 test-first, limited to its done-criteria. Then I'll run the tests, lint, typecheck and build, and exercise the real behavior. After that I'll update the plan and report the files changed, test counts and names, and the verification output. I won't commit anything.