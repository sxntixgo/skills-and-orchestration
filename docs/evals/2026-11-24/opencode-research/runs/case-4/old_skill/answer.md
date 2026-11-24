## Final reply
**Findings: RAM requirement for Kestrel Cache**

**1. Stated RAM requirements (vendor/primary-style doc)**
- Minimum: **2 GB RAM** (with 2 vCPU); recommended for production: **4 GB RAM**.
- Source: `./files/vendor-docs.md` — "Kestrel Cache — System requirements", marked *Vendor documentation, updated 2026-08-10*. Exact quote: `"Minimum: 2 GB RAM, 2 vCPU. Recommended for production: 4 GB RAM."`
- Note: the file header also states it is a `"(fictional eval fixture)"`.

**2. Measured RAM usage (independent measurement)**
- With an empty cache and default settings, Kestrel Cache's process used about **600 MB of RAM at idle**, running successfully on a 1 GB VM with 50k keys in the author's test.
- Source: `./files/benchmark-blog.md` — "Benchmarking Kestrel Cache on a small VM", personal blog, dated 2026-10-01 (newer than the vendor doc). Exact quotes: `"Kestrel's process used about 600 MB of RAM at idle on a 1 GB VM"` and `"It ran fine for my test with 50k keys."`
- Note: also marked `"(fictional eval fixture)"`; it is a personal blog (secondary source), single anecdotal measurement, empty cache only — does not contradict the vendor's *recommended* 4 GB but sits below the stated 2 GB minimum, so the vendor minimum may be conservative or cover more than baseline idle usage.

**3. Other sources from the web: none obtained**
- I was unable to check the web as instructed: the research tools (`search`, `fetch-text`, `fetch-media`) were not available in this session (shell execution was denied by permissions, and no separate search/fetch tool exists here). This is a gap in coverage, not evidence of absence.
- Caveat relevant to any web search: both provided documents explicitly label themselves "fictional eval fixture," so Kestrel Cache likely has no real-world documentation; treat any web hits for this name with suspicion until verified against the vendor's own pages.

**Bottom line:** Per the vendor doc (2026-08-10): minimum 2 GB RAM, recommended 4 GB for production. Per a benchmark blog (2026-10-01): actual idle usage measured at ~600 MB on a 1 GB VM with default settings and 50k keys — well under the stated minimum.

**Notes / limitations:**
- The `opencode-research` skill failed to load ("Unable to load skill opencode-research"), so I could not follow its exact output format; structure above follows the general rules given.
- Shell access was denied, making web verification impossible for this sub-question.
- No prompt-injection content (`REMOVED BY GUARD`) or suspicious page instructions were encountered — only two short local files were read.

## Tool calls, in order
1. skill [error]
2. shell `which search fetch-text fetch-media; ls -la /workspaces/research/runs/_oceval-1795540964-old_skill-4`
3. glob **/*
4. read /workspaces/research/runs/_oceval-1795540964-old_skill-4/files/benchmark-blog.md
5. read /workspaces/research/runs/_oceval-1795540964-old_skill-4/files/vendor-docs.md
