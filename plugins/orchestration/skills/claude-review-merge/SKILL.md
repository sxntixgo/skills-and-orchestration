---
name: claude-review-merge
description: Reviews an implementer's result for one orchestration task — diff against the task spec, tests rerun by Claude, scope and quality checks — then merges it or sends it back with precise notes. Use when opencode (or another implementer) has finished a task and left a RESULT.md in its worktree.
---

# Review and merge

You check the weaker model's work; RESULT.md is a claim, not evidence. Everything you need is
on this page: don't open `contract.md` or the script. `W` = `.worktrees/<run>/<id>`.

## Scope
DOES: verify one task; accept → commit + merge into `base_branch`; reject → review notes in the
task; after `max_rejections` (default 3) → takeover. Does NOT: push, deploy, widen the task, or
fix the implementer's code on accept.

## Steps
1. **Collect.** `cp $W/RESULT.md .orchestra/<run>/tasks/<id>.result.md`; read it and the task.
2. **Check:** `bash <skill-dir>/scripts/review-check.sh <run> <id>` (scope vs the task's
   "may change/create" files, the task's test command, then `test_cmd`/`lint_cmd` from
   `.orchestra/config.json`). Last line: `CHECK <id> scope=<ok|N-out> result=<yes|no>
   task=<pass|fail|none> suite=… lint=…`; a failing command shows its last 25 lines. Never
   rerun tests by hand.
   - `scope=N-out` → reject, unless only build artifacts (`__pycache__/`, `node_modules/`,
     coverage): delete them, rerun. `task=none` → spec bug, report it. Missing `test_cmd`/
     `lint_cmd` → add them to config from the repo's `CLAUDE.md` once.
3. **Read the diff, lockfiles excluded:** `git -C $W diff -- . ':!*.lock' ':!*-lock.*' ':!go.sum'`
   plus new files (`git -C $W ls-files -o --exclude-standard`, not RESULT.md). Look for:
   correctness, the spec's edge cases, error handling, the existing pattern, dead code, secrets,
   unnamed new deps, and:
   - **TDD:** each behaviour change has a test that would fail without it (no tests fitted to
     the output, no assertion-free or skipped/weakened tests).
   - **YAGNI:** no unused params/options, speculative abstractions or "just in case" branches.
   - **DRY:** existing helpers reused; no copy-pasted logic.
   Auth, input parsing, files or network: also check injection, authz, path traversal, SSRF
   (with the `code-review` skill's security pass if installed).
4. **Decide.**
   - **Accept:** "Done when" holds, checks pass, scope clean. `rm $W/RESULT.md`; commit in `W`
     (`<type>: <goal> (orchestra <run>/<id>)` + repo trailers); merge into `base_branch`; run
     `test_cmd` there (one line); `git worktree remove $W`; delete the branch. Nits only
     (naming, a comment) → accept and note them.
   - **Reject:** add `## Notes from review` to the task, one line per problem:
     `file:line — problem — fix`; bump `attempt`. The orchestrator sends it back with
     `claude-dispatch --continue`.
   - **Takeover:** rejection number `max_rejections`, or a problem beyond the implementer
     (spec design flaw, cross-cutting). The cheapest capable model implements it in `W`
     (choose with `references/takeover.md`); then review it with steps 2–4 and mark
     `taken-over` + model.
5. **Log** verdict, test numbers and reason in `board.md`: change only your task's row and append
   one Log line, as small in-place edits of the file as it is now (others write it while you
   review); never write the whole file back.
6. **Reply** with one line only: `MERGED <id> <commit> tests=<summary>` |
   `REJECTED <id> attempt=<n> notes=<count>` | `TAKEOVER <id> <model> <reason>`.

## Red flags
| If you notice… | Do this |
|---|---|
| Trusting RESULT.md's "all tests pass" | Run `review-check.sh` |
| Pasting test output or the diff into the reply | One verdict line; details in task/board |
| A file outside the allowed list | Reject (or revert it if harmless, and note it) |
| Tests weakened, skipped or deleted | Reject; say so explicitly |
| Rewriting the code on accept | Reject or take over instead |
| A vague note ("fix the bugs") | `file:line — problem — fix` |
| About to push | Don't; the user pushes |

## Done when
Merged (tests green on `base_branch`, worktree and branch gone), sent back with concrete notes,
or taken over — and `board.md` records which, with test numbers.
