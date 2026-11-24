**Answer:** I can't confirm it as stated. "Bun is the fastest" holds for startup, package installs and synthetic hello-world HTTP tests. It does not hold for every workload. In realistic I/O-bound apps (a real database, real middleware), Bun, Node and Deno come out within a few percent of each other. Node wins some workloads outright, such as HTTP/2, pipelining, uploads and allocation-heavy handlers. Bun also usually uses more memory in framework-heavy servers.

**Evidence:**
- **Bun's headline numbers are its own benchmarks.** It reports 48,243 vs 25,181 vs 19,243 req/s (Bun 1.4, Node 26.7, Deno 2.9.5) on an Express hello-world over HTTPS. Its Postgres test compares Bun's built-in driver against postgres.js, so it measures the driver and the runtime together. [1]
- **Under a realistic app the gap mostly disappears.** A URL shortener on Postgres (Fastify/Hono/Elysia; Node 24.4, Deno 2.4, Bun 1.2.18) measured about 12.0K req/s for Node and about 12.4K for both Deno and Bun (July 2025). [2] A Node vs Bun peer-reviewed study (JCSI, Sept 2025) reportedly found I/O-bound HTTP roughly tied, 27.5K for Bun vs 28.2K for Node, with Bun using more memory. [3][4]
- **Results depend heavily on the workload.** In HttpArena, Bun ranked #1 of 47 on the mixed workload and beat Node by about 20% on JSON. But Node was about 5x faster on pipelining, about 4x faster on HTTP/2 and about 3.5x faster on uploads. [5] Bun's own GitHub investigation, as reported by Strapi, had Node ahead on allocation-heavy HTTP: 16.2K vs 11.8K req/s. [3]
- **Bun's advantages that hold up:**
  - Package installs: 1.41 s cold vs 13–20 s for pnpm, npm and Yarn. These are vendor numbers, but every source agrees on the direction. [1][3]
  - CPU-bound recursion: Fibonacci(40) in 561 ms vs 750 ms. [3]
  - JSON.stringify: about 1.5x faster (June 2026 issue). [3]
- **Memory goes the other way.** An idle Next.js standalone server used 179–318 MB on Bun vs about 80 MB on Node 24 (Bun issue). [3]

**Disagreements / single-source claims:**
- **The JCSI numbers are second-hand.** They come only through Strapi's summary. The journal page confirms the study exists (Kalman & Miłosz, Node vs Bun only), but it doesn't show the results.
- **Single-source figures.** The allocation-heavy and memory numbers come from Bun GitHub issues as reported by Strapi. The HttpArena numbers come from one write-up whose year and versions aren't stated.
- **Ownership.** One critique notes that Anthropic acquired Bun in late 2025. That's relevant context for Bun-favorable claims, but I didn't verify it myself.

**Confidence:** Medium-high on the overall conclusion, because every independent source agrees that Bun leads on synthetic tests and the gap narrows under real I/O. Confidence is low on any exact multiplier, since hardware, versions and frameworks differ across tests.

**Gaps:**
- I didn't open the JCSI PDF, the Bun GitHub issues or the HttpArena repo.
- I didn't find a single controlled, current benchmark covering all three runtimes.
- For your own decision, benchmark your actual workload.

**Sources:**
- [1] Bun homepage benchmarks — Oven/Bun, current (Bun 1.4), https://bun.sh
- [2] "Myth vs Reality: Real-world runtime performance of Node.js, Deno and Bun" — Mayank Choubey, HackerNoon, 2025-07-21, https://hackernoon.com/myth-vs-reality-real-world-runtime-performance-of-nodejs-deno-and-bun
- [3] "Bun vs Node.js performance comparison guide" — Strapi, 2026-04-19 (updated 2026-09-14), https://strapi.io/blog/bun-vs-nodejs-performance-comparison-guide
- [4] "Comparative analysis of JavaScript runtime environments" — Kalman & Miłosz, Journal of Computer Sciences Institute vol. 36, 2025-09-30, https://ph.pollub.pl/index.php/jcsi/article/view/7512
- [5] "Bun HTTP server: #1 in mixed workloads, #41 in pipelining — HttpArena deep dive" — DEV Community, Mar 27 (year not stated), https://dev.to/fbio_reis_355b87b508598e/bun-http-server-1-in-mixed-workloads-41-in-pipelining-the-full-picture-httparena-deep-dive-4h6e

In a real session I'd also save the notes and source list to `./.claude-skills-work/online-research/bun-fastest-runtime/notes.md`. That file wasn't written in this dry run.