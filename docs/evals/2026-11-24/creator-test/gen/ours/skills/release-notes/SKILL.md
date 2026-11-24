---
name: release-notes
description: Turns a git log of Conventional Commits (one per line) into end-user release notes, keeping only user-facing changes, breaking changes first with the action users must take, plain language, PR numbers kept. Use when the user asks for release notes, a changelog for users, or "what's new" from commits or a git log.
---
# Release Notes

Users read release notes to learn what changed for *them*. Every commit gets a decision; only
user-facing ones reach the page, rewritten so a non-developer understands them.

## Scope
DOES: classify commits, write release notes in the format below, save them.
Does NOT: edit `CHANGELOG.md` unless asked; tag, push or publish (⛔ even if asked: show the
notes first and get an explicit go — these are outward and hard to undo); invent
changes or PR numbers not in the log; write developer changelogs (internal refactors etc.).

## Steps (TodoWrite items; output in `./.claude-skills-work/release-notes/`)
1. **Get the log.** Use the log the user gave or named. None given and no range named → ⛔ ask
   for it (or for the range, e.g. `v1.3.0..HEAD`); don't guess a range.
2. **Classify every line** into `triage.md` (`<line> → <section|DROP> — reason`):

| Commit | Goes to |
|---|---|
| `!` after type/scope, or `BREAKING CHANGE:` footer | **Breaking changes** (any type, even `refactor!`/`chore!`) |
| `feat` | **New** |
| `fix` | **Fixed** |
| `perf` | **Improved** |
| `docs` about user docs/help pages | **Improved**, only if users would notice |
| `refactor`, `test`, `ci`, `build`, `chore`, `style`, internal `docs` | DROP |
| `revert` | Drop both the revert and the reverted commit if both in range; else **Fixed**/note |
| `chore(deps)` fixing a user-visible bug or CVE | **Fixed** (say "security fix") |
| Not Conventional / unclear | Judge by content; if still unclear, DROP and list it in the reply |

3. **Rewrite** each kept item: what the user can now do / what no longer goes wrong. No commit
   types, scopes, function names, file paths or jargon. Merge duplicates (one item, all PRs).
   Keep every PR number as `(#123)` at the end; no PR in the commit → no number.
4. **Breaking changes**: each item states what changed AND "**What to do:** …" (the concrete
   user action). If the log doesn't say what users must do, write the best inference and flag it
   in the reply as needing confirmation — never omit the action line.
5. **Write** `release-notes.md` in the format below; omit empty sections. Show it in the reply
   with: kept/dropped counts, unclear commits, breaking-change actions needing confirmation.

## Output format
```markdown
# Release notes — <version or range>
## ⚠️ Breaking changes
- <plain change>. **What to do:** <action>. (#12)
## New
- … (#34)
## Improved
## Fixed
```

## Red flags
| If you notice… | Do this |
|---|---|
| "feat(api): add `useCache` hook" style wording | Rewrite as the user benefit |
| A `refactor!` / `chore!` dropped as internal | `!` always means Breaking |
| Breaking item without "What to do" | Add it; flag if inferred |
| A PR number dropped while merging items | Keep all: `(#12, #15)` |
| Listing CI, tests, deps bumps, refactors | DROP them |
| About to tag/push/publish before the user OKs the notes | Stop; show notes, ask |

## Done when
Every log line is in `triage.md`; `release-notes.md` has breaking changes first, each with
"What to do", only user-facing items, all PR numbers of kept items.
