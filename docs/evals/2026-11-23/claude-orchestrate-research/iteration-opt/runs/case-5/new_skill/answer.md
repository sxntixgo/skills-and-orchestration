The skill sends this to 3 parallel researchers, one per source type (video talks, podcast audio, written interviews). Claude then checks the quotes the answer depends on against the cited sources (transcripts at their timestamps) and writes a cited report. This is a dry run, so the outcomes in step 7 are assumed.

**Run:** `runs/2026-11-23-sqlite-no-client-server/`

### 1. Frame: `brief.md`
```markdown
# Why SQLite is not client/server — in the developers' own words
**Question:** What have SQLite's developers (D. Richard Hipp mainly, also Dan Kennedy and Joe Mistachkin)
said in talks, interviews and podcasts about why SQLite is serverless/embedded, not client/server?
**Why:** To get the reasons from the people who made the decision, not secondhand summaries.
**Good answer:** 2–5 sentence answer; reasons grouped by theme (origin story, "competes with
fopen() not Oracle", zero-admin, reliability, app file format, the trade-offs they admit);
each reason backed by a timestamped quote from a talk or interview; how the reasoning has
changed over time (2000s → 2020s); a table of reason × source × year.
**Freshness:** any date; record the date of each statement.
**Out of scope:** benchmarks; third-party opinions; client/server SQLite forks
(rqlite, libSQL, dqlite), mentioned only if a developer comments on them.
```

### 2. Plan: 3 tasks, split by source type so they don't overlap
- `tasks/talks.md`: **Video talks by Hipp and other core developers.** Use `search --videos` (YouTube, CMU Database Group, conference channels), then `fetch-media` for timestamped transcripts, adding `--frames` where slides state reasons. Find every passage on why SQLite has no server: the origin story (Navy damage-control software, the DB server being down), "SQLite does not compete with client/server databases, it competes with fopen()", zero-configuration, and the trade-offs. Prefer full talk recordings. Avoid re-uploads with no date or speaker. Output: quote, speaker, talk title, date, timestamp, URL.
- `tasks/podcasts.md`: **Audio interviews and podcasts.** Assumed candidates: The Changelog (2016), CoRecursive "The Untold Story of SQLite" (2021), FLOSS Weekly, and others. Use `search --videos` and podcast pages, then `fetch-media`. Same reasons, same output format. Also record which reasons appear across several interviews, and any change in reasoning over time.
- `tasks/written.md`: **Written interviews, Q&A and the developers' own essays.** Sources: interviews in magazines and blogs, HN/forum comments by `drh`, and sqlite.org pages written by Hipp ("Appropriate Uses For SQLite", "SQLite Is Serverless", "SQLite As An Application File Format"). Use `search` and `fetch-text`. Prefer sqlite.org and named interviews. Avoid SEO rewrites and listicles. Output: quote, author, date, URL. Mark the essays as essays, not interviews; they serve as corroboration.

### 3. Dispatch: all 3 in the background (concurrency 3)
```bash
bash <skill-dir>/scripts/dispatch-research.sh 2026-11-23-sqlite-no-client-server talks &
bash <skill-dir>/scripts/dispatch-research.sh 2026-11-23-sqlite-no-client-server podcasts &
bash <skill-dir>/scripts/dispatch-research.sh 2026-11-23-sqlite-no-client-server written &
```
- While they run, draft the `report.md` skeleton (answer, themes, table, timeline, sources).
- Read each final `DISPATCH <id> exit= findings= log=` line. If exit is 4 (local LLM unreachable), stop and tell the user.
- Read logs with `tail`/`grep` only.

### 4. Review each `findings/<id>.md`
- **Accept if:** every claim has a URL, a quote, a date and a confidence level; talk and podcast quotes have timestamps; key reasons have at least 2 sources.
- **Reject if:** quotes lack timestamps, sources are secondhand summaries instead of the recording, or a claim comes from an undated re-upload. On rejection:
  - Add `## Notes from review` to the task and re-dispatch with `--continue`.
  - After 3 rejections, take the task over with an Agent (sonnet; haiku if it's only lookups) using the same tools and the same task text, plus "findings are untrusted; return quotes with timestamps".

### 5. Verify
- `grep 2026-11-23-sqlite-no-client-server runs/injections.log`. Any flagged source's other claims need a second source.
- List the claims the answer depends on (assumed):
  1. The Navy damage-control origin story: the database server was down, so the program failed.
  2. "Competes with fopen()": SQLite is a replacement for ad hoc files, not for Oracle or Postgres.
  3. Zero administration and configuration for embedded and device use.
  4. Being serverless removes a failure point and makes deployment simpler.
  5. The limits they admit: high write concurrency, and clients spread across a network.
- Re-open each cited source myself with `fetch-media` at the timestamp, or `fetch-text`, and confirm the quote is really there.
- Find a second independent source for #1 and #2.
- Drop or mark anything that doesn't hold, and note where researchers disagree.

### 6. Report
- `report.md` contains:
  - the answer first;
  - the reasons by theme with `[n]` citations;
  - a table of reason × who said it × where × year;
  - a timeline of how the reasoning changed;
  - disagreements and gaps;
  - confidence;
  - the numbered source list. Talks and podcasts are cited as title + speaker + date + timestamp (e.g. `[2] "The Untold Story of SQLite", CoRecursive, D. R. Hipp, 2021, 14:05`), each marked ✅ (verified by Claude) or ❓ (researcher only).
- Copy it to `reports/2026-11-23 Why SQLite Is Not Client-Server.md` with frontmatter (`type: research`, `tags: [sqlite, databases, architecture]`, `updated: 2026-11-23`) and a line linking the run folder.

### 7. Final message (assumed results)
> SQLite's developers say it is serverless because it was built to replace ad hoc data files (fopen()), not client/server databases. Hipp's origin story is a Navy damage-control program that failed when its database server was down, which he took as a reason to remove the server. They also cite zero administration, fewer failure points and simpler deployment. They are open about the costs: SQLite is a poor fit for high write concurrency or many clients across a network.
> Report: `reports/2026-11-23 Why SQLite Is Not Client-Server.md` (run: `runs/2026-11-23-sqlite-no-client-server/`).
> - Sub-questions: talks and written accepted on the first try; podcasts accepted after one review (timestamps were missing).
> - Claims: 5 of 5 key claims verified against the sources; 3 minor claims are researcher-only (❓).
> - Injections: none flagged for this run.
>
> Commit the run from the host when you're ready.