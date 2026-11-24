---
name: release-notes
description: Turns a git log of Conventional Commits (one per line) into end-user release notes - user-facing changes only, grouped, breaking changes first with required user actions, plain language, PR numbers kept. Use when the user asks for release notes or a user-facing changelog from commits or a git log.
---

# Release notes from commits

**Does:** classify every commit, drop internal ones, rewrite the rest in plain
language for end users, put breaking changes first with what users must do.
**Does NOT:** run `git` to pick a range the user didn't give, invent features,
migration steps or version numbers, bump versions, tag, or publish anything.

Input: a log with one commit per line, e.g.
`a1b2c3d feat(api)!: drop v1 endpoints (#412)`. If no log or range was given,
STOP and ask for one.

## Checklist (track each as a TodoWrite item)

1. **Classify** every line into the table below. Write it to
   `.claude-skills-work/release-notes/classified.md` (one row per commit:
   hash | type | breaking? | keep/drop | reason | PR). Resume from this file if it exists.
2. **Rewrite** kept rows into user language. Write the draft to
   `.claude-skills-work/release-notes/notes.md`.
3. **Verify** with the checks below, fix, then return the notes and a one-line
   count: `N commits: K kept, D dropped, B breaking, U unclear`.

## 1. Classify

| Commit | Keep? | Section |
|---|---|---|
| `type!:` or subject/body says `BREAKING CHANGE` | always | **Breaking changes** |
| `feat` | yes | **New** |
| `fix` | yes, if a user could have hit it | **Fixed** |
| `perf` | yes, if users notice it | **Improved** |
| `security`, or fix mentioning CVE/vuln | yes | **Security** |
| `docs` | only user docs (guides, help), not README dev notes | **Improved** |
| `refactor`, `test`, `ci`, `build`, `chore`, `style` | drop, unless breaking or the subject shows a user-visible effect | — |
| merge / revert / non-conventional line | revert: drop both if the pair is in range; else judge by content | mark `unclear` if unsure |

- Scope hints audience: `(internal)`, `(ci)`, `(deps-dev)`, `(test)` -> drop.
- Dependency bumps: drop unless they fix a user-visible bug or security issue.
- PR number: copy every `(#NNN)` exactly. No PR -> no number; never invent one.

## 2. Rewrite rules

- Section order: Breaking changes, Security, New, Improved, Fixed. Omit empty sections.
- Each breaking item: **what changed** + **what you must do** (concrete action).
  If the commit doesn't say what users must do, write
  `Action required: TODO - confirm migration step` — do not guess one.
- Describe the effect for the user ("You can now export reports as CSV"), not
  the code ("add CsvSerializer"). No file names, class names, scopes, or hashes.
- One bullet per user-visible change; merge commits describing the same change
  and keep all their PR numbers: `(#12, #15)`.
- Keep it short: one sentence per bullet, two for breaking items.
- Title: `## Release notes` (add the version only if the user gave one).
- Commits marked `unclear`: list them after the notes under
  `Needs your call (not included):` with hash + subject.

## 3. Verify before returning

- [ ] Every input line appears in `classified.md` (row count == line count).
- [ ] Every kept commit's PR number appears in the notes; no number appears that wasn't in the input.
- [ ] Breaking changes section is first and each item has an action (or a TODO).
- [ ] No jargon: no `feat`/`fix` prefixes, scopes, hashes, or code identifiers.
- [ ] Nothing in the notes lacks a source commit.

## Red flags

| Thought | Correction |
|---|---|
| "This refactor is worth mentioning" | Only if users see a difference. Otherwise drop. |
| "I'll add a likely migration step" | Unknown action -> TODO line, not a guess. |
| "I'll run git log to get commits" | Use the log given; ask if none. |
| "Bundle all fixes into 'various bug fixes'" | One bullet per user-visible fix, with its PR. |
| "Add a version / date / upgrade instructions" | Only what the user supplied or commits state. |
