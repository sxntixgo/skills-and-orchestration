Short answer: **Zilliz Cloud (managed Milvus) gives the most throughput per dollar on dedicated clusters, Qdrant Cloud is second, and Pinecone is easiest to start with on pure pay-per-use but costs the most once you have heavy query traffic.** Weaviate has the cheapest published per-dimension rates for small to mid indexes, but I found no good managed latency data for it. Confidence is medium on pricing, because I read it on the vendors' own pages. It's low to medium on latency, because the only head-to-head test of managed services was run by Zilliz, and the other source doesn't name where its numbers came from.

**What I did:** I followed `skills/online-research/SKILL.md` and its `references/source-evaluation.md`. I ran five searches, then opened all four pricing pages, Zilliz's VectorDBBench leaderboard, Qdrant's benchmark page and one independent 2026 write-up. In a real session I'd also track progress with TodoWrite and save notes and sources to `./.claude-skills-work/online-research/vector-db-latency-pricing/notes.md`. I couldn't write files in this run, so that step was skipped.

## Latency at the same spend (1M × 768-dim vectors, about $1,000/mo setup)

| Service | p99 | QPS | Recall |
|---|---|---|---|
| Zilliz Cloud 8 CU (perf) | 2 ms | 13,316 | 0.94 |
| Qdrant Cloud 16c/64g | 6.4 ms | 1,242 | 0.95 |
| Pinecone p2.x8 (pod-based, not serverless) | 13.7 ms | 1,147 | 0.93 |
| Weaviate Cloud | not tested | – | – |

Source: [Zilliz VDBBench leaderboard](https://zilliz.com/vdbbench-leaderboard). Zilliz runs this benchmark, so expect bias in its favour, and the page gives no date. Under constant writes at 10M vectors, Zilliz drops to 2,119 QPS, Pinecone to 367 and Qdrant to 394.

- **Second source:** an independent [2026 write-up](https://buttondown.com/ultradune/archive/eval-002-vector-databases-in-2026-qdrant-vs) gives the same order: Milvus about 4 ms, Qdrant about 5 ms, Pinecone about 10 ms and Weaviate about 12 ms at p99. However, it doesn't name its benchmark sources, so it's only weak support.
- **Qdrant's own benchmarks** ([qdrant.tech/benchmarks](https://qdrant.tech/benchmarks/)) claim Qdrant leads, but they're from 2024 and self-hosted only, so they don't help with the managed services.
- **Conclusion:** Zilliz and Qdrant come out ahead of Pinecone on latency in both sources. The size of the Zilliz lead is vendor-measured. Weaviate's position is unverified.

## Pricing (from the official pages, November 2026)

- **Pinecone** ([pricing](https://www.pinecone.io/pricing/), updated Nov 2026):
  - Standard plan has a $50/mo minimum.
  - Reads cost $16–18 per million read units and writes $4–4.50 per million write units.
  - Storage is $0.33/GB/mo.
  - Dedicated Read Nodes have a fixed hourly rate that isn't published.
  - This is cheapest for low or uneven query traffic. It gets expensive as query volume grows, because every query is billed.
- **Zilliz Cloud** ([list prices](https://zilliz.com/pricing/pricing-guide)):
  - Dedicated compute is $0.273 per CU-hour, about $200 per CU per month.
  - Storage is $0.025/GB/mo.
  - The serverless rate wasn't shown for the default region. A third-party tracker says $4 per million vCUs, but that's the only source for it.
  - Best throughput per dollar, but you pay for capacity even when it sits idle.
- **Qdrant Cloud** ([pricing](https://qdrant.tech/pricing/)):
  - Billed hourly for vCPU, RAM and storage.
  - No unit prices are published, so you have to use the calculator at cloud.qdrant.io.
  - Free tier: 1 GB RAM, 4 GB disk.
  - The page contradicts itself on uptime guarantees (99.5% or 99.9% for Standard).
- **Weaviate Cloud** ([pricing](https://weaviate.io/pricing), updated 2026-11-02):
  - Flex: $45/mo minimum, $0.00465 per million vector dimensions, $0.12/GiB storage, 99.5% uptime.
  - Premium Dedicated: $0.002718 per million dimensions, 99.95% uptime, sold through sales.
  - Example: 10M vectors × 1536 dims comes to about $71/mo on Flex for dimensions, plus storage. That's my calculation.

## What to pick this week (my reading)

- **Low or uneven traffic, smallest ops burden:** Pinecone serverless, or Weaviate Flex.
- **Steady high QPS or tight p99 targets:** Zilliz dedicated, or Qdrant if you want open-source portability and good filtered search.
- **Before you sign:** load 1M of your own vectors, with your real filters, into the two finalists' free tiers. Then measure p99 with VectorDBBench, which is open source. Every number above depends heavily on the setup.

**Gaps:**
- No managed latency data for Weaviate.
- No published Qdrant prices.
- Pinecone's latency here is for pod-based indexes, not serverless.
- Price comparisons are rough because the vendors bill in different units (read units, CUs, vCPU-hours, dimensions).

If you send me your vector count, dimensions, queries per second and filter use, I can work out actual monthly costs for each.