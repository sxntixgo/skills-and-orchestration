**What I'd do, in order:**

1. **TodoWrite** with these items: Context → Clarify intent → Choose approach → Design in sections → Write `docs/plans/` → Hand off to `writing-plans`.
2. **Read the project state** (read-only): `README.md`, the dependency manifest (`package.json` / `pyproject.toml`), `docker-compose.yml`, the data-access and HTTP layers, and `git log --oneline -20`.
   *Assumed findings:* a Python/FastAPI REST API on Postgres, a single app instance behind a load balancer, no Redis in `docker-compose.yml`, no caching today, and recent commits about slow `GET /products` list and detail endpoints.
3. **Create the work-in-progress design file** `./.claude-skills-work/brainstorming/caching-layer/design.md`:
   ```markdown
   # Caching layer — WIP design
   ## Status: clarifying intent (turn 1)
   ## Known context (assumed)
   - FastAPI + Postgres, single instance, no Redis, no caching yet
   - Recent work: slow GET /products list/detail
   ## Open questions
   - Purpose: what's slow / what problem? ← asking now
   - Success criteria (p95 target?), staleness tolerance, scope
   ## Candidates
   - A: in-process TTL cache on hot read functions
   - B: Redis cache-aside in the service layer
   - C: HTTP caching (Cache-Control/ETag) / CDN
   ## Current lean: A (pending answer)
   ```
4. **No code, no subagents, no task plan.** I'd send the reply below and wait for the answer.

---

**Reply to the user:**

I won't build a cache until I know what problem it solves, because "best" depends on that. Here's my read so far.

**My understanding:** you want to speed up reads, and I'm assuming that means the slow `GET /products` endpoints from the recent commits. I'm also assuming one app instance on Postgres with no Redis yet, and that data a few seconds or minutes old is acceptable.

**Options:**
- **A. In-process TTL cache on the hot read functions.** Zero new infrastructure, about a day of work, and easy to remove later. Each instance keeps its own copy, though, so it stops working well once you scale out or need instant invalidation.
- **B. Redis cache-aside in the service layer.** Shared across instances, with explicit invalidation on writes. It adds a new service to run and monitor, plus invalidation bugs to get right.
- **C. HTTP caching (Cache-Control/ETag, optionally a CDN).** Needs almost no server code and also helps clients. It only fits public or rarely changing GET responses, and you have little control over invalidation.

**My recommendation is A.** It meets today's need with the least risk and is easy to reverse. That changes if you run several instances or users must see writes immediately, in which case B is the better choice. A general-purpose caching layer can wait until a second use case actually shows up.

**One question:** what's driving this?
(a) specific endpoints are too slow (which ones, and what p95 are you aiming for?)
(b) database load or cost is too high
(c) an external API is slow or rate-limited
(d) something else