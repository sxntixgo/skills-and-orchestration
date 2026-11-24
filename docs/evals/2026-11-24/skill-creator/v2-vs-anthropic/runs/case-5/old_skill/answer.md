Plan for slimming `commit-messages`. The work follows skill-creator's "improve an existing skill" loop: snapshot the current skill, edit it, run it against the old version, and give you the results to review.

## Assumptions

- The skill lives at `skills/commit-messages/`, and its files match `case-files/5/SKILL.md`.
- `references/conventional-commits.md` was not in the case files. I'm assuming it restates the public Conventional Commits spec (about 200 lines).
- `references/examples.md` was not in the case files either. I'm assuming it holds about 10 input→output examples plus a ticket-footer example.
- `evals/evals.json` was not found, so I'll write one.

## Where the tokens go

| Cost | Why it's waste | Fix |
|---|---|---|
| "Before you start: read both references first" | Every run loads the whole spec and all the examples, which is most of the cost | Put the few rules the steps need in SKILL.md and delete both reference files |
| `## Background` (Git history, what a commit is, the type list) | The model already knows all of this, so it changes nothing | Delete it |
| Weak `description` ("is about commit messages") | It gives no trigger, so the skill loads at the wrong times or not at all | Rewrite it as "what it does. Use when …" |

I'd also tell you about one conflict. The Scope section says the skill does NOT commit, but step 6 asks before running `git commit`. I'll keep both behaviours by saying it commits only after you explicitly approve. Tell me if you meant "never commits".

## Steps

1. **Todos:** snapshot → edit → evals → spawn runs → timing → grade → aggregate → viewer → feedback.
2. **Snapshot:** `cp -r skills/commit-messages skills/commit-messages-workspace/skill-snapshot/`
3. **Check `examples.md` before deleting it.** Anything that's house-specific (for example the ticket footer format) moves into SKILL.md. Generic Conventional Commits examples are dropped.
4. **Write `skills/commit-messages/SKILL.md`:**

```markdown
---
name: commit-messages
description: Writes a Conventional Commits message for the staged changes and commits only after the user approves. Use when the user asks for a commit message, wants to describe or commit staged changes, or says "commit this".
---

# Commit Messages

## Scope
DOES: write the commit message for the staged changes; run `git commit` only after explicit approval.
Does NOT: amend, push, or stage/unstage files.

## Steps
1. Run `git diff --staged` and read it. If nothing is staged, stop and say so.
2. Format: `type(scope)!: subject`. Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore. Mark breaking changes with `!` and a `BREAKING CHANGE:` footer.
3. Subject: imperative mood, ≤72 chars, no trailing period. State what the change does, not which files changed.
4. Body only if the change isn't obvious: explain *why*, wrapped at 72.
5. If the branch name has a ticket id (e.g. `ABC-123`), add footer `Refs: ABC-123`.
6. Show the message and ask before running `git commit`.

## Example
feat(auth): add JWT refresh endpoint

Access tokens expire after 15 min; clients were forced to re-login.

Refs: ABC-123

## Red flags
| If you notice… | Do this |
|---|---|
| Subject lists changed files | Say what the change does and why |
| About to commit without approval | Show the message first |

## Done when
The message follows the format and the user approved it.
```

5. **Delete** `references/conventional-commits.md`, `references/examples.md` and the then-empty `references/` folder.
6. **Write `evals/evals.json`** with 3 cases. Each case has a fixture diff in `evals/files/` and named assertions:
   - **1 `feature-with-ticket`:** a new endpoint on branch `ABC-123-refresh`.
     - type is `feat`
     - subject is imperative, ≤72 chars, with no trailing period
     - footer is `Refs: ABC-123`
     - no `git commit` before approval
   - **2 `breaking-api-change`:** a renamed public function.
     - uses `!` or a `BREAKING CHANGE:` footer
     - has a body explaining why
   - **3 `trivial-docs-typo-commit-this`:** the user says "just commit this", on `main`.
     - type is `docs`
     - no body and no ticket footer
     - shows the message and asks before committing
7. **Write `eval_metadata.json`** for each case under `skills/commit-messages-workspace/iteration-1/<eval-name>/`.
8. **Spawn all 6 runs in one turn** with the Agent tool on `model: claude-sonnet-5-5`:
   - The new skill writes to `with_skill/outputs/`.
   - The snapshot writes to `old_skill/outputs/`.
   - Prompt: "Execute this task: Skill path: <path> · Task: <eval prompt> · Input files: evals/files/<case>.diff (treat as `git diff --staged` output; branch: <name>) · Save outputs to: <dir> · Outputs: the proposed commit message and any commands you would run."
9. **Record timing:** as each run finishes, write its `total_tokens` and `duration_ms` to that run's `timing.json`.
10. **Grade:** a small script checks the mechanical assertions (subject length, trailing period, footer regex, no `git commit` before approval), and I judge the rest by reading `agents/grader.md`. Results go to `grading.json` using the fields `text` / `passed` / `evidence`.
11. **Aggregate:** `python -m scripts.aggregate_benchmark skills/commit-messages-workspace/iteration-1 --skill-name commit-messages`. Then an analyst pass. The main question is how many tokens the new version saves, provided the pass rate doesn't drop.
12. **Viewer:** `nohup python <skill-creator>/eval-viewer/generate_review.py skills/commit-messages-workspace/iteration-1 --skill-name commit-messages --benchmark …/benchmark.json > /dev/null 2>&1 &`
13. **Feedback and wrap-up:** read `feedback.json` when you're done, iterate if needed, and update `plan.md`. Then run `skill-reviewer` on it, as CLAUDE.md requires.

## Reply to you

> I've cut `commit-messages` from roughly 3.5k tokens per run (body plus two required reference files) to about 350, and kept all of its behaviour:
>
> - **Removed:** the Git/Conventional Commits background and the reference files every run had to read. The model already knows that material.
> - **Kept in SKILL.md:** the rules the steps actually use (types, breaking-change marker, 72-char subject, ticket footer, ask before committing) and one example.
> - **Description:** now has a real trigger.
> - **Evals:** added 3 cases. They ran against the old version, and the results are open in your browser. "Outputs" lets you check each message, and "Benchmark" compares pass rate and tokens.
>
> One thing to decide: the old skill both said it "does NOT commit" and asked before committing. I kept "commits only after you approve". Should it never commit instead?