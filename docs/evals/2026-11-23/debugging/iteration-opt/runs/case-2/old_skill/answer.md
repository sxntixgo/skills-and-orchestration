I won't patch this yet. Adding `user?.id` would only hide the error, and nothing would explain why `user` is undefined. Here's what I'd do, in order.

**1. Track the work**
- TodoWrite items: Reproduce, Isolate, Hypothesize, Verify cause, Fix root cause, Confirm.
- Create `./.claude-skills-work/debugging/user-id-undefined/notes.md` with:
  ```
  # Bug: TypeError reading 'id' of undefined at `return user.id;`
  ## Repro
  (pending: need file, stack trace and trigger)
  ## Isolation notes
  ## Hypotheses
  ## Verified cause
  ```

**2. Find the line**
- Run `git grep -n "return user.id;"`.
- You didn't give a file, stack trace or trigger, so I'm not assuming which call site it is.
  - **One hit:** read that function and every caller (`git grep -n "<fnName>("`) to see where `user` comes from.
  - **Several hits:** I can't tell which one throws without the stack trace, so I stop and ask you.

**3. Reproduce (step 1, the gate)**
- Write a failing test that calls the function the same way the failing caller does, and run only that test.
- I don't fix anything until this test fails with the same TypeError.

**4. Isolate and form a hypothesis (steps 2–3)**
I'd follow `user` back to where its value is set and check the usual causes:
- **Async:** a fetch or DB lookup isn't awaited, or failed without an error, so `user` is undefined.
- **Lookup misses:** something like `users.find(...)` returns undefined because the ID types differ (`"1"` vs `1`), or the record doesn't exist.
- **Wrong source:** the caller passes `req.user` before the auth middleware has run, or destructures the wrong field.
- **Regression:** if this used to work, `git bisect` with the failing test.

**5. Verify (step 4)**
- Add one assertion or log at the point I suspect, and predict what it will show.
- Run the test. If the prediction is wrong, go back to step 4.

**6. Fix and confirm (steps 5–6)**
- Make the smallest change that fixes the verified cause, such as adding the missing `await`, making the ID types match, or handling "user not found" where the lookup happens.
- Run the new test as the regression test, plus the tests around it.
- Record the cause and fix in `notes.md`.

**Reply to you:**

> Before I fix this I need to reproduce it. Can you send:
> 1. The full stack trace, or at least the file and function containing `return user.id;`
> 2. What triggers it: the request, command or test, and the inputs.
> 3. Whether it ever worked. If so, roughly when it broke, or a known-good commit.
>
> A null check would hide the crash and leave the real cause. In the meantime I'll search for the line and write a failing test if there's only one call site.