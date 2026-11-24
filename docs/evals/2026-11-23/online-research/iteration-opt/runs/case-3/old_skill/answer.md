OAuth 2.1 isn't a new protocol. It takes OAuth 2.0 (RFC 6749/6750) and folds in the security best practices published since, mainly PKCE and the Security BCP (RFC 9700). It is still an IETF draft, not an RFC: the latest version is draft-ietf-oauth-v2-1-17 from 31 Oct 2026, and the working group plans to send it to the IESG in Dec 2026 ([IETF Datatracker](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/)).

**Main differences (backed by both the draft and oauth.net):**
- **PKCE is required.** Every authorization code flow must use it, including confidential clients. In 2.0 it was optional.
- **The Implicit grant (`response_type=token`) is removed.** Tokens sent back in the redirect can leak or be injected, and they can't be tied to the client that requested them. OpenID Connect's `id_token` response type is not affected.
- **The password grant (ROPC) is removed.**
- **Redirect URIs must match exactly.** Wildcard or pattern matching is no longer allowed.
- **Bearer tokens can't go in URL query strings.**
- **Refresh tokens for public clients** must be rotated (single-use) or tied to the client that holds them (sender-constrained).
- **Client types are defined more simply:** a client is public or confidential based on whether it has credentials.

**Smaller changes found only in the latest draft (one source, though it's the spec itself):**
- The token request no longer includes `redirect_uri`, because PKCE now prevents code injection. Servers that support both versions must still accept it from 2.0 clients.
- The PKCE `plain` method is removed. I read this through a summarizing fetch tool, so check the exact wording in Section 10 if it matters to you.
- Authorization servers must accept client credentials in the request body.
- Refresh tokens issued to browser-based apps have extra lifetime limits.

**What it means in practice:** 2.0 clients that skip PKCE, rely on wildcard redirect URIs, or use the implicit or password grant won't work with a server that enforces 2.1 (draft §10). If your setup already follows the current 2.0 Security BCP, you're nearly 2.1-compliant.

**Confidence:** High for the main differences, which the draft and oauth.net agree on and vendor posts (WorkOS, Stytch, Descope) repeat. Medium for the smaller changes, since I only have the latest draft for those and the text could still change before it becomes an RFC.

I couldn't do two steps the skill asks for, because I don't have TodoWrite or a Write tool here. In a real session I'd track the steps with TodoWrite and save the query plan and source list to `./.claude-skills-work/online-research/oauth-2-1-vs-2-0/notes.md`.

Sources:
- [IETF Datatracker – draft-ietf-oauth-v2-1 (rev 17), §1.8 and §10](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/)
- [oauth.net – OAuth 2.1](https://oauth.net/2.1/)
- [WorkOS – OAuth 2.1 vs 2.0](https://workos.com/blog/oauth-2-1-vs-oauth-2-0)
- [Stytch – OAuth 2.1 vs 2.0](https://stytch.com/blog/oauth-2-1-vs-2-0/)
- [Descope – OAuth 2.0 vs OAuth 2.1](https://www.descope.com/blog/post/oauth-2-0-vs-oauth-2-1)