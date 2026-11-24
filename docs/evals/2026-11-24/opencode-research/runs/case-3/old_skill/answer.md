## Final reply
---
id: T3
status: done
---
## Answer
The latest stable release of the Caddy web server is **v2.11.9**, published on GitHub on **5 November 2026** (API timestamp `published_at: 2026-11-05T01:30:24Z`; endoflife.date lists it as "2.11.9 (04 Nov 2026)", a same-moment timezone difference). Verified via the GitHub releases API's `/releases/latest` endpoint on 24 Nov 2026, so it is still current this month; `v2.11.9` is marked `"draft": false` and `"prerelease": false`, i.e., a stable release. It is a security/bugfix follow-up to v2.11.8 ("This is a quick follow-up on top of 2.11.8, to fix a regression it introduced and a few more security issues, mostly in FastCGI").

## Claims
1. Latest stable version number is v2.11.9 — [1] `"html_url": "https://github.com/caddyserver/caddy/releases/tag/v2.11.9"` and `"name": "v2.11.9"` (GitHub's "latest" release endpoint returns the newest non-draft, non-prerelease release; fetched 2026-11-24) — confidence: high
2. It is a stable (not pre-release/draft) release — [1] `"draft": false,` … `"prerelease": false,` — confidence: high
3. Release date: published 5 Nov 2026 at 01:30 UTC — [1] `"published_at": "2026-11-05T01:30:24Z"`; corroborated by the release page front-matter `date: "2026-11-05"` [2] — confidence: high
4. Release content/context: quick fix release on top of v2.11.8 with security fixes — [2] "This is a quick follow-up on top of 2.11.8, to fix a regression it introduced and a few more security issues, mostly in FastCGI." (release page dated 2026-11-05) — confidence: high
5. Independent tracker agrees v2.11.9 is the latest line-2 release — [3] "| 2 | 6 years ago (04 May 2020) | Yes | 2.11.9 (04 Nov 2026) |" (page dated 2026-11-06) — confidence: high

## Conflicts
- Release-date day: GitHub shows `published_at: 2026-11-05T01:30:24Z` [1] while endoflife.date says "2.11.9 (04 Nov 2026)" [3]. Not a real conflict — same instant rendered in different timezones; report 5 Nov 2026 per the primary source, noting "4–5 Nov 2026 depending on timezone".
- A release-alert aggregator in search results showed stale data ("Latest version: v2.11.4, last published: June 3, 2026"); disregarded as out of date — GitHub's own API (fetched today) takes precedence.

## Gaps
- None for the asked facts (version + date). Did not verify whether any v3/pre-release line exists, since the question is explicitly about the latest *stable* release; `/releases/latest` excludes prereleases by definition.

## Sources
[1] GitHub Releases API — "latest" release JSON for caddyserver/caddy — https://api.github.com/repos/caddyserver/caddy/releases/latest (HTML view: https://github.com/caddyserver/caddy/releases/tag/v2.11.9) — official GitHub, primary — fetched 2026-11-24
[2] Release page "Release v2.11.9 · caddyserver/caddy" — https://github.com/caddyserver/caddy/releases/tag/v2.11.9 — official GitHub releases page (preferred source), primary — release dated 2026-11-05, fetched 2026-11-24
[3] endoflife.date "Caddy" — https://endoflife.date/caddy — secondary tracker (used only for cross-check), page date 2026-11-06, fetched 2026-11-24

## Notes
- The `opencode-research` skill failed to load ("Unable to load skill opencode-research"); I used the documented tools directly (`search`, `fetch-text`) per the workspace CLAUDE.md and matched the findings format from a prior run. Compound shell commands (e.g., piping fetch-text to `head`) were permission-denied; plain `search`/`fetch-text` invocations worked.
- The GitHub API JSON fetch returned many `[⚠ REMOVED BY GUARD: possible prompt injection …]` markers (109 passages, max score 0.98) — consistent with the workspace README's documented false-positive behavior on short machine-generated/JSON fragments. No instructions were present in or around those passages and nothing was acted upon; the release page [2] and endoflife.date [3] fetched GUARD-clean (max score 0.00).
- Search-result URLs via SearXNG redirect proxies (`http:///go/v1/...`) could not be quoted directly; only pages resolved to canonical URLs are cited above.

## Tool calls, in order
1. skill [error]
2. shell `which search fetch-text fetch-media 2>/dev/null; ls /workspaces/research 2>/dev/null | head -50`
3. glob **/SKILL*.md
4. glob **/*research*
5. glob **/*
6. read /tmp/opencode [error]
7. glob /workspaces/research
8. read /workspaces/research/CLAUDE.md
9. read /workspaces/research/README.md
10. shell `search "Caddy web server latest stable release"` → exit 0
```text
   https://caddyserver.com/
   Caddy is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go.
7. GitHub - caddyserver/caddy: Fast and extensible multi-platform ...
   http:///go/v1/AYDC0gyAGzG-awXI5AGVqGk7DKAjfl3PuZlKj73dg6HC_1n5L0gMC0z--puHO_9QCFK7Qg1pKxd8gUvw2uDnoU5WeyTHXSutZeDd-cAsiY0b_RQG6Wmvf1phEWbctaFKBs5OIw4jAZ_lwWdrNhoL3PR8FJFDIWHGSfUgWdTSHryS_qjOhfG0BLlqqfSJcwyUPWQf1SksCg
   Caddy is an extensible server platform that uses TLS by default. ... The simplest, cross-platform way to get started is to download Caddy from GitHub Releases and place the executable file in your PATH.
8. Releases - caddyserver/caddy - upd.dev
   http:///go/v1/AYDC0gyAGzG-awXI5AGVqGk7DKAjfl3PuZlKj73dhP9vNgy_TejA_ijifxkj2-vZz30pBwJV2YZg9_FZ1ZZG1nm62OQUdLJdrz8QpYfWIYtbU5m1ALP7p74yAz-tsncDVlfyH1GWPSKZLewBZoOAGmeaujjDmbJnQw5pNZeyTUUNLvbu4IYEa-HryzqLADj4oJmzPX4h3Cb5Kbp5BQ
   This is the first release made by our new, automated release process developed by @Mohammed90 that was carried out and approved entirely by our maintainer team (together with @francislavoie) without intervention from @mh
```
11. shell `fetch-text "https://api.github.com/repos/caddyserver/caddy/releases/latest"` → exit 0
```text
      "node_id": "RA_kwDOAb2sRc4qahi7",
      "name": "caddy_2.11.9_freebsd_amd64.sbom.sig",
      "label": "",
      "uploader": {
        "login": "github-actions[bot]",
        "id"

[... 126113 more chars: same command with --offset 12000]
```
12. shell `fetch-text "https://github.com/caddyserver/caddy/releases/tag/v2.11.9" | head -80`
13. shell `fetch-text "https://endoflife.date/caddy" | head -60`
14. shell `fetch-text "https://github.com/caddyserver/caddy/releases/tag/v2.11.9"` → exit 0
```text
- httpcaddyfile: add Helper.IsNamedRoute by @dunglas in #8354
- fastcgi: take HTTP\_HOST from the routed host only by @dunglas in #8355
- fastcgi: reject Win 8.3 aliases and alt data streams paths by @dunglas in #8356
- caddyhttp: presize buffers in hot paths to reduce allocations by @jvoisin in #7842
- fastcgi: let configured env variables override request headers by @dunglas in #8358
- fastcgi: reject paths whose escaped form selects another script by @dunglas in #8357

**Full Changelog**: `v2.11.8...v2.11.9`
```
15. shell `fetch-text "https://endoflife.date/caddy"` → exit 0
```text
      `cpe:/a:caddyserver:caddy`
- 
      cpe:
      `cpe:2.3:a:caddyserver:caddy`

You can submit an improvement to this page on GitHub . This page has also a corresponding Talk Page 💬.

A JSON version of this page is available at /api/v1/products/caddy/ 📡. See the API Documentation 📖 for more information. You can subscribe to the RSS feed at /caddy.atom ⚛️ or to the iCalendar feed at /calendar/caddy.ics 📅.
```
16. read /workspaces/research/runs/2026-11-21-sqlite-serverless/findings/T1.md
