---
name: commit-messages
description: This skill is about commit messages.
---

# Commit Messages

## Background
Git is a distributed version control system created by Linus Torvalds in 2005. A commit records
a snapshot of the repository. Commit messages explain why a change was made, which helps future
maintainers understand the history. Good commit messages are important for code review,
debugging with git bisect and generating changelogs. Many teams follow the Conventional Commits
specification, which defines types such as feat, fix, docs, style, refactor, perf, test, build,
ci and chore. A breaking change is marked with an exclamation mark or a BREAKING CHANGE footer.

## Before you start
Read `references/conventional-commits.md` first, then `references/examples.md`.

## Scope
DOES: write the commit message for the staged changes.
Does NOT: commit, amend or push.

## Steps
1. Run `git diff --staged` and read it.
2. Pick the type from the specification.
3. Write a subject line in the imperative mood, at most 72 characters, no trailing period.
4. If the change is not obvious, add a body that explains why, wrapped at 72 characters.
5. If the repo has a ticket id in the branch name (e.g. ABC-123), put it in the footer.
6. Show the message and ask before running `git commit`.

## Red flags
| If you notice… | Do this |
|---|---|
| A subject that says what files changed | Say what the change does and why |
| Committing without asking | Show the message first |

## Done when
The message follows the format and the user approved it.
