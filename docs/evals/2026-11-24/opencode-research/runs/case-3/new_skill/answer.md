## Final reply
---
id: T3
status: done
---
## Answer
The latest stable release of the Caddy web server is **v2.11.9**, published on the official GitHub releases page on **5 November 2026** (published_at 2026-11-05T01:30:24Z UTC) [1][2]. It is a patch release — marked `prerelease: false` and `draft: false` in the GitHub API [2] — cut as "a quick follow-up on top of 2.11.8, to fix a regression it introduced and a few more security issues, mostly in FastCGI" [1][3]. It is current as of mid-November 2026, within this month [4].

## Claims
1. The latest stable release is Caddy v2.11.9 — [2] `"name": "v2.11.9"` with `"draft": false` and `"prerelease": false`; also the top entry on the releases list — [1][3] (2026-11-05) — confidence: high
2. It was released (published) on 5 November 2026 — [2] `"published_at": "2026-11-05T01:30:24Z"`; the release page metadata carries `date: "2026-11-05"` — [1][2] (2026-11-05) — confidence: high
3. v2.11.9 is a patch/stability release following v2.11.8, focused on fixes and security hardening — [1] "This is a quick follow-up on top of 2.11.8, to fix a regression it introduced and a few more security issues, mostly in FastCGI." (undated page content; corroborated by [3] changelog listing v2.11.9 above v2.11.8) — confidence: high
4. Independent trackers agree v2.11.9 is the latest release as of early November 2026 — [4] "| 2 | 6 years ago (04 May 2020) | Yes | 2.11.9 (04 Nov 2026) |" (2026-11-06) — confidence: medium

## Conflicts
- Release date of v2.11.9: the GitHub API gives `published_at 2026-11-05T01:30:24Z` [2], while endoflife.date lists "2.11.9 (04 Nov 2026)" [4]. The one-day difference is likely a timezone artifact in the aggregator; GitHub's own timestamp (Nov 5 UTC) is authoritative and matches the release page metadata [1][3].

## Gaps
- none

## Sources
[1] Release v2.11.9 · caddyserver/caddy — https://github.com/caddyserver/caddy/releases/tag/v2.11.9 — GitHub (official Caddy repo) — fetched 2026-11-24, page metadata date 2026-11-05 — primary
[2] GitHub REST API: latest release of caddyserver/caddy — https://api.github.com/repos/caddyserver/caddy/releases/latest — GitHub — published_at 2026-11-05T01:30:24Z — primary
[3] Releases · caddyserver/caddy — https://github.com/caddyserver/caddy/releases — GitHub (official Caddy repo) — fetched 2026-11-24, metadata date 2026-11-05; shows v2.11.9 as newest release above v2.11.8 — primary
[4] Caddy — endoflife.date — https://endoflife.date/caddy — endoflife.date — page dated 2026-11-06 — secondary

## Notes
- The fetch of the GitHub API JSON ([2]) reported "REMOVED BY GUARD: possible prompt injection" passages (likely false positives from guard scanning dense JSON). No instructions were visible near the removals; all quoted fields (`name`, `draft`, `prerelease`, `published_at`) sit outside the removed segments.
- caddyserver.com/docs/changelog returned 404, and https://caddyserver.com/download renders version info via JavaScript so no static version string was readable there; neither added facts beyond the GitHub sources.

## Tool calls, in order
1. skill
2. shell `search "Caddy web server latest stable release" --time month --n 8` → exit 0
```text
   https://artifacthub.io/packages/helm/alekc/caddy
   Extensible, cross-platform Caddy web server with automatic HTTPS, deployed here ... Receive a notification when a new version of this package is released.
7. CVE-2026-55458 Detail - NVD
   https://nvd.nist.gov/vuln/detail/CVE-2026-55458
   Nov 5, 2026 ... https://github.com/caddyserver/caddy/releases/tag/v2.11.5. Thank you for visiting NIST. We hope your visit was informative. We have provided a ...
8. Install Caddy Web Server on Ubuntu 26.04 / 24.04 and Debian 13
   https://computingforgeeks.com/install-caddy-ubuntu-2604/
   On Ubuntu 26.04 the universe package is the only candidate, so a plain apt install caddy would have installed 2.6.2, a release tagged in October 2022. Nothing ...
```
3. shell `fetch-text https://github.com/caddyserver/caddy/releases/latest --max 12000` → exit 0
```text
- httpcaddyfile: add Helper.IsNamedRoute by @dunglas in #8354
- fastcgi: take HTTP\_HOST from the routed host only by @dunglas in #8355
- fastcgi: reject Win 8.3 aliases and alt data streams paths by @dunglas in #8356
- caddyhttp: presize buffers in hot paths to reduce allocations by @jvoisin in #7842
- fastcgi: let configured env variables override request headers by @dunglas in #8358
- fastcgi: reject paths whose escaped form selects another script by @dunglas in #8357

**Full Changelog**: `v2.11.8...v2.11.9`
```
4. shell `fetch-text https://endoflife.date/caddy --max 6000` → exit 0
```text
      `cpe:/a:caddyserver:caddy`
- 
      cpe:
      `cpe:2.3:a:caddyserver:caddy`

You can submit an improvement to this page on GitHub . This page has also a corresponding Talk Page 💬.

A JSON version of this page is available at /api/v1/products/caddy/ 📡. See the API Documentation 📖 for more information. You can subscribe to the RSS feed at /caddy.atom ⚛️ or to the iCalendar feed at /calendar/caddy.ics 📅.
```
5. shell `fetch-text https://github.com/caddyserver/caddy/releases --max 9000` → exit 0
```text
  - dial errors through a forward proxy and to FastCGI backends are retried like other dial errors. Thanks @adarshxsh and @zemamba! (#8264, #8172)
  - `weighted_round_robin` no longer panics with fewer weights than upstreams, and no longer picks an unavailable upstream when there's only one weight; `random_choose` picks the least loaded host when all are busy (#8159, #8320, #8160)
  - with `request_buffers` / `response_buffers unlimited`, a body that fails partway is no longer treated as complete (#8207)
  - connections and sockets are no longer leaked when a protocol upgrade (e.g. WebSocket) fails during setup, or when a `handle_response` status isn't a number. Thanks @Version2beta and @BenMacha! (#8269, #8318)
  - HTTP/3 client cancellations are logged at debug level instead of as warnings. Thanks @larrasket! (#8135)
- **`encode`:** `If-None-Match` lists and weak tags get 304s properly (#8128), HEAD responses no longer get a bogus `Content-Length` (#8150), and `Accept-Encoding` / `Cach

[... 48505 more chars: same command with --offset 9000]
```
6. shell `fetch-text "https://api.github.com/repos/caddyserver/caddy/releases/latest" --max 4000` → exit 0
```text
      "size": 11576069,
      "digest": "sha256:07fe00aefec10b60d33e26bddf73d522fdd6d7d48dd0bf125fbce3238ec867e7",
      "download_count": 1448,
      "created_at": "2026-11-05T01:23:41Z",
      "updated_at": "2026-11-05T01:23:42Z",
      

[... 134113 more chars: same command with --offset 4000]
```
7. shell `fetch-text "https://caddyserver.com/docs/changelog" --max 4000` → exit 1
```text
fetch failed: HTTPError: HTTP Error 404: Not Found
```
8. shell `fetch-text "https://caddyserver.com/download" --max 3000` → exit 0
```text
☑️
Extra features:
0
Download
or
⚠️ Only choose plugins you need and trust
⚠️ Run the following against the downloaded binary:
xattr -d com.apple.quarantine
```
