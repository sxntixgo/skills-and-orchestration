---
name: debugging
description: Systematically diagnoses a bug before fixing it — reproduce, isolate, form a root-cause hypothesis, verify it, then fix and confirm. Use when facing a bug, test failure, crash, or unexpected behavior, before proposing a fix.
---

# Debugging

Find the cause before you change anything. A fix you can't explain is a guess.
Work the six steps in order — don't jump to step 5.

## Scope
This skill DOES:
- Reproduce the bug, narrow it to a verified root cause, fix that cause, and
  confirm the fix with a regression test.

This skill does NOT:
- Guess-and-check fixes without a reproduction.
- Patch the symptom while the root cause remains (a symptom mitigation is only
  OK when it's a deliberate, stated choice).
- Refactor or "clean up" unrelated code while chasing the bug.

## Steps
Surface these as TodoWrite items. Checkpoint repro steps, isolation notes, and
the verified cause to `./.claude-skills-work/debugging/<bug>/notes.md` so a long
hunt resumes.

### 1. Reproduce  ⛔ don't fix what you can't reproduce
Get a reliable repro: exact steps, inputs, environment. If it's intermittent,
find what makes it happen. A failing test is the ideal repro — write one if you
can. Can't reproduce it? Gather more information first (logs, inputs, versions).

### 2. Isolate
Narrow WHERE it happens. Binary-search the code path or history (`git bisect`),
add logging/assertions to localize, and find the boundary between working and
broken. Reduce to the smallest input/case that still fails.

### 3. Hypothesize (root cause, not symptom)
State a specific, testable hypothesis about the ROOT cause: "`user` is undefined
because the fetch isn't awaited, so `.id` reads on a pending promise." Not "add a
null check."

### 4. Verify the cause
Prove the hypothesis BEFORE fixing — a log, assertion, or failing test that
confirms the cause is what you think. If it doesn't hold, go back to step 3.
Change one variable at a time so you know what's true.

### 5. Fix the root cause
Make the minimal change that addresses the *verified* cause, not the symptom.
See `references/techniques.md` for common cause patterns.

### 6. Confirm
The repro now passes. Add a regression test so the bug can't silently return.
Check you didn't break nearby behavior (run the surrounding tests).

## Red flags (stop and correct)
| If you notice… | Do this |
|----------------|---------|
| Proposing a fix before reproducing | Reproduce first (step 1) |
| Fixing on a hunch | Verify the cause first (step 4) |
| Null-guarding / try-catching the symptom | Find why it's null/throwing; fix the cause |
| Changing several things at once | One variable at a time, or you won't know what fixed it |
| "It works now" but you don't know why | Not done — understand the cause |
| Fixed, but no regression test | Add one so it can't come back |
| Wandering into unrelated refactors | Stay on the bug; note other issues separately |

## Done when
- The bug is reproduced, and the root cause is identified AND verified (not guessed).
- The fix addresses that cause; the repro passes and a regression test covers it.
- You can explain *why* it broke and *why* the fix works.

## References (load only when needed)
- `references/techniques.md` — isolation techniques (bisection, differential
  debugging), verifying a cause, and common bug patterns (races, state leakage,
  off-by-one, heisenbugs).
