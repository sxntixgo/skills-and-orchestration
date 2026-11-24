I won't write a fix yet. The `TypeError` is only the symptom. Adding `user?.id` or a null check would just hide it (the skill flags this as a red flag). First I need to find out why `user` is undefined.

**What I'd do, in order:**

1. **Find the line.** You didn't give a file or a stack trace, so I'd search for it:
   `grep -rn "return user.id" --include="*.{js,ts,jsx,tsx}" .` (excluding `node_modules`)
   - **No match, or several matches I can't tell apart:** stop and ask you for the full stack trace and how you trigger the error. Without that I can't reproduce it.
   - **One match**, say `getUserId(user)` in some file: carry on.

2. **Set up tracking.** Create TodoWrite items for Reproduce, Isolate, Hypothesize, Verify, Fix and Confirm. Start the notes file `./.claude-skills-work/debugging/user-id-undefined/notes.md` with the error text, the file and line, and the trigger.

3. **Reproduce (run it).** Find the callers with `grep -rn "getUserId(" .`, then write a failing test that goes through the real caller path, not one that passes `undefined` in directly. Run the single test (e.g. `npx jest path/to/test -t "..."`) and save the actual output in the notes. If I can't reproduce it, I'd collect logs, inputs and versions before going further.

4. **Isolate.** Start from the first error in the trace. Follow `user` back from where it's used to where it's produced, and compare a case that works with one that fails. If this used to work, run `git log -L` on the function and `git bisect` with the test.

5. **Hypothesize.** I'd write down one specific, testable cause. These are the usual suspects:
   - a fetch or lookup that isn't awaited, so `user` is a Promise or not set yet
   - `find()` or a database query that returns `undefined` for a missing record
   - reading a session or request before middleware has filled it in
   - destructuring the wrong property

6. **Verify before fixing.** Predict what a log or assertion at the source will show (e.g. "`await` is missing, so `typeof user` is `object`, a Promise, at the call site"), run it and check. If I'm wrong, go back to step 5. I'd change one thing at a time.

7. **Fix the cause** with the smallest change, e.g. add the missing `await`, or handle "user not found" explicitly where the lookup happens.

8. **Confirm.** Rerun the test from step 3 and show that it now passes, keep it as a regression test, and run the surrounding test suite.

**Reply to you:**
- **If step 1 finds nothing usable:** "I couldn't find `return user.id;` in a single obvious place. Please paste the full stack trace and the steps or request that trigger it. I'll reproduce it and fix why `user` is undefined, rather than guarding the property read."
- **Otherwise:** a short report with the repro command and its output before the fix, the cause and how I confirmed it, the diff, and the passing output after the fix.