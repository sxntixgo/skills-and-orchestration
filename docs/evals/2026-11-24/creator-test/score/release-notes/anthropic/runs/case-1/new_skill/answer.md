I'd write the release notes to `RELEASE_NOTES.md`. 3 commits kept, 5 dropped, no TODOs.

**Steps I'd take**

1. TodoWrite items: get log, classify, judge, write, hand off.
2. Log: `case-files/1/git-log.txt` (8 commits). I'm using `case-files-1` as the range name for the work directory.
3. Run `python3 <skill-dir>/scripts/classify.py case-files/1/git-log.txt > ./.claude-skills-work/release-notes/case-files-1/classified.json`. I assume it gives: 2 feat (one marked breaking with `!`), 2 fix, 1 chore(deps), 1 refactor, 1 ci, 1 test. It finds no reverts and no lines it can't parse.
4. Write `./.claude-skills-work/release-notes/case-files-1/decisions.md`:
   ```markdown
   | Commit | Decision | Reason |
   |---|---|---|
   | a1f3e9c feat(export) CSV export (#412) | kept → New | feature |
   | b72d0aa chore(deps) eslint bump (#415) | dropped | dev-tooling |
   | c0d4411 fix(auth) session during upload (#409) | kept → Fixed | user-visible |
   | d93be12 refactor(api) InvoiceRepository (#408) | dropped | internal |
   | e41c7f0 feat(api)! remove /v1/reports (#406) | kept → Breaking | breaking |
   | f5a2b31 ci: cache node_modules (#405) | dropped | ci |
   | 0ab77de fix(pdf) VAT number (#404) | kept → Fixed | user-visible |
   | 1cd9e02 test(export) empty lists (#403) | dropped | test |
   ```
5. Write `RELEASE_NOTES.md`:
   ```markdown
   ## ⚠️ Breaking changes
   - **The deprecated `/v1/reports` API endpoint has been removed.** What to do: switch any integrations that call `/v1/reports` to `/v2/reports`. (#406)

   ## New
   - You can now export your invoices as a CSV file. (#412)

   ## Fixed
   - You're no longer signed out partway through a file upload when your session would otherwise expire. (#409)
   - Invoice PDFs show the customer's VAT number again. (#404)
   ```

**Reply to the user**

The release notes are in `RELEASE_NOTES.md`. 3 of the 8 commits made it in: 1 breaking change, 1 new feature and 2 fixes. The other 5 were dropped because users won't see them: the eslint bump, the refactor, the CI change and the export test. No TODOs: the commit for the breaking change itself says to use `/v2/reports`, so that's the migration step. The one borderline call is #406, which affects API users rather than everyone using the app. It's listed under Breaking changes, as the skill requires for every commit marked with `!`.