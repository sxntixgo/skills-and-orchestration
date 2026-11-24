---
name: release-notes
description: Turns a git log of Conventional Commits (one commit per line) into end-user release notes — keeps only user-facing changes, puts breaking changes first with what users must do, groups the rest, rewrites in plain language, and keeps PR numbers. Use when the user asks for release notes, a user-facing changelog, or "what's new" from commits, a git log, or a tag range.
---

# Release notes

Readers are end users, not contributors. They want to know: what breaks for me and what do I
do, what can I now do, what got fixed. Everything else is noise. The work is a filter plus a
rewrite: classify every commit, drop the internal ones, then translate the rest.

## Scope
DOES: classify commits, drop internal ones, write grouped plain-language notes from the log.
Does NOT: invent changes, migration steps or versions not in the log; read the codebase to
add detail unless asked; commit, tag or publish anything.

## Steps (TodoWrite items; work files in `./.claude-skills-work/release-notes/<range>/`)
1. **Get the log.** Use the text/file the user gave. If they named a range or tag but no log,
   run `git log --oneline <range>` (or `<last-tag>..HEAD`). No log and no repo → ask.
2. **Classify** — run `python3 <skill-dir>/scripts/classify.py <log-file>` → writes JSON to
   stdout; save it as `classified.json`. It buckets lines by type, flags breaking (`!` or
   `BREAKING`), extracts `#123`, cancels revert pairs, and lists unparseable lines.
   Resume here if `classified.json` exists.
3. **Judge each kept line** (the script is a first pass, not the decision):
   | Type | Default |
   |---|---|
   | `feat` | New |
   | `fix` | Fixed |
   | `perf` | Improved |
   | `docs` | drop, unless it's user docs (guides, help text) → Improved |
   | `refactor` `test` `ci` `build` `chore` `style` | drop |
   | `deps` / dependency bumps | drop, unless it fixes a security issue or changes requirements (min runtime/OS) → keep |
   | any type with `!` / BREAKING | Breaking, always kept |
   | unparseable line | read it; keep only if clearly user-visible, else drop |
   A `feat`/`fix` with an internal scope (`ci`, `tests`, `deps-dev`, admin-only tooling) is
   internal → drop. When unsure, keep it and say so in the hand-off.
   Save the decisions (kept/dropped + one-word reason) to `decisions.md`.
4. **Write** to `RELEASE_NOTES.md` (or the path the user named), this order, empty sections
   omitted:
   ```markdown
   ## ⚠️ Breaking changes
   - **<what changed, in user terms>.** What to do: <action>. (#123)
   ## New
   - <benefit-first sentence>. (#124)
   ## Improved
   ## Fixed
   - <what used to go wrong, now doesn't>. (#125)
   ```
   - Plain language: describe what the user sees/does, not code ("Exports no longer cut off
     at 1,000 rows", not "fix(export): paginate cursor"). Drop prefixes, scopes, hashes.
   - Keep every PR number exactly as in the log, at the end. No PR number → none; don't make one up.
   - Breaking "what to do": derive it from the commit text. If the log doesn't say what users
     must do, write `What to do: <TODO: confirm migration step>` — never guess a migration.
   - Merge commits that describe one change into one bullet, keeping all their PR numbers.
   - Nothing user-facing → write "No user-facing changes in this release." and stop.
5. **Hand off**: path written, counts (kept / dropped), any TODOs and borderline calls.

## Red flags
| If you notice… | Do this |
|---|---|
| A bullet still reads like a commit ("refactor", "bump", scope names) | Rewrite or drop |
| A breaking change without "What to do" | Add it, or a TODO |
| A migration step not supported by the log | Replace with TODO |
| A PR number missing or changed | Restore it from the log |
| Chores/CI/tests in the notes | Drop them |
| A reverted change listed | Drop both the change and the revert |
| Adding sections (Contributors, Stats) nobody asked for | Remove |
