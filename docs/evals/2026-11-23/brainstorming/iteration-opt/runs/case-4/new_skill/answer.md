**What I'd do, in order:**

1. **TodoWrite** with the skill's steps:
   - Context: read the project state
   - Clarify intent (restate, candidates, one question per turn)
   - User chooses an approach
   - Design in sections, validated one by one
   - Write `docs/plans/YYYY-MM-DD-api-style-design.md` and hand off to `writing-plans`

2. **Context.** Read the README, any existing API code or OpenAPI/GraphQL schema files, `package.json` or the equivalent, and `git log --oneline -20`. This is a dry run, so I assume what they would show: a typical web backend, no existing public API, and a web frontend as the first consumer. Nothing points to GraphQL tooling already being in place.

3. **Write** a work-in-progress file at `./.claude-skills-work/brainstorming/api-style/design.md`:
   ```markdown
   # API style: REST vs GraphQL (WIP)
   ## Assumptions
   - New API, no existing public API to stay compatible with
   - First consumer: our own web frontend
   - Team has no GraphQL in production yet
   ## Candidates
   - A: REST + OpenAPI
   - B: GraphQL
   - C: REST now, BFF/GraphQL layer later if needed
   ## Open question
   - Who consumes the API and how varied are their data needs?
   ## Decisions
   (none yet)
   ```

4. **Reply to the user:**

---

You want to pick an API style for a new backend. I'm assuming it's a new API, your own web frontend is the first client, and your team doesn't run GraphQL in production yet.

**Options:**
- **(A) REST + OpenAPI.** Simplest to build and run: HTTP caching, rate limiting and monitoring work out of the box, and every client and tool understands it. Downside: when screens need data from several resources, you get chatty calls or a growing set of custom endpoints.
- **(B) GraphQL.** Clients fetch exactly what they need in one request, and the typed schema makes it easy to change over time. Downside: more server work (N+1 queries via DataLoader, limits on query cost and depth, field-level auth), harder caching, and a learning curve for the team.
- **(C) REST now, add a GraphQL or backend-for-frontend layer later only if clients need it.** It keeps your options open, but you may end up running two API styles.

**I'd lean to (A)** because it's cheaper and easier to run for a first API with one known client. That changes **unless** you have several clients with very different data needs, such as web plus mobile plus third parties, each wanting a different shape of deeply nested data. Then (B) pays for itself.

**One question:** who will use this API in the next 6–12 months?
(a) Only our own web frontend
(b) Our web app plus mobile apps, with different screens and data needs
(c) External or third-party developers (a public API)
(d) Other internal services (service-to-service)