---
name: online-research
description: Researches a question on the web with source-quality discipline — plans queries, gathers and evaluates sources, triangulates each claim across independent sources, and answers with citations. Use when asked to research, investigate, fact-check, or find current/authoritative information online.
---

# Online Research

Answer the question from evidence, not memory. Corroborate every load-bearing
claim across independent sources and cite it. Uncertainty stated plainly beats a
confident guess.

Use `WebSearch`/`WebFetch` when they're available; if only one (or a different
retrieval tool) is present, apply the same method with what you have. Never
fabricate a source, quote, or URL.

## Scope
This skill DOES:
- Plan queries, gather sources, judge their credibility, triangulate claims, and
  synthesize a cited answer with a confidence level and known gaps.

This skill does NOT:
- State claims from memory as if researched — if you didn't verify it, say so.
- Rely on a single source for a load-bearing claim.
- Invent citations, quotes, dates, or numbers.

## Steps
Surface as TodoWrite items. Checkpoint running notes and the source list to
`./.claude-skills-work/online-research/<topic>/notes.md` as you go, so a long
research task can pause and resume from where you left off.

### 1. Clarify the question  ⛔ STOP if ambiguous
State what's actually being asked, the scope, and what a complete answer needs.
Note if it's time-sensitive (needs current info). If the ask is ambiguous, ask
before burning searches.

### 2. Plan queries
Decompose into sub-questions. For each, list search angles and terms (include
alternates/synonyms and, for current facts, a recency qualifier). Write the plan
to the notes file.

### 3. Gather
Search, then open the promising sources — don't judge a page by its snippet.
For each source, record in the notes file: URL, who published it, date, and the
specific claims it supports. Prefer primary sources and originals over aggregators.

### 4. Evaluate & triangulate
For each source judge credibility, recency, and bias (see
`references/source-evaluation.md`). Then, for each load-bearing claim,
corroborate it across at least two independent sources (not two sites copying
one wire story). Mark claims that are contested, single-source, or uncertain.

### 5. Synthesize with citations
Answer the question. Every load-bearing claim carries a citation to a source you
actually read. State a confidence level and call out gaps, disagreements, and
anything you could not verify. Distinguish established fact from your inference.

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Answering from memory | Verify against a source, or label it unverified |
| One source for a key claim | Corroborate with an independent second source |
| Citing a page from its snippet | Open and read it before relying on it |
| Two "sources" that are the same wire story | Find a genuinely independent one |
| A confident tone on shaky evidence | State the uncertainty and the gap |
| A high-ranked but low-quality/SEO page | Judge credibility, not search rank |
| Stale info on a time-sensitive question | Seek current sources; note the date |
| Any invented URL, quote, or number | Never — remove it; only cite what you read |

## Done when
- Each load-bearing claim is cited to a source you read and corroborated (or
  explicitly flagged single-source/uncertain).
- The answer states a confidence level and lists gaps/disagreements.
- No fabricated sources, quotes, or figures.

## References (load only when needed)
- `references/source-evaluation.md` — credibility signals, primary vs secondary,
  recency, bias, independence, and citation practice.
