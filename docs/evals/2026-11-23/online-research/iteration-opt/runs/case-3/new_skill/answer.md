**Answer:** OAuth 2.1 isn't a new protocol. It folds OAuth 2.0 (RFC 6749/6750) and its later security best practices into one spec, and removes the insecure options. In practice that means PKCE is required, the Implicit and Password grants are gone, and redirect URIs must match exactly. It is still an IETF Internet-Draft, not an RFC. The latest is draft-17 (31 Oct 2026), and the working group aims to send it to the IESG in Dec 2026.

**Evidence:**
- **PKCE is required** for every client using the authorization code flow, confidential clients included. In 2.0 it was optional. [1][2]
- **The Implicit grant is removed.** The draft has a dedicated section, 10.1. [1][2]
- **The Resource Owner Password Credentials grant is removed.** [1][2]
- **Redirect URIs must match exactly** by string comparison, with no wildcards or partial matching. [1][2]
- **Bearer tokens can't go in URI query strings.** [1]
- **Public clients' refresh tokens** must be sender-constrained or rotated on each use. [1]
- **Client types are simplified:** a client is public or confidential based only on whether it has credentials. [1]
- **There are no new features.** It consolidates 2.0 plus PKCE, the Security BCP and the native-apps and browser-apps guidance. [1][2]
- **Status:** active WG draft-17, 31 Oct 2026, Standards Track. It would obsolete RFC 6749 and 6750. [2]

**Disagreements / single-source claims:**
- I found the query-string, refresh-token and client-type points only on oauth.net [1]. I couldn't read the draft's full Section 10 to confirm them.
- Some vendor blogs in the search results say refresh-token rotation is mandatory across the board. That's an oversimplification: [1] says rotation *or* sender-constraining, and only for public clients.

**Confidence:** high for the core changes (PKCE, the removed grants, exact redirect matching). Medium for the smaller points. The draft could still change before it becomes an RFC.

**Gaps:** I only read part of the draft-17 text, through Section 1.8. I didn't read the full Section 10 list of differences. Section 10.2, "Redirect URI Parameter in Token Request", looks like a further change I didn't check.

**Sources:**
- [1] [OAuth 2.1](https://oauth.net/2.1/) — oauth.net (Aaron Parecki, a draft editor), undated, opened
- [2] [draft-ietf-oauth-v2-1](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/) — IETF Datatracker, draft-17, 31 Oct 2026, opened

*In a live session I'd also save the notes and source list to `./.claude-skills-work/online-research/oauth-2-1-vs-2-0/notes.md`. This dry run allows reads only, so I didn't write the file.*