---
name: debugging
description: Systematically diagnoses a bug before fixing it — reproduce, isolate, form a root-cause hypothesis, verify it, then fix and confirm. Use when facing a bug, test failure, crash, or unexpected behavior, before proposing a fix.
---

# Debugging

Find the cause before changing anything; a fix you can't explain is a guess. Six steps, in
order. When you can run commands, run them: a reproduction you only describe is not one.

## Scope
DOES: reproduce, isolate, verify the root cause, fix it, confirm with a regression test.
Does NOT: guess-and-check without a repro; patch the symptom while the cause stays (unless
that's a stated, deliberate choice); refactor unrelated code.

## Steps (TodoWrite items; notes in `./.claude-skills-work/debugging/<bug>/notes.md`)
1. **Reproduce** ⛔ — exact steps, inputs, environment; ideally a failing test. **Run it** and
   record the real output. Don't ask for what you can find yourself (which test, which file):
   look. Intermittent → run it several times, then vary the order/seed/clock to find the
   trigger. Can't reproduce → gather logs, inputs, versions first.
2. **Isolate** — read the full error and the *first* one; binary-search the code path; `git
   bisect` if it used to work; compare a working vs failing case and shrink the difference;
   reduce to the smallest failing input.
3. **Hypothesize the root cause**, specific and testable ("`user` is undefined because the fetch
   isn't awaited"), not a fix ("add a null check"). Usual suspects: boundaries (empty, first/
   last, inclusive/exclusive), async values read too early, state leaking between calls (cache,
   module-level or default mutable values), races/check-then-act, type coercion (`0`, `""`,
   `NaN`, float equality), environment (env vars, versions, timezone, case-sensitive paths).
4. **Verify the cause** before fixing: a log, assertion or test that holds only if you're right;
   predict, then check. Wrong → back to 3. One variable at a time. Timing-dependent bugs: make
   the source deterministic (inject clock/seed, fix ordering) instead of adding sleeps/retries.
5. **Fix the cause** with the minimal change.
6. **Confirm** — rerun the repro and show it passes; keep it as the regression test; run the
   surrounding tests.

Report: the repro (command + output before), the verified cause, the fix, the output after.

## Red flags
| If you notice… | Do this |
|---|---|
| A fix before a reproduction | Reproduce first |
| "I'd run the test" while you can run it | Run it |
| Fixing on a hunch | Verify the cause first |
| Null-guarding / try-catching the symptom | Find why; fix the cause |
| Several changes at once | One at a time |
| "It works now", cause unknown | Not done |
| No regression test | Add one |
| Unrelated refactors | Note them separately |

## Done when
Reproduced; root cause identified AND verified; minimal fix; repro passes and stays as a
regression test; you can say why it broke and why the fix works.
