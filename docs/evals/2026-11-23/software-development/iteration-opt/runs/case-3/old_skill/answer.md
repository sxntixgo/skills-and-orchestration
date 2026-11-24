**What I'd do (in order):**

1. Read `skills/software-development/SKILL.md` (done). No orchestration run is involved, so I'd skip the dispatch script and subagents.
2. Create one TodoWrite item for each of the five stages, and mark Stage 1 (Understand) in progress.
3. Write the Stage 1 checkpoint to `./.claude-skills-work/software-development/parse-date/progress.md`:
   ```
   # parse-date — Stage 1 (Understand) — BLOCKED on user input
   Task: function taking a date string -> parsed date value.
   Unknowns:
   - Language/module location (assumed: existing project, unknown stack)
   - Which input formats are needed today (concrete examples)
   - Return type (date vs datetime; tz-aware?)
   - Timezone/offset handling
   - Behavior on invalid input (raise vs return null)
   - Existing date utils/library in the codebase to reuse
   YAGNI flag: "any future format" is a hypothetical requirement; design for current formats only.
   Next: wait for answers, then Stage 2 plan.
   ```
4. Stop at the Stage 1 gate. I wouldn't write any code or tests and wouldn't touch project files.

**Reply to user:**

I need a few answers before I write this, so I don't end up guessing:

1. **Formats:** Which date strings do you need to parse now? A few real examples would help (e.g. `2026-11-23`, `23/11/2026`, `Nov 23, 2026`, ISO 8601 with time).
2. **Ambiguity:** For values like `03/04/2026`, should that be read as March 4 (US) or 3 April (EU)?
3. **Output:** Should it return a date only or a date with a time? If times are included, how should timezones or offsets be handled?
4. **Invalid input:** Should it raise an error or return null/None?
5. **Context:** Which language and module is this for? Is there already a date library in the codebase (e.g. `dateutil`, `date-fns`) that I should reuse instead of writing a new parser?

About "configurable and extensible for any future format": I'd build only for the formats you need now, with tests written first. The simplest version is a short ordered list of known formats, so adding one later is a one-line change plus a test. Building a plugin or config system for formats nobody has asked for yet would add complexity with no current benefit. If you have a concrete need for runtime configuration, such as formats that vary per customer, tell me and I'll plan for it.