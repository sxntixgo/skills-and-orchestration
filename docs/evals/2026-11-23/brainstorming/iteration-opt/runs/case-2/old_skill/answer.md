**What I'd do, in order:**

1. **TodoWrite** the five brainstorming steps: understand context → clarify intent → explore approaches → validate design in sections → write it to `docs/plans/` and hand off.

2. **Read the project before asking anything** (read-only):
   - `git log --oneline -20`
   - `README.md`, `package.json` / `pyproject.toml`, `docker-compose.yml`
   - Grep for the hot paths and existing caching: `rg -n "cache|redis|memo|lru" src/`, plus the route handlers and DB access layer.

   *Assumption:* this is a TypeScript/Express API on Postgres, running as 2+ instances behind a load balancer. No cache exists today. `docker-compose.yml` has no Redis. A few read-heavy endpoints, such as `GET /products` and `GET /products/:id`, make repeated DB queries.

3. **Write the checkpoint** `./.claude-skills-work/brainstorming/caching-layer/design.md`:
   ```markdown
   # Caching layer: WIP design
   ## Restated idea
   Add a cache in front of slow/repeated reads in the API to cut latency and DB load.
   ## Context (assumed from repo scan)
   - TS/Express API, Postgres, ≥2 instances, no existing cache, no Redis in compose
   - Read-heavy candidates: GET /products, GET /products/:id
   ## Open questions
   - [ ] Purpose: what problem prompted this (latency? DB load? cost? external API limits?)
   - [ ] Success criteria (numbers)
   - [ ] Staleness tolerance / invalidation needs
   - [ ] Constraints: new infra allowed?
   - [ ] Scope: which endpoints in/out
   ## Approaches (pending)
   ## Decisions
   ```

4. **No subagents and no code.** This skill only designs. "Whatever's best" depends on details the user hasn't given yet, so step 2 has to come first.

**Reply to the user:**

> Got it. You want a cache in front of the API's slow or repeated reads. From the repo, it looks like an Express + Postgres service with no caching yet, and the read-heavy endpoints are `GET /products` and `/products/:id`. Tell me if I've got that wrong.
>
> The best choice depends on what's hurting, so one question first:
>
> **What's the main reason you want caching?**
> (a) Pages or endpoints feel slow (latency)
> (b) The database is under too much load or costs too much
> (c) We call a rate-limited or slow external API
> (d) Something else
>
> My guess is (a). Is that right?

**Next turns (one question each):** acceptable staleness and how data gets invalidated, a concrete target such as "p95 under 100ms on `/products`", and whether adding Redis is OK. Once those are clear, I'd lay out three approaches and recommend one:

- **In-process LRU per instance:** simplest. Copies can disagree across instances, and the cache is lost on restart.
- **Shared Redis cache-aside:** every instance sees the same data. It adds one service to run.
- **HTTP caching (Cache-Control/ETag):** caches at the client or CDN with almost no server code. Gives the least control over invalidation.

After the user picks one, I'd present the design in sections and validate each one, then write it to `docs/plans/2026-11-23-caching-layer-design.md` and hand off to `writing-plans`.