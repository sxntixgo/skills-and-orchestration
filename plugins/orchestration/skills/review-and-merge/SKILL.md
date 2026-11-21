---
name: review-and-merge
description: Reviews an implementer's result for one orchestration task — diff against the task spec, tests rerun by Claude, scope and quality checks — then merges it or sends it back with precise notes. Use when opencode (or another implementer) has finished a task and left a RESULT.md in its worktree.
---

# Review and merge

You are the stronger model checking the weaker one. RESULT.md is a claim, not evidence.
Formats: `../../contract.md` (relative to this skill's base directory).

## Scope
DOES: verify one task's worktree; accept → commit and merge into `base_branch`; reject → write
review notes into the task and hand it back; after `max_sendbacks` rejections → take it over.
Does NOT: push, deploy, or widen the task. Does not fix the implementer's code silently on accept.

## Required steps
1. **Collect.** Copy `.worktrees/<id>/RESULT.md` to `.orchestra/<run>/tasks/<id>.result.md`.
   Read it and the task file.
2. **Scope check.** `git -C .worktrees/<id> status --porcelain` and `git -C .worktrees/<id> diff`
   (plus untracked files). Every changed file must be in the task's "may change/create" list.
   RESULT.md itself must not be committed. Build artifacts (`__pycache__/`, `node_modules/`, coverage)
   are not scope violations: delete them before committing.
3. **Run the check yourself** in the worktree: the task's exact test command, then the repo's
   full test suite (or the relevant part if it's slow) and its lint/typecheck if the repo has them.
   Compare with what RESULT.md claims.
4. **Read the diff** with a code-review lens (`code-review` helps): correctness, edge cases from
   the spec, error handling, matches the existing pattern, no dead code, no secrets, no new deps
   the task didn't name. `security-review` when it touches auth, input, files or the network.
5. **Decide.**
   - **Accept** when every "Done when" holds, tests pass, scope is clean, nothing important
     wrong. Remove RESULT.md, commit in the worktree (`<type>: <goal> (orchestra <run>/<id>)`
     plus the repo's trailers), merge into `base_branch` (fast-forward or `--no-ff`, per the repo),
     run the tests on `base_branch` again, then `git worktree remove` and delete the branch.
   - **Reject** otherwise: write `## Notes from review` into the task (each `file:line — problem —
     what to do`), bump `attempt`, and send it back with `dispatch-opencode --continue`.
   - **Take over** when this would be rejection number `max_sendbacks + 1`, or the problem is
     beyond the implementer (design flaw in the spec, cross-cutting change): fix it yourself in
     the worktree, then accept as above, marking `taken-over`.
   Small nits only (naming, a comment) → accept and note them; don't spend a round-trip.
6. **Log** the verdict, test numbers and reason in `board.md`.

## Red flags
| If you notice… | Do this |
|---|---|
| Accepting because RESULT.md says "all tests pass" | Run them yourself first |
| A file outside the allowed list changed | Reject (or revert that file if harmless and note it) |
| Tests were weakened, skipped or deleted to pass | Reject; say so explicitly |
| Rewriting the implementation "while you're there" on accept | Don't; reject or take over |
| Vague notes ("fix the bugs") | Each note: file:line, problem, concrete fix |
| About to push | Don't; the user pushes |

## Done when
The task is merged (tests green on `base_branch`, worktree and branch removed) or sent back with
concrete notes or taken over — and `board.md` records which, with the test numbers.
