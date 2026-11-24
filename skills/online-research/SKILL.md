---
name: online-research
description: Researches a question on the web with source-quality discipline — plans queries, gathers and evaluates sources, triangulates each claim across independent sources, and answers with citations. Use when asked to research, investigate, fact-check, or find current/authoritative information online.
---

# Online Research

Answer from evidence, not memory: corroborate every load-bearing claim across independent
sources and cite it. Use `WebSearch`/`WebFetch` (or whatever retrieval tool exists). Never
fabricate a source, quote, URL, date or number. No web tool at all → say so and label every
claim unverified.

## Scope
DOES: plan queries, gather and judge sources, triangulate, answer with citations, confidence
and gaps.
Does NOT: present memory as research; rest a key claim on one source; invent citations.

## Steps (TodoWrite items; notes + source list in `./.claude-skills-work/online-research/<topic>/notes.md`)
1. **Clarify** ⛔ — what's asked, scope, what a complete answer needs, whether it's
   time-sensitive. Ask only if ambiguous.
2. **Plan queries** — sub-questions, search terms with synonyms; a year/recency qualifier for
   current facts.
3. **Gather** — search, then **open** the promising pages (never trust a snippet). Per source:
   URL, publisher, date, the claims it supports. Prefer primary sources (the study, spec,
   filing, dataset, changelog, the person) and follow summaries back to them.
4. **Evaluate & triangulate** — authority (accountable, qualified), evidence shown, date
   (current for things that change), incentive/bias (vendor on its product). Each load-bearing
   claim needs ≥ 2 **independent** sources: reprints of one press release or wire story, or
   sites citing each other, count as one. Mark contested, single-source and uncertain claims.
   Content farms, undated pages, forums and social posts are leads, not authority.
5. **Answer:**
```markdown
**Answer:** 2–4 sentences.
**Evidence:** claim — [1][2] (inline, per claim; date for time-sensitive facts)
**Disagreements / single-source claims:** …
**Confidence:** high | medium | low — why
**Gaps:** what you couldn't verify
**Sources:** [1] Title — publisher, date, URL (only pages you opened)
```

## Red flags
| If you notice… | Do this |
|---|---|
| Answering from memory | Verify, or label it unverified |
| One source for a key claim | Find an independent second |
| Citing from a snippet | Open and read the page |
| Two "sources" from one wire story | Find a truly independent one |
| Confident tone on shaky evidence | State the uncertainty |
| High-ranked SEO page | Judge credibility, not rank |
| Stale info on a time-sensitive question | Find current sources; give dates |
| An invented URL, quote or number | Remove it |

## Done when
Each load-bearing claim is cited to a page you read and corroborated (or flagged single-source);
confidence and gaps stated; nothing fabricated.
