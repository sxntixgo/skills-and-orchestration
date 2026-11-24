**Dry run: what I would do, in order**

TodoWrite: 7 items (Frame, Plan, Dispatch, Review, Verify, Write report, Finish).

**1. Frame.** The goal is clear, so I don't ask the user anything. Run is `2026-11-23-sqlite-no-client-server`.

`runs/2026-11-23-sqlite-no-client-server/brief.md`:
```markdown
# Why SQLite isn't client/server, in its developers' own words
**Question:** What have the SQLite developers (mainly D. Richard Hipp; also Dan Kennedy and
Joe Mistachkin) said in talks and interviews about why SQLite is an embedded library and not
a client/server database?
**Why:** To get the design reasons from the people who made it, not from commentators.
**A good answer has:** the reasons, grouped by theme (origin story, zero administration,
"competes with fopen()", reliability, deployment, performance and latency, where they say
client/server is the better choice). Each reason is quoted from a named talk or interview with
a date and a timestamp. Also a table of where each reason is stated, and any change in the
story over time.
**Freshness:** any date (about 2000 to now). Note the year of each statement.
**Out of scope:** third-party opinions and blog explainers (only as pointers to primary
material), SQLite internals unrelated to this choice, and forks (libSQL and the like) except
where a dev comments on them.
**Primary first:** recordings and transcripts of talks and interviews. sqlite.org docs and the
2022 VLDB paper count only as written corroboration.
```

**2. Sub-questions.** I split by medium so the researchers don't overlap, and I don't ask for approval. Each file in `tasks/` has the frontmatter `id`, `run`, `attempt: 1`.

- `tasks/Q1.md`: **Recorded conference and university talks by Hipp.**
  - What to find: segments where he explains why SQLite is serverless or embedded. Likely sources: the CMU Database Group talk (2015), "SQLite: The Database at the Edge of the Network" (Ohio LinuxFest, about 2015), Google TechTalk (2006), and any 2018–2025 talks.
  - Use `fetch-media` for timestamped transcripts, and `--frames` for slide text. Give a quote, timestamp, date and URL for each claim.
  - Prefer: YouTube or the conference's own uploads. Avoid: re-uploads with no event attribution.
- `tasks/Q2.md`: **Podcast and text interviews with SQLite developers.**
  - Likely sources: CoRecursive "The Untold Story of SQLite" (2021), The Changelog #201 (2016), FLOSS Weekly (about 2011), and written Q&A interviews.
  - Look for the origin story: the US Navy damage-control software on the DDG-79 destroyer and the Informix server that was down. Also look for "competes with fopen()" and zero-administration reasons.
  - Use official transcripts where they exist, otherwise `fetch-media`, with a quote and timestamp for each claim.
- `tasks/Q3.md`: **Written statements by the developers, used for corroboration and limits.**
  - Sources: sqlite.org `serverless.html`, `whentouse.html`, `about.html`, and the Gaffney/Hipp et al. VLDB 2022 paper "SQLite: Past, Present, and Future". Also Hipp's posts on the forum or mailing list on "why no server mode".
  - Find the stated reasons and the cases where they say to use client/server instead. Flag any place that contradicts what was said in talks.

**3. Dispatch.** All three run in the background, which fits concurrency 3:
```
bash plugins/orchestration/skills/claude-orchestrate-research/scripts/dispatch-research.sh 2026-11-23-sqlite-no-client-server Q1 &
… Q2 &
… Q3 &
```
- While they run, I draft the `report.md` skeleton: the answer, then themes, the source table, consistency over time, confidence, unknowns and sources.
- I read only the last `DISPATCH <id> exit= findings= log=` line of each output, with `tail -1`.
- If any exit code is 4, I stop and tell the user the LLM is unreachable.

**4. Review `findings/Q*.md`.** Each claim needs a URL, a quote, a date (and a timestamp for media) and a stated confidence.
- Assumed: Q2 and Q3 pass on the first try.
- Assumed: Q1 comes back citing a YouTube re-upload with no timestamps for the CMU talk. I append `## Notes from review` to `tasks/Q1.md`: "use the CMU DB Group channel upload, give timestamps for each quote, add the 2006 Google TechTalk or say it couldn't be found". Then I set `attempt: 2` and re-dispatch with `--continue`. Assumed: it is accepted on attempt 2.
- If a sub-question were rejected 3 times, I'd take it over with a `sonnet` Agent subagent and the same tools.

**5. Verify (I do this myself).**
- `grep 2026-11-23-sqlite-no-client-server runs/injections.log`. Any source flagged there needs a second source for its other claims.
- The key claims (assumed about 8):
  1. The Navy/Informix origin story (2000).
  2. "Competes with fopen(), not with Oracle."
  3. Zero configuration: no DBA and no server process to install.
  4. Reliability: there is no server that can be down.
  5. Single-file portability and application file format.
  6. Low latency: no IPC or network round trip, so many small queries are fine (the "N+1 is not a problem" argument).
  7. Where they say client/server wins: high write concurrency and many machines.
  8. Hipp: "I didn't set out to compete with servers."
- For each one, I re-open the cited source with `fetch-media <url>` at the timestamp, or `fetch-text`, and check that the quote is there.
- For the origin story and the fopen line, I `search` for a second independent primary source.
- Anything that doesn't check out gets dropped or marked ❓. I note conflicts between researchers, for example different dates or ship details in the origin story.

**6. Write `runs/2026-11-23-sqlite-no-client-server/report.md`.**
- Order: the answer in 2–5 sentences, then the evidence by theme with `[n]` citations, a table of reason × source × year, how the story changed over time, confidence, what's still unknown, and numbered sources marked ✅ or ❓.
- If any page carried instructions, I note it as suspicious.
- I copy it to `reports/2026-11-23 Why SQLite Is Not Client-Server.md` with this frontmatter, plus a line linking the run folder:
  ```yaml
  ---
  type: research
  tags: [sqlite, databases, architecture, embedded]
  updated: 2026-11-23
  ---
  ```
- I don't commit or push.

**7. Final message to the user (assuming the outcomes above):**

> **Answer:** SQLite's developers say it was never meant to replace client/server databases.
> - **Origin:** Hipp built it in 2000 for Navy damage-control software because the Informix server it depended on was often down. He wanted a database with no server to administer or lose.
> - **Main reasons in talks and interviews:** zero administration, nothing to install or keep running, data in a single file, and no network or IPC round trips. Hipp sums it up as "SQLite competes with fopen()".
> - **Where they say to use client/server instead:** many concurrent writers, or data shared across machines over a network.
>
> **Report:** `reports/2026-11-23 Why SQLite Is Not Client-Server.md` (run: `runs/2026-11-23-sqlite-no-client-server/`)
>
> **Sub-questions:**
> - Accepted on the first try: Q2 (interviews) and Q3 (written statements)
> - Accepted after one review: Q1 (talks), sent back for timestamps and the original upload
> - Taken over: none
>
> **Verification:** 8 key claims checked against the source. 7 confirmed ✅. The exact year of one origin-story detail is ❓ because the interviews disagree.
>
> Nothing was committed. Commit the run from the host when you're ready.