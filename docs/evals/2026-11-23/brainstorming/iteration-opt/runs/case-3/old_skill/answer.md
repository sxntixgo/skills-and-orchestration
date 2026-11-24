**What I'd do, in order:**

1. **TodoWrite** (from the skill's steps):
   - Understand context: read the project and restate the idea
   - Clarify intent, one question at a time
   - Explore 2–3 approaches
   - Present the design in sections, validating each
   - Write the design to `docs/plans/` and hand off to `writing-plans`

2. **Read project context** (read-only: `README.md`, the top-level layout, `git log --oneline -20`). Since I can't see it, I assume a mid-sized app with a modular core and no extension mechanism today. Nothing tells me which features would become plugins or who would write them.

3. **Write the checkpoint** `./.claude-skills-work/brainstorming/plugin-system/design.md`:
   ```markdown
   # Plugin system: WIP design
   Status: step 2 (clarifying intent)

   ## Idea (restated)
   An extension mechanism so new features can ship as plugins
   instead of changes to core.

   ## Open concerns
   - "Any future feature" is unbounded (YAGNI risk). Need 2–3 concrete
     upcoming features to design against.
   - Unknown: who writes plugins (us vs third parties), trust/sandboxing,
     load time (build vs runtime), versioning of the plugin API.

   ## Answers so far
   (none yet)
   ```

4. **No subagents and no code.** This step is a conversation with the user.

**Reply to the user:**

---

Here's how I understand it: you want an extension mechanism so new features can be added as plugins without changing the core. Correct me if that's off.

I don't want to start from "any future feature". A system built to take *anything* usually ends up as a large, vague API that fits nothing well. A better start is the real features you expect next, designing the plugin API to fit those.

**First question:** who will write these plugins?

- **(a)** Only our team. It's mostly about modularity and keeping core small. *(This is my guess.)*
- **(b)** Our team plus trusted partners or internal teams.
- **(c)** Untrusted third parties, like a public marketplace. That means sandboxing, permissions and a stable versioned API.

---

**Next, one per turn after that answer:**
- 2–3 concrete features you'd build as plugins first
- When plugins load: at build time or at runtime
- What "done" means, e.g. "feature X ships as a plugin with zero core changes"
- Constraints: stack, performance, and what's out of scope

Then I'd propose 2–3 approaches with a recommendation, for example:
- compile-time modules with a registry
- runtime-loaded packages with hooks or events
- out-of-process plugins over RPC

After that I'd present the design in sections, ending each with "does this look right?", and write the final version to `docs/plans/2026-11-23-plugin-system-design.md` for `writing-plans` to turn into an implementation plan.