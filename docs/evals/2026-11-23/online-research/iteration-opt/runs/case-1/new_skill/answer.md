I could only partly answer this. My search quota ran out after six calls, so I have current pricing for Pinecone and Qdrant only. Latency, Zilliz and Weaviate are unverified. Don't pick from this alone.

**Answer:** The two pricing models trade off in opposite directions:
- **Pinecone serverless charges per use.** That is cheap when traffic is low or bursty and gets expensive as query volume grows: you pay $16–18 per million read units, and the plan has a $50/month minimum.
- **Qdrant Cloud bills for the hardware you reserve, by the hour.** That costs more at low volume but stays flat and predictable when traffic is steady and heavy.

I haven't confirmed where Zilliz and Weaviate sit, or any latency numbers, in sources I could open.

**Evidence:**
- **Pinecone Standard** (pricing page, "Updated November 2026") [1]:
  - Storage $0.33/GB/month.
  - Reads $16–18 per million read units; writes $4–4.50 per million write units. Both vary by cloud and region.
  - $50/month minimum; usage counts toward it.
- **Pinecone Enterprise** [1]: reads $24–27 per million, writes $6–6.75 per million, $500/month minimum.
- **Pinecone Dedicated Read Nodes** [1]: an option where reads are billed at a fixed hourly rate instead of per read. The rate isn't published.
- **Pinecone price change:** reads cost about twice what they did at launch in 2024 ($8.25 per million). That figure comes from the search summary only, so it's a lead. Any blog post or comparison citing the old rates is out of date.
- **Qdrant Cloud** [2]:
  - Billed hourly for vCPU, RAM, cluster storage, backup storage and paid inference tokens.
  - No per-unit rates published; you estimate cost with their calculator.
  - Free tier: 0.5 vCPU, 1 GB RAM, 4 GB disk.
  - Standard tier: 99.5% uptime SLA. Premium tier: 99.9% SLA and a minimum spend.

**Disagreements / single-source claims:**
- Each pricing fact rests on the vendor's own page, which is the authoritative source for its own prices, but nothing independent confirms it.
- Third-party summaries of Qdrant pricing contradict each other. One claims "$0.80 per 1M vectors/month", which doesn't match Qdrant's own hourly-resource billing. I ignored them.

**Unverified, from memory only:**
- **Latency:** Clusters you provision yourself (Qdrant, Zilliz Dedicated, Weaviate) usually give lower and steadier p99 latency. Serverless offerings that keep data in object storage (Pinecone serverless, Zilliz Serverless) can be slower on rarely queried data and less consistent at the tail.
- **Benchmarks:** The public benchmarks (VectorDBBench from Zilliz, Qdrant's own benchmarks) are run by vendors and tend to favour their authors.
- **Weaviate:** I believe it moved to tiered plans in 2025, but I didn't check current figures.

**Confidence:** Medium for the Pinecone and Qdrant pricing structure. Low for the overall comparison.

**Gaps:**
- Zilliz pricing (serverless and dedicated rates).
- Weaviate pricing and minimums.
- Pinecone Dedicated Read Node rates.
- An independent latency benchmark from 2026.

**What I'd do next:**
1. Finish the research when the quota resets: zilliz.com/pricing, weaviate.io/pricing, and VectorDBBench results checked against at least one non-vendor benchmark.
2. Send me your numbers and I'll price all four for your actual workload:
   - number of vectors and dimensions
   - peak and average queries per second
   - p99 latency target
   - whether you filter on metadata
   - cloud and region
3. The fastest reliable way to decide this week: load a sample of your own data into the top two candidates' free tiers and measure p99 yourself.

I'd normally log notes and sources to `./.claude-skills-work/online-research/vector-db-pricing/notes.md`, but I had no write tool in this session, so it wasn't created.

**Sources:**
[1] [Pinecone Pricing](https://www.pinecone.io/pricing/), Pinecone, updated Nov 2026
[2] [Qdrant Cloud Pricing](https://qdrant.tech/pricing/), Qdrant, undated (© 2026)