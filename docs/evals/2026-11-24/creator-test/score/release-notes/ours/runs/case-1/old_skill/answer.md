I'd read `case-files/1/git-log.txt` (8 commits) and write the notes below. I'd leave out 4 internal commits that users won't notice: #415 (eslint bump), #408 (refactor), #405 (CI cache) and #403 (tests). The log doesn't show a version number or date, so those are left as placeholders.

```markdown
# Release vX.Y.Z — YYYY-MM-DD

## ⚠️ Breaking changes
- **`/v1/reports` endpoint removed.** It was deprecated and has now been deleted.
  Switch any calls to `/v2/reports`. (#406)

## New
- **Export invoices to CSV.** You can now download your invoices as a CSV file. (#412)

## Fixed
- Your session no longer expires while a file is still uploading. (#409)
- Invoice PDFs show the customer's VAT number again. (#404)
```

Replace `vX.Y.Z` and the date with the real values. Because #406 is a breaking change, this should be a major version bump if you follow semver. If there's a migration guide for `/v2/reports`, add a link to it in the breaking-change entry.