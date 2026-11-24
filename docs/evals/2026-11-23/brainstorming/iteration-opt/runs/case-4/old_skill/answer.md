**What I'd do, in order:**

1. **TodoWrite** with the five skill steps:
   - Understand context
   - Clarify intent (one question per turn)
   - Explore approaches (REST / GraphQL / hybrid) and recommend one
   - Present the design in sections
   - Write `docs/plans/2026-11-23-api-style-design.md` and hand off to `writing-plans`

2. **Read the project context** with no commands run in this dry run. I'd check the README, `docs/`, existing route or schema files, `package.json` or an equivalent, and `git log --oneline -20`.
   - **What I assume I find:** a backend repo with no existing public API layer and no GraphQL dependencies. I don't know who the clients are, so that's the first question.

3. **Write the checkpoint** `./.claude-skills-work/brainstorming/api-style/design.md`:
   ```markdown
   # API style: REST vs GraphQL (work in progress)
   ## Idea (restated)
   Choose the interface style for a new API before building it.
   ## Known
   - No existing API layer found (assumed); no GraphQL deps.
   ## Open questions
   - Who are the consumers? (asking now)
   - Data shape / query variety, team familiarity, caching/perf needs, deadline
   ## Decisions
   (none yet)
   ```

4. **No subagents and no code.** The step 2 gate requires clear intent before anything else, so I'd ask one question and wait.

**Final reply to the user:**

> I'll help you decide, but the answer depends on who will use the API. As I understand it, you're starting a new API from scratch and want to settle on REST or GraphQL before building it. Correct me if there's already an API this has to match.
>
> First question: **who will mainly use this API?**
> - (a) Your own frontend(s): a web app, mobile app, or both
> - (b) Outside developers or partners, as a public API
> - (c) Other internal services (service-to-service)
> - (d) A mix. Tell me which ones matter most.