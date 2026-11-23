No plan exists yet, so I'd stop at step 0 (plan gate) and start the design work with you instead of orchestrating.

**What I'd do, in order**

1. Read `contract.md` (done) and add one TodoWrite item per required step (0–5).
2. Find the todo task "Research app (headless runner + web UI)". I'm assuming it's in your todo list and contains only a title plus a line or two. My guess: "run research jobs without a chat session and watch or read them in a browser".
3. **Step 0, plan gate:** `docs/plans/` doesn't exist because the repo only has `.devcontainer/`. A todo task is not a plan, and this isn't a small change the request already pins down. I'd stop orchestrating here.
   - I would not create `.orchestra/`, `config.json` or `board.md`.
   - I would not spawn subagents or dispatch anything.
   - Choosing a stack or architecture while writing `board.md` is a red flag in the skill, so I'd leave that alone too.
4. Run `brainstorming` (frugal-skills) with you, one question at a time, and write nothing until the design is settled.
5. Run `writing-plans` to save a phased plan to `docs/plans/2026-11-23-research-app-plan.md`.
6. Come back to `claude-orchestrate-development` with that plan path and start at step 1 (set up run `2026-11-23-research-app`).

**Final reply to you**

> There's no plan for "Research app (headless runner + web UI)" yet, and the repo only has the devcontainer. I can't orchestrate a todo title without inventing the design, so we'll settle the design first, then I'll write a phased plan in `docs/plans/` and orchestrate from that.
>
> First question: what should the headless runner run?
> - **A)** The existing research pipeline (brief → sub-question tasks → opencode researchers → report, like `claude-orchestrate-research`), started without an interactive Claude session.
> - **B)** A new, simpler pipeline of its own, for example a single question that produces a single report.
> - **C)** Something else. Please describe it.
>
> After that I'll ask about the web UI's job (start runs, watch progress live, read reports, or all three), who uses it (just you on localhost, or others on the LAN), and the stack.