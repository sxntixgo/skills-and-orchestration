**What I'd do (dry run; the searches and fetches below really ran):**

1. **Clarify:** The question isn't ambiguous enough to stop and ask. The real question is whether Bun is the fastest JS runtime, and on which workloads. This changes over time, so I need current versions (Nov 2026).
2. **Write notes:** `./.claude-skills-work/online-research/bun-runtime-speed/notes.md` would hold:
   - The sub-questions:
     - What Bun itself claims.
     - What independent micro-benchmarks show.
     - What realistic, I/O-bound app benchmarks show.
     - What peer-reviewed studies show.
   - The query plan.
   - A source log with URL, publisher, date, claims and a credibility note for each.
   - Checkpoints after each gather round.
3. **Gather:** 4 WebSearches. I fetched bun.sh, the HttpArena post, the HackerNoon real-app benchmark, the JCSI 2025 paper and the mistval post.
4. **Triangulate:** I marked the vendor numbers as biased and the HttpArena and HackerNoon results as single-author. The JCSI paper's numbers are unverified because its PDF wouldn't decode. I ignored SEO "2026 comparison" posts whose numbers conflict.

---

**Final reply:**

**Not as a blanket statement.** Bun is usually fastest on simple HTTP benchmarks, startup and package installs. On realistic apps the lead mostly disappears, and on some workloads Node wins.

**Where Bun clearly leads (mostly Bun's own numbers):**
- **Bun's homepage:** Bun 1.4 does 48,243 req/s on a hello-world Express-over-HTTPS test. Node 26.7 does 25,181 and Deno 2.9.5 does 19,243. Bun also roughly doubles Node on Postgres queries ([bun.sh](https://bun.sh/)).
- **Caveats:** This is a vendor benchmark of minimal workloads. Reproduction scripts are published, but I didn't run them.

**Where the lead shrinks or flips (independent tests):**
- **Realistic app:** A URL shortener with JSON parsing, validation and Postgres through an ORM (Node 24.4 / Deno 2.4 / Bun 1.2.18):
  - Node got about 12K RPS; Deno and Bun got about 12.4K.
  - The author calls the gap marginal, "certainly not the 2x or 3x improvement often claimed."
  - Source: [HackerNoon, Jul 2025](https://hackernoon.com/myth-vs-reality-real-world-runtime-performance-of-nodejs-deno-and-bun).
- **HttpArena suite:** The results are mixed ([DEV deep dive](https://dev.to/fbio_reis_355b87b508598e/bun-http-server-1-in-mixed-workloads-41-in-pipelining-the-full-picture-httparena-deep-dive-4h6e)):
  - Bun is #1 of 47 on the mixed workload and about 20% faster than Node on JSON.
  - Node is about 5x faster on pipelining, about 3.5x faster on uploads and about 4x faster on HTTP/2.
  - Deno edges out Bun on compression.
- **Why it matters little in practice:** Most web servers are I/O-bound, so a faster engine barely changes end-to-end latency ([mistval, 2022](https://www.dev.to/mistval/when-faster-isnt-better-4f19)). This is reasoning, not measurement.

**Unverified:** A 2025 peer-reviewed paper in JCSI (Kalman et al.) reportedly found HTTP throughput about equal (Bun ~27.5K vs Node ~28.2K req/s), with Bun faster on compute. That comes from a secondary summary ([Strapi](https://strapi.io/blog/bun-vs-nodejs-performance-comparison-guide)). I couldn't extract the [paper's PDF](https://ph.pollub.pl/index.php/jcsi/article/download/7512/5142/36452) to confirm it.

**Confidence:** High that "fastest" depends on the workload. Medium on the exact numbers, since they come from single-author or vendor sources and use different versions and hardware.

**Gaps:**
- I found no independent audit of Bun's current homepage numbers.
- I found no recent peer-reviewed study comparing all three runtimes under the same conditions.

If speed matters for your decision, benchmark your own workload on current versions.

Sources:
- [bun.sh](https://bun.sh/)
- [HackerNoon: Myth vs Reality](https://hackernoon.com/myth-vs-reality-real-world-runtime-performance-of-nodejs-deno-and-bun)
- [HttpArena deep dive (DEV)](https://dev.to/fbio_reis_355b87b508598e/bun-http-server-1-in-mixed-workloads-41-in-pipelining-the-full-picture-httparena-deep-dive-4h6e)
- [When faster isn't better (DEV)](https://www.dev.to/mistval/when-faster-isnt-better-4f19)
- [Strapi: Bun vs Node.js](https://strapi.io/blog/bun-vs-nodejs-performance-comparison-guide)
- [JCSI paper PDF](https://ph.pollub.pl/index.php/jcsi/article/download/7512/5142/36452)