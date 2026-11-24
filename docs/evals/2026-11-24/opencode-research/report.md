# opencode-research — eval 2026-11-24

new = working tree (39e07e1+worktree), baseline = no skill; model atlas/qwen3.8-flash-next; opencode research runs on atlas/qwen3.8-flash-next in the research-research devcontainer, real tools, blind Claude judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 5/5 | 0/5 |
| 2 | 5/5 | 3/5 |
| 3 | 4/4 | 4/4 |
| 4 | 4/5 | 2/5 |
| 5 | 4/5 | 1/5 |
| 6 | 4/4 | 2/4 |
| 7 | 5/5 | 2/5 |
| 8 | 4/4 | 0/4 |
| 9 | 5/5 | 1/5 |
| 10 | 4/5 | 1/5 |

| | pass rate | assertions | Claude tokens ≈ (mean) | local tokens, free (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|:---:|
| new | 0.94 | 44/47 | 1746.2 | 434251.9 | 374.49 |
| baseline | 0.35 | 16/47 | 1010.2 | 74806.6 | 120.3 |
| **delta** | **+0.59** | | +736.0 | | +254.19 |

Failed assertions:

- case 1 baseline: The tool calls include fetch-text of at least one page on docs.searxng.org or github.com/searxng — Tool calls are only skill, shell (which/ls/echo), and glob; no fetch-text call. Answer admits "tooling was unavailable".
- case 1 baseline: At least 3 searches with different wordings were run — No search command was run; the globs are local file listings ("glob **/*research*"), not web searches.
- case 1 baseline: The update procedure is answered from a fetched page with a quote; for requirements, either a quoted figure or a Gap saying the docs give none — "No claims about SearXNG's hardware requirements or update procedure are reported below, because none could be sourced"; there is no fetched page and no Gap section.
- case 1 baseline: Every claim in Claims cites a source number and includes a short quote in quotation marks — There is no Claims section and no cited claims. The reply reports "Findings: none", so the assertion has no evidence to pass on.
- case 1 baseline: The final reply is in the findings format: frontmatter with id T1 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — There is no frontmatter. The sections are "Result", "What happened (attempted steps)", "Notes" and "Sources consulted". Answer, Claims, Conflicts and Gaps are missing.
- case 2 baseline: The tool calls include fetch-text of files/vendor-page.html — Tool calls show '4. read /workspaces/.../files/vendor-page.html'; no fetch-text call. Notes: 'fetch-text/fetch-media commands were unavailable'.
- case 2 baseline: The final reply is in the findings format: frontmatter with id T2 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter with id T2/status; sections are 'Answer', 'Evidence', 'Source inventory', 'Notes'. No Claims, Conflicts, Gaps or Sources sections.
- case 4 new: The tool calls include fetch-text of both files/vendor-docs.md and files/benchmark-blog.md — Both files were opened with 'read' (calls 3 and 4: 'read .../benchmark-blog.md', 'read .../vendor-docs.md'), not fetch-text. fetch-text was used only on GitHub and usekestrel.io URLs.
- case 4 baseline: The tool calls include fetch-text of both files/vendor-docs.md and files/benchmark-blog.md — Files were read with the read tool, not fetch-text: '4. read .../benchmark-blog.md' and '5. read .../vendor-docs.md'
- case 4 baseline: The Conflicts section names both figures (2 GB vendor minimum vs about 600 MB measured at idle) with their source numbers — There is no Conflicts section and no numbered sources. Both figures appear only under headings like '1. Stated RAM requirements' and '2. Measured RAM usage', cited by file path.
- case 4 baseline: The final reply is in the findings format: frontmatter with id T4 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter, id T4 or status. The reply opens with '**Findings: RAM requirement for Kestrel Cache**' and uses custom sections. It admits 'I could not follow its exact output format'.
- case 5 new: Every number in the reply appears in a quote from a fetched source (no invented number) — Headline "4–5 W ... ≈100–120 Wh/day ... ~3 W ... ~7–8 W" is derived and appears in no quote. NUC "idle (6.4W)" came only from a search snippet; the fetch of [5] returned unrelated spam text.
- case 5 baseline: At least 4 searches with different wordings were run — No searches ran. All shell calls failed: "Permission denied: shell"; the tool list shows only skill, shell, glob, read and grep calls.
- case 5 baseline: Status is partial, or every power figure is given low/medium confidence with the missing evidence under Gaps — There is no status field and no Gaps section. Figures such as "~2–3 W" and "adapter loss of roughly 10–15%" have no low/medium confidence label.
- case 5 baseline: Every number in the reply appears in a quote from a fetched source (no invented number) — Nothing was fetched, yet the reply states "adapter wattage (45 W or 60 W MagSafe 2)", "display draw (~2–3 W...)" and "roughly 10–15%" with no source.
- case 5 baseline: The final reply is in the findings format: frontmatter with id T5 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter. The sections are Blocker, Confidence, What would resolve it and Notes, with no Claims, Conflicts, Gaps or Sources. Extra "## Final reply" and "## Tool calls" headers sit outside the format.
- case 6 baseline: The tool calls include fetch-media of the YouTube URL with --frames — No fetch-media call in the tool list; shell calls only ran `which search fetch-text fetch-media` and the reply says 'every shell invocation... returned Permission denied'.
- case 6 baseline: The final reply is in the findings format: frontmatter with id T6 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter (starts '## Findings — T6: ...'); no Answer, Claims, Conflicts or Sources sections, only numbered sections, 'Bottom line', 'Gaps / uncertainty', 'Notes'.
- case 7 baseline: The tool calls include fetch-text of both files/vendor-whitepaper.pdf and files/pricing.xlsx — Tool calls list only skill, shell, glob, read, grep; no fetch-text. Answer admits 'no web searching or fetching was possible at all.'
- case 7 baseline: The tiers are given with quotes: Starter free with 1M vectors; Team USD 49/month, 20M vectors, 3 replicas, 99.9% SLA; Enterprise on request, 99.95% — Team row says 'SLA not stated'; the 99.9% SLA for Team is missing. The other tiers are quoted correctly.
- case 7 baseline: The final reply is in the findings format: frontmatter with id T7 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter, id T7 or status. The sections are 'Findings', numbered items and 'Notes / limitations', not Answer/Claims/Conflicts/Gaps/Sources/Notes.
- case 8 baseline: The tool calls include fetch-text of postgresql.org/support/versioning — Tool calls list only skill, shell, glob, grep; reply says fetch-text commands "do not exist among my available tools in this run."
- case 8 baseline: Supported versions and EOL dates are quoted from that page — "I am reporting **zero verified findings**... No supported-version list or EOL dates are included above as claims."
- case 8 baseline: Sources are numbered and each is labelled primary or secondary — Sources section reads "None — no web page could be fetched"; the one intended source is a bullet with no number and no primary/secondary label.
- case 8 baseline: The final reply is in the findings format: frontmatter with id T8 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter (no id T8 or status); the sections are "**Findings**", "**Sources**", "**Notes**", and Answer, Claims, Conflicts and Gaps are missing.
- case 9 baseline: (a) is answered with a version and date quoted from a fetched page — "(a) Latest stable Caddy release + date | Not answered — unverified"; no pages were fetched.
- case 9 baseline: (c) is not answered with an invented codename: it is reported as not found under Gaps — No codename is invented ("Not answered — premise unconfirmed"), but there is no Gaps section. It appears only in a 'Per-part status' table.
- case 9 baseline: Status is partial, or (b) and (c) are explicitly listed under Gaps — Status is "UNABLE TO RESEARCH — no web access available in this session", not partial, and there is no Gaps section.
- case 9 baseline: The final reply is in the findings format: frontmatter with id T9 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — There is no frontmatter. The sections are 'Status', 'What happened', 'Per-part status' and 'Notes', with no Answer, Claims, Conflicts, Gaps or Sources.
- case 10 new: The tool calls include fetch-text of files/blog-measurement.md and at least one web search — Web searches ran (e.g. `search "SearXNG idle memory usage RAM docker container"`), but the blog was opened with call 2 "read ./files/blog-measurement.md", not with fetch-text.
- case 10 baseline: The tool calls include fetch-text of files/blog-measurement.md and at least one web search — Tool calls show 'read .../files/blog-measurement.md' (not fetch-text) and no search call; shell attempts failed with permission denied.
- case 10 baseline: If the 85 MB figure has no second independent source, it is labelled secondary with confidence low or medium (not high) — Reply calls it 'a weak baseline' but never labels it 'secondary' or assigns a confidence level (low/medium).
- case 10 baseline: Any conflicting figure found is listed under Conflicts (passes if none was found and Conflicts says none) — No Conflicts section exists in the reply.
- case 10 baseline: The final reply is in the findings format: frontmatter with id T10 and a status, then the sections Answer, Claims, Conflicts, Gaps, Sources and Notes, with no code fence around the whole reply and no chatter outside it — No frontmatter; sections are 'Bottom line', 'What the existing measurement says', 'Attempted verification', 'Gaps', 'Notes'. Answer, Claims, Conflicts, Sources missing.
