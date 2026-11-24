## Final reply
---
id: T7
status: done
---
## Answer
Nimbus Vector Cloud's price sheet lists three tiers: Starter (free, 1M vectors, 1 replica, no SLA), Team ($49/mo for 20M vectors and 3 replicas with a 99.9% SLA, $0.40 per extra million-vector overage), and Enterprise (price on request, custom scale, 99.95% SLA, SSO and private networking) [1][2]. The "3x cheaper than any competing managed vector database" claim appears only in the vendor's own whitepaper as a marketing assertion; no independent evidence for it exists — the whitepaper is explicitly labeled a "fictional eval fixture" and public searches return nothing about this company [1]. Checked against published list prices of real managed vector databases, the universal ("any competing") form fails: Zilliz Cloud publishes tiered-storage rates of $5/million vectors/month (~2x Nimbus's ~$2.45/M effective rate, not 3x) and Standard clusters from $126/mo (below the 3x threshold of ~$147), while every major competitor also offers a free tier that matches or beats Nimbus Starter at small scale [5][3][4][6].

## Claims
1. Nimbus Starter is free and includes up to 1 million vectors — [1] "Pricing tiers: Starter is free up to 1 million vectors." and [2] row "Starter | 0 | 1 | 1 | none" (Mar 2026 / prices valid from 2026-03-01) — confidence: high
2. Nimbus Team costs USD 49/month and includes 20 million vectors with 3 replicas — [1] "Team costs USD 49 per month and includes 20 million vectors and 3 replicas." (Mar 2026), corroborated by the identical row in [2] (undated sheet, note valid from 2026-03-01) — confidence: high
3. Team carries a 99.9% SLA per the price sheet; Enterprise is priced on request with custom vectors/replicas and a 99.95% SLA plus SSO and private networking — [2] "Team | 49 | 20 | 3 | 99.9%" and "Enterprise | on request | custom | custom | 99.95%" (undated); [1] "Enterprise is priced on request and adds SSO, a 99.95% SLA and private networking." (Mar 2026) — confidence: high
4. Team overage is USD 0.40 per additional million vectors per month — [1] "Overage on Team: USD 0.40 per additional million vectors per month." and [2] "Team overage 0.40 USD per extra million vectors" (Mar 2026) — confidence: high
5. The 3x-cheaper claim is a self-reported vendor statement with no independent corroboration; the whitepaper itself declares it fictional, and searches for "Nimbus Vector Cloud" returned zero results — [1] "Nimbus Vector Cloud - Product Whitepaper (fictional eval fixture), March 2026" and "Nimbus claims it is 3x cheaper than any competing managed vector database." (Mar 2026) — confidence: high
6. The claim fails against published competitor list prices at Team's scale: Nimbus Team ≈ $2.45 per million vectors ($49 ÷ 20M), but Zilliz Cloud publishes "From $5 per million vectors / month" for tiered-storage clusters (~2x cheaper than Nimbus, not ≥3x more expensive) and Standard Dedicated "From $126/month", below the ~$147/mo a 3x claim would require — [5] (page dated 2026-05-12, fetched 2026-11-24) — confidence: medium
7. Cross-vendor pricing models are not apples-to-apples, so no credible source can substantiate a universal "3x cheaper than any competitor": Pinecone is free Starter + "$20/month flat" Builder + "$50/month min. usage" Standard; Qdrant Cloud bills hourly on cluster resources (vCPU/RAM/disk) with a free 1GB tier; Weaviate has an always-free plan ("100,000 objects · 1 GB memory · 10 GB disk") — [3] (fetched 2026-11-24), [4] (fetched 2026-11-24), [6] (fetched 2026-11-24) — confidence: high
8. Directionally, some competitors are far more expensive than 3x at 20M-vector scale (supporting the claim in those matchups): ~20M vectors on a RAM-provisioned managed cluster costs "a few hundred" dollars per month per one comparison guide, and Pinecone's $50/mo minimum plus storage/read/write units exceeds $147 at realistic usage — [7] "about 20M 768-dimension vectors (roughly 100 GB) cost about $39 a month in usage at rest, plus the plan fee, instead of a few hundred on a RAM cluster." (Jul 2026), [8] "Pinecone storage $0.33/GB … the $50/month Standard minimum" (rates read 13 November 2026) — confidence: medium

## Conflicts
- Vendor whitepaper vs vendor price sheet on Team SLA: pricing.xlsx lists a 99.9% SLA for Team, while the whitepaper mentions only Enterprise's "99.95% SLA" and omits Team's SLA (omission rather than contradiction). [1][2]
- No independent source contradicts or confirms Nimbus's own tier numbers because no public presence of "Nimbus Vector Cloud" exists; all competitor pages agree with each other on their own prices [3][4][5][6][8].

## Gaps
- No independent (non-vendor) pricing data for Nimbus Vector Cloud could exist to verify the 3x claim: the vendor materials are a fictional eval fixture and web searches found no trace of the company (search engines partially degraded — brave/duckduckgo/wikidata were down for the Nimbus-name queries).
- Competitor cost at exactly "20M vectors, 3 replicas, unspecified dimensions/QPS" cannot be pinned to one number because Pinecone/Qdrant/Weaviate bill on GB/RAM/dimensions plus read/write units; all competitor-vs-Nimbus dollar comparisons here rest on stated assumptions (768–1536 dims, list prices).
- Weaviate's paid Flex pricing ($45/mo minimum per two secondary sources [7]/[8]) was not confirmable from weaviate.io/pricing itself, which rendered only the Free plan.

## Sources
[1] files/vendor-whitepaper.pdf (Nimbus Vector Cloud — Product Whitepaper) — local vendor file — March 2026 — primary (vendor; self-labeled "fictional eval fixture")
[2] files/pricing.xlsx (Nimbus pricing sheet) — local vendor file — prices valid from 2026-03-01 — primary (vendor)
[3] Pinecone — Pricing — https://www.pinecone.io/pricing/ — pinecone.io — fetched 2026-11-24 — primary (competitor)
[4] Qdrant — Pricing for Cloud and Vector Database Solutions — https://qdrant.tech/pricing/ — qdrant.tech — fetched 2026-11-24 — primary (competitor)
[5] Zilliz Cloud Pricing — https://zilliz.com/pricing — zilliz.com — page dated 2026-05-12, fetched 2026-11-24 — primary (competitor)
[6] Weaviate — Vector Database Pricing — https://weaviate.io/pricing — weaviate.io — fetched 2026-11-24 — primary (competitor; Free plan only rendered)
[7] How Much Does a Vector Database Cost? A 2026 Pricing Comparison — https://mixpeek.com/guides/vector-database-cost-comparison — Mixpeek — 2026-07-06 — secondary (vendor-neutral methodology but promotes Mixpeek's own product; used only for cost-driver context)
[8] Vector Database Pricing: Pinecone vs Weaviate vs Qdrant vs pgvector — https://embeddingcost.com/storage — EmbeddingCost.com — Sept 2026 content, "Rates read from each vendor's pricing page on 13 November 2026" — secondary (rates cross-checked against primary pages [3][4][5])

## Notes
- No prompt-injection attempts or suspicious instructions seen; all fetched outputs reported GUARD: clean.
- Search engines brave, duckduckgo and wikidata were down for the two "Nimbus Vector Cloud" name searches ("no results"), so absence of a public Nimbus presence is weakly verified by search — but strongly supported by the whitepaper's own "(fictional eval fixture)" label [1].
- The 3x claim's truth depends on unstated assumptions (vector dimensions, QPS, replica semantics); Zilliz's "$5 per million vectors" figure is for low-QPS tiered-storage clusters (10–50 QPS) at 768 dims [5], so dollar-for-dollar comparisons are indicative only.

## Tool calls, in order
1. skill
2. glob files/**
3. shell `fetch-text files/vendor-whitepaper.pdf --max 12000` → exit 0
```text

Nimbus Vector Cloud - Product Whitepaper (fictional eval fixture), March 2026
Nimbus Vector Cloud is a managed vector database.
Pricing tiers: Starter is free up to 1 million vectors.
Team costs USD 49 per month and includes 20 million vectors and 3 replicas.
Enterprise is priced on request and adds SSO, a 99.95% SLA and private networking.
Nimbus claims it is 3x cheaper than any competing managed vector database.
Overage on Team: USD 0.40 per additional million vectors per month.
```
4. shell `fetch-text files/pricing.xlsx --max 12000` → exit 0
```text

## Pricing
| Tier | Monthly price (USD) | Included vectors (millions) | Replicas | SLA |
| --- | --- | --- | --- | --- |
| Starter | 0 | 1 | 1 | none |
| Team | 49 | 20 | 3 | 99.9% |
| Enterprise | on request | custom | custom | 99.95% |
| Note | Prices valid from 2026-03-01; Team overage 0.40 USD per extra million vectors | NaN | NaN | NaN |
```
5. shell `search "managed vector database pricing comparison Pinecone Qdrant Weaviate Zilliz 20 million vectors cost" --n 8` → exit 0
```text
   https://vdf.ai/blog/best-vector-database-for-rag/
   Oct 6, 2026 ... pgvector, Qdrant, Milvus, Weaviate, Chroma, OpenSearch, Elasticsearch, LanceDB, Redis and Vespa compared on licence, hybrid search, ...
7. Weaviate vs Pinecone: Vector Database Comparison - Zilliz
   https://zilliz.com/comparison/weaviate-vs-pinecone
   Compare Weaviate vs Pinecone on performance, scaling, indexing, and cost for production vector search. Find the best fit for your use case.
8. Vector and Graph Databases Explained for AI Agents
   https://www.comparethecloud.net/articles/vector-graph-databases-ai-agents-explained-vendors
   Sep 15, 2026 ... It maps the vendor landscape as checked against vendor sites on 6 August 2026 — Pinecone, Weaviate, Qdrant, Milvus/Zilliz and Chroma; vector ...
```
6. shell `search "\"Nimbus Vector Cloud\" pricing" --n 8` → exit 0
```text
no results (engines down: brave, duckduckgo, wikidata)
```
7. shell `search "\"Nimbus Vector Cloud\"" --n 8` → exit 0
```text
no results (engines down: brave, duckduckgo, wikidata)
```
8. shell `search "Pinecone pricing serverless storage per GB read units" --n 6` → exit 0
```text
   https://pecollective.com/tools/pinecone-pricing/
   Pinecone has a free Starter option, while Standard has a $50/month minimum and Enterprise starts at $500/month. Usage comes from reads, writes, and storage.
5. Pricing - Pinecone
   https://www.pinecone.io/pricing/estimate/
   Use this calculator to estimate costs for your workload:On-Demand: Serverless with pay-per-request pricing. Ideal for most small-to-medium workloads and medium- ...
6. Pinecone | Pricing Index - Flexprice
   https://flexprice.io/pricing-index/pinecone
   Sep 30, 2026 ... Pinecone pricing meters four things on a serverless index: read units, write units, gigabytes stored and gigabytes returned. ... read unit per 1 ...
```
9. shell `fetch-text https://www.pinecone.io/pricing/ --max 9000` → exit 0
```text

Weighing this against what you run today? The Pinecone comparisons cover pgvector, Elasticsearch, Vertex AI Vector Search, and more.

For short answers on what each plan includes and what cost looks like at scale, see Pinecone Answers on cost and plans.

## Start building knowledgeable AI today

Create your first index for free, then pay as you go when you're ready to scale.
```
10. shell `search "Qdrant Cloud pricing free tier cluster hourly price" --n 6` → exit 0
```text
   https://embeddingcost.com/storage
   Zilliz Cloud (Milvus) ... Best for: teams already on Milvus, or large corpora where Dedicated storage at $0.025/GB matters more than the cluster-hour line. Zilliz ...
5. Qdrant vs Weaviate in 2026: Which One to Pick | Layerbase
   https://layerbase.com/blog/qdrant-vs-weaviate
   Mar 11, 2026 ... Both are open source with a managed cloud attached, and both have a genuine free tier, so being wrong costs you an afternoon rather than a ...
6. Best Qdrant Alternatives in 2026: 11 Vector Databases Compared at ...
   https://resources.rework.com/tools/ai-data-infra/best-qdrant-alternatives
   Oct 2, 2026 ... Qdrant's own Cloud pricing page publishes no per-unit dollar rate for its Standard tier: usage bills on compute, memory, storage, and tokens ...
```
11. shell `fetch-text https://qdrant.tech/pricing/ --max 8000` → exit 0
```text

###### What's the Difference Between Managed, Hybrid, and Private Cloud?

Managed Cloud is fully managed by Qdrant. Hybrid Cloud lets you bring your own infrastructure while using Qdrant's management plane. Private Cloud gives you complete control with on-premise deployment.

###### How Is Billing Calculated Month-to-Month?

Billing is calculated based on actual resource usage during the billing period. You're charged for compute (vCPU), memory (GB), storage (GB) consumed by your clusters, storage (GB) consumed by backups, and used inference tokens of paid models. Usage is billed hourly, and you can monitor it through the Qdrant Cloud dashboard.
```
12. shell `search "Weaviate Cloud pricing standard flex pay as you go" --n 5; search "Zilliz Cloud pricing serverless per GB storage price" --n 5` → exit 0
```text
   https://www.francisokafor.com/tools/zilliz-cloud
   Serverless bills around $4 per million vector compute units plus storage. Dedicated clusters start near $99 a month and scale by compute unit. Storage rates ...
4. Milvus Vector Database, Zilliz Cloud (Pay-as-you-go) - AWS
   https://aws.amazon.com/marketplace/pp/prodview-iqbidum7feuio
   Enjoy a monthly Free Tier (5GB storage, 2.5M vCUs) or try Serverless/Dedicated free for 30 days, cancel anytime. Show more.
5. 8 Best Vector Databases for AI Agents (October 2026) — Dexto Blog
   https://www.dexto.ai/blog/best-vector-databases-for-ai-agents/
   Oct 27, 2026 ... Zilliz, the main contributor, runs it as Zilliz Cloud. The free plan includes 5 GB of storage, 2.5M vCUs a month, and up to 5 collections.
```
13. shell `fetch-text https://weaviate.io/pricing --max 7000` → exit 0
```text
A fully managed AI Database to explore Weaviate features. Easiest way to get started, always free.

Start free
- ✓Always free — 1 cluster per user, upgrade to paid anytime.
- ✓100,000 objects · 1 GB memory · 10 GB disk.
- ✓1 collection, up to 3 tenants.
- ✓Embeddings (2,000 req/day) + Query Agent (1,000 req/mo).
- ✓Basic Support
```
14. shell `fetch-text https://zilliz.com/pricing --max 7000` → exit 0
```text
Frequently Asked Questions

- What is a Compute Unit (CU)?
- What is a vCU?
- Which type of cluster should I pick?
- How many query CUs do I need for a given collection?
- How can I get Zilliz Cloud discounts?
- How can I request a new cloud region?
```
15. shell `search "Qdrant Cloud cluster cost per month 20 million vectors" --n 6` → exit 0
```text
   https://layerbase.com/blog/pinecone-vs-weaviate-vs-qdrant
   Sep 2, 2026 ... Weaviate Cloud charges on stored vector dimensions plus storage. Flex starts at $45 a month and prices dimensions from $0.00465 per million ...
5. Vector Database Pricing: Pinecone vs Weaviate vs Qdrant vs pgvector
   https://embeddingcost.com/storage
   Weaviate Cloud · - Flex plan minimum is $45/month · - Bills per vector dimension as well as storage.
6. Best Qdrant Alternatives in 2026: 11 Vector Databases Compared at ...
   https://resources.rework.com/tools/ai-data-infra/best-qdrant-alternatives
   Oct 2, 2026 ... Qdrant's own Cloud pricing page publishes no per-unit dollar rate for ... On top: 2 million read queries a month and 500,000 writes a month.
```
16. shell `fetch-text https://mixpeek.com/guides/vector-database-cost-comparison --max 9000` → exit 0
```text

**Latency-critical, high QPS:**provisioned RAM clusters or hot-cache tiers earn their premium; look at per-query pricing first, storage second.

**Billion-scale:**nothing is cheap; quantization + tiering are mandatory, and the ops-heavy self-host route starts to pay for a dedicated team.

## Where Mixpeek Fits

Mixpeek MVS is a vector store that runs directly on object storage: vectors rest on object storage ($1.56 per million vectors plus $0.08/GB-month on the rate card), queries and writes are $2 per million, and plans start at $25/month with usage billed on top. Because it is part of a multimodal indexing platform, the same namespaces can hold BYO vectors today and managed video/image/document extraction later without re-indexing -- see the best vector databases list for how it compares feature-by-feature, and best S3-compatible object storage for the storage layer underneath.
```
17. shell `fetch-text https://embeddingcost.com/storage --max 6000` → exit 0
```text
|---|---|---|---|
| 3072 (full) | 1144.4 GB | $378 | baseline | 
| 1536 (half) | 572.2 GB | $189 | $189 saved | 
| 768 (quarter) | 286.1 GB | $94 | $283 saved | 

For 100M vectors at 100M-scale, halving dimensions saves **$189/month** on Pinecone. OpenAI reports that 3-large shortened as

[... 903 more chars: same command with --offset 6000]
```
