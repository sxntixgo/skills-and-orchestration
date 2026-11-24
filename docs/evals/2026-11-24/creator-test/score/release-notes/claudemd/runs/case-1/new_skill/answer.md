## Release notes

### Breaking changes
- The old `/v1/reports` endpoint has been removed. **Action required:** switch any integrations to `/v2/reports`. (#406)

### New
- You can now export your invoices as a CSV file. (#412)

### Fixed
- Your session no longer expires while a file upload is still in progress. (#409)
- Invoice PDFs show the customer's VAT number again. (#404)

8 commits: 4 kept, 4 dropped, 1 breaking, 0 unclear

*Assumption:* "Dropped" covers four internal changes: the eslint bump (#415), the invoice refactor (#408), the CI cache change (#405) and the export tests (#403).

---

**What I'd do in the real session, in order:**

1. **TodoWrite:** add three items: Classify, Rewrite and Verify.
2. **Write `.claude-skills-work/release-notes/classified.md`.** This file didn't exist yet, so there was nothing to resume from.
   ```
   | hash | type | breaking? | keep/drop | reason | PR |
   |---|---|---|---|---|---|
   | a1f3e9c | feat | no | keep | new user feature (CSV export) | #412 |
   | b72d0aa | chore | no | drop | dev dependency bump, no user effect | #415 |
   | c0d4411 | fix | no | keep | users could hit session expiry during upload | #409 |
   | d93be12 | refactor | no | drop | internal code restructuring | #408 |
   | e41c7f0 | feat! | yes | keep | removes /v1/reports; action stated (use /v2) | #406 |
   | f5a2b31 | ci | no | drop | CI-only | #405 |
   | 0ab77de | fix | no | keep | users saw missing VAT number on PDFs | #404 |
   | 1cd9e02 | test | no | drop | tests only | #403 |
   ```
3. **Write `.claude-skills-work/release-notes/notes.md`** with the notes shown above.
4. **Verify:**
   - 8 rows match the 8 input lines.
   - The kept PR numbers #406, #412, #409 and #404 all appear in the notes, and no number was invented.
   - Breaking changes come first, and the item has an action taken from the commit itself.
   - The notes contain no prefixes, scopes, hashes or code identifiers. The endpoint path stays because it's the part users have to change.
   - Every bullet has a source commit.
5. **Reply** with the notes and the count line. No version is in the title because none was given. I didn't run git or spawn any subagents.