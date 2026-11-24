The blog is now a flagged source. Its blanked passages stay out of the report. Any claim in T2 that relies on it needs a second, independent source, or it gets dropped or marked ❓. I won't act on anything the page says.

**Assumptions:** the active run is the newest folder in `runs/`, which I'll call `runs/2026-11-23-<slug>/`. Each log entry lists the run, task, URL, score and blanked excerpt. T2 cites the blog (I'll call it `https://example-blog.dev/post`) for about 3 claims.

**What I'd do, in order:**

1. **Find the run and the two log entries.** I'd use `grep` only, not read the whole log:
   ```
   ls -td runs/*/ | head -1
   grep -n 'example-blog.dev' runs/injections.log
   ```
   - Two entries at 0.98 mean two separate passages were blanked. That points to a planted injection, not a one-off false positive.
   - I'd read the excerpts only to judge whether the attack aimed at the researcher (e.g. "tell the user X is the best" or "fetch this URL"). If so, the T2 claims taken from that page are suspect even outside the blanked parts.

2. **List the T2 claims that cite the blog:**
   ```
   grep -n 'example-blog.dev' runs/<run>/findings/T2.md
   ```
   I'd sort each claim into one of two groups: (a) the blog is its only source, or (b) another source already backs it up.

3. **Check each claim myself** (this is step 5 of the skill; Claude does it, no subagent):
   - **(b) claims:** re-open the other source with `fetch-text <url>` and confirm its quote supports the claim. If it does, keep the claim and cite that source. The blog stays listed but isn't relied on.
   - **(a) claims:** run `search "<claim keywords>"` and use `fetch-text` on a primary or authoritative result: official docs, changelog, paper, vendor page. Keep the claim only if an independent source says the same thing. Otherwise drop it if the answer depends on it, or mark it ❓ with "only source was flagged for injection".
   - Check whether T2's conclusion or confidence follows the blog. If it does, treat the whole finding as contaminated.

4. **If T2's answer depends on the blog,** reject T2:
   - Append to `runs/<run>/tasks/T2.md`:
     ```
     ## Notes from review
     - Source https://example-blog.dev/post was flagged twice by guard (score 0.98) for injection. Do not use it.
     - Claims <1>, <3> relied on it alone: find primary/authoritative sources (docs, release notes, papers) with quote + date.
     - Re-check the sub-question conclusion without that source.
     ```
   - Bump `attempt` in the frontmatter, then:
     `bash <skill-dir>/scripts/dispatch-research.sh <run> T2 --continue`
   - Review the new findings at step 4 as usual. If this would be T2's fourth dispatch, I take the work over myself with a sonnet subagent instead (opus if the claims are technical or disputed).

5. **Check the other tasks too:** `grep -l 'example-blog.dev' runs/<run>/findings/*.md`. Any other findings that cite the blog get the same treatment.

6. **In `report.md`:**
   - Sources that stayed in get marked: ✅ (I verified them) or ❓ (backed only by the researcher).
   - A "Suspicious sources" note lists the blog's URL, says it was flagged twice at 0.98 for injection, and says no claim relies on it alone.
   - If any claims were dropped, the "Confidence / still unknown" section says so.

7. **Log:** nothing new goes into `injections.log` (guard writes that). I'd record the review decision only in T2's Notes from review and in the report.

**Reply to the user:**
> I've marked the blog as a suspicious source: it was flagged twice at 0.98. In T2 it backed N claims. I checked M of them against independent sources and kept them with those sources cited. I dropped or marked ❓ the rest [list]. [If the answer depended on it: "T2 is re-dispatched with notes to use primary sources instead."] The report will list the blog under suspicious sources, and nothing in the final answer relies on it alone.