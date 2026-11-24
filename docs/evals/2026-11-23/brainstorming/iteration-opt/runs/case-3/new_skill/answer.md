**What I'd do, in order:**

1. **TodoWrite** with the skill's steps: Context → Clarify intent → Choose approach → Design in sections → Write to `docs/plans/` and hand off to `writing-plans`.
2. **Context (read-only):** `git log --oneline -20`, `ls`, then read `README.md`, the top-level source layout and any `docs/`. Nothing exists on disk here, so I'm assuming a single-repo app with a core module and features wired in directly, and no plugin or extension mechanism yet.
3. **Start the work-in-progress file** `./.claude-skills-work/brainstorming/plugin-system/design.md`:
   ```markdown
   # Plugin system: design (WIP)
   ## Request
   "Design a plugin system so we can add any future feature as a plugin."
   ## Assumptions
   - Single codebase; features currently wired directly into core.
   - No existing extension mechanism.
   ## Open question
   - Who writes plugins and how do they ship? (decides approach)
   ## Candidates
   - A: internal registry + fixed extension points
   - B: hook/event bus
   - C: external loadable plugins (discovery, versioned API, isolation)
   ## Decisions
   (none yet)
   ```
4. No subagents and no code. I send the reply below, then wait.

---

**Reply to the user:**

You want new features to plug into the app instead of being wired into the core. I'm assuming the features we'd add next live in this repo, and nobody outside the team builds plugins yet.

"Any future feature" is the part to cut down. A system that can host *anything* needs a huge, stable API we'd be guessing at today. The better move is to build for the 2–3 features you actually expect next and extend it when a real feature needs more. Options:

- **A. Internal registry + a few typed extension points** (e.g. `registerRoute`, `registerCommand`, `onStartup`). Features become modules that register themselves at boot. It's the cheapest option, easy to reverse, and type-checked, but it only covers the extension points we define.
- **B. Hook/event bus.** Core emits named events and plugins subscribe. It's more flexible and loosely coupled, but data flow gets implicit and harder to debug and test, and ordering between plugins becomes its own problem.
- **C. External loadable plugins:** separate packages discovered at runtime, with a versioned public API and possibly isolation. Third parties can extend the app without touching the core, but you take on API stability, version compatibility and security costs. That only pays off if outsiders really will write plugins.

**I'd lean to A** because it fixes today's coupling at the lowest cost, and we can add B or C later without rewriting anything, **unless** you need third parties shipping plugins independently. In that case it's C.

**One question:** who writes and ships these plugins?
(a) Only our team, in this repo
(b) Our team, but as separately deployed or toggled packages
(c) External developers or customers