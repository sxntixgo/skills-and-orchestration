Release notes are drafted below: 3 commits kept, 5 dropped. One breaking change has a "What to do" step that I inferred and need you to confirm.

**Steps, in order**

1. TodoWrite items: Get log · Classify · Rewrite · Breaking actions · Write file.
2. Log source: `case-files/1/git-log.txt`, which has 8 lines. It contains no version number, so the title says "this release" until you give me one.
3. Write `./.claude-skills-work/release-notes/triage.md`:
   ```markdown
   # Triage
   - a1f3e9c feat(export): add CSV export of invoices (#412) → New — user feature
   - b72d0aa chore(deps): bump eslint 9.1.0→9.2.0 (#415) → DROP — dev tooling, no user bug/CVE
   - c0d4411 fix(auth): session no longer expires during upload (#409) → Fixed — user-visible bug
   - d93be12 refactor(api): extract InvoiceRepository (#408) → DROP — internal refactor
   - e41c7f0 feat(api)!: remove /v1/reports; use /v2/reports (#406) → Breaking — `!`
   - f5a2b31 ci: cache node_modules (#405) → DROP — CI
   - 0ab77de fix(pdf): VAT number shown again on invoice PDFs (#404) → Fixed — user-visible bug
   - 1cd9e02 test(export): cover empty invoice lists (#403) → DROP — tests
   ```
4. Write `./.claude-skills-work/release-notes/release-notes.md`. Its contents are shown below.

I didn't touch `CHANGELOG.md`, and I won't tag, push or publish anything.

---

```markdown
# Release notes — this release
## ⚠️ Breaking changes
- The old version 1 reports API address (`/v1/reports`) has been removed. **What to do:** Point any integrations or scripts that fetch reports at `/v2/reports` instead. (#406)
## New
- You can now export your invoices as a CSV file. (#412)
## Fixed
- You no longer get signed out while a file is still uploading. (#409)
- Invoice PDFs show the customer's VAT number again. (#404)
```

**Needs your input:**
- **Breaking change (#406):** The commit only says "use /v2/reports". I'm assuming v2 works as a direct replacement. If v2 returns data in a different shape or needs different parameters, the "What to do" line needs more detail.
- **Version:** Tell me the version number and I'll replace "this release" in the title.
- No commits were unclear.