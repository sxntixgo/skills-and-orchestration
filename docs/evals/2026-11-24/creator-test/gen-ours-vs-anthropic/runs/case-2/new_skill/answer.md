I created `skills/release-notes/` with the skill, its evals and two sample git logs, and the validator passes. I haven't run the evals yet.

**Description:** Turns a git log of Conventional Commits (one per line) into end-user release notes, keeping only user-facing changes, breaking changes first with the action users must take, plain language, PR numbers kept. Use when the user asks for release notes, a changelog for users, or "what's new" from commits or a git log.

`CHECK release-notes fail=0 warn=0 chars=3444 refs=0 cases=4`

**How it works:**
- **Sorting:** every commit is sorted into a section or dropped, with a reason, in `triage.md`. A `!` or a `BREAKING CHANGE:` footer always counts as breaking, even on `refactor` or `chore` commits.
- **Breaking changes:** each one must have a "**What to do:**" line. If the log doesn't say what users must do, the skill writes its best guess and asks you to confirm it.
- **Output:** the notes are saved to `./.claude-skills-work/release-notes/release-notes.md`.

**Eval cases (4):**
- `standard-release`: an 11-commit log. Checks that breaking changes come first with an action line, the 5 user-facing PRs are kept, the 5 internal ones are dropped, and no commit-type prefixes like `feat(` remain.
- `hidden-breaking-and-merge`: a `refactor!` commit and a breaking change hidden in a commit footer. Checks that both are listed as breaking, the rename action names the exact config key, two dark-mode commits become one bullet with both PR numbers, and a dependency bump that fixes a CVE becomes a "security fix".
- `no-log-given`: the stop case. Checks that it asks for the log or commit range and writes no notes.
- `no-publish`: you ask it to tag and push too. Checks that it writes the notes but doesn't tag or push until you approve.

**Assumptions:**
- **Docs commits:** they're dropped unless they change docs that users would notice.
- **Reverts:** if both the change and its revert are in the log, both are dropped.
- **Non-Conventional commits:** judged by what they say, and any that are still unclear are dropped and listed in the reply.
- **Tagging, pushing and publishing:** the skill never does these without your OK after you've seen the notes, even if you ask in the same message.
- **`CHANGELOG.md`:** only edited if you ask.

Approve, or what should change? Next step is `skill-authoring:skill-reviewer` to run the evals with and without the skill.