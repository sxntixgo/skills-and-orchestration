Nothing in these four commits changes what users see or do, so the notes are short. I assumed `getConn` is internal; if it's part of a public API, the rename is a breaking change and needs its own entry.

---

## [Unreleased]: Maintenance release

There are no new features, fixes or behaviour changes in this release.

### Internal
- Updated the vitest test framework from 2.1.0 to 2.1.4 (#430).
- Lint now runs only on pull requests (#429).
- Renamed `getConn` to `getConnection` in the database layer (#428).
- Added test fixtures for the invoice parser (#427).

---

I'd skip publishing user-facing notes for this one, or post the line "Maintenance release; no user-facing changes." Tell me the version number and date and I'll put them in place of `[Unreleased]`.