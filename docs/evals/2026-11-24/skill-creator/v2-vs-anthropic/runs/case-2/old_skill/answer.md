Your description is `Helps with reviews.` It has no trigger and doesn't say what gets reviewed, so the model has nothing to match "I'm done" or "can I merge?" against. Below is the replacement and how I'd test it. I'm assuming the skill lives at `skills/review-helper/SKILL.md` (the case file I read).

## Steps, in order

1. **Snapshot the original** so it's the baseline for comparison:
   ```bash
   mkdir -p review-helper-workspace
   cp -r skills/review-helper review-helper-workspace/skill-snapshot/
   ```

2. **Edit the frontmatter in `skills/review-helper/SKILL.md`.** Only the `description` changes; `name` and the body stay the same.
   ```yaml
   ---
   name: review-helper
   description: Reviews a code diff for correctness and naming problems, giving one finding per issue with severity, file:line and a concrete fix, and ends with a "Ready to merge" / "Fix the 🔴 items first" verdict. Use when the user has just finished a change, asks to check or look over their diff, branch, commit or PR, or is about to merge, push or open a PR — even if they don't say "review" (e.g. "done, can I merge this?", "sanity-check before I push").
   ---
   ```
   - The "what it does" half comes from the body's Scope, so it only claims what the skill actually does.
   - The "Use when" half covers your two moments: finishing a change and before merging. It's deliberately broad, because skills tend to undertrigger.

3. **Write 20 trigger test queries** to `review-helper-workspace/trigger-eval.json`.
   - **Should trigger (10):**
     - "ok finished the retry logic in `src/http/client.ts`, anything wrong before I merge to main?"
     - "pr #212 is ready, look over the diff"
     - "done with the refactor, sanity check?"
     - "about to push `feat/billing-proration`, can you check it first"
     - "review my staged changes"
     - "is this branch good to merge? it renames `getUser` to `fetchUser` everywhere"
     - "just wrapped up the migration script, give it a once-over"
     - "before I open the PR can you look for bugs in the last 3 commits"
     - "lgtm-able? diff is in `git diff main`"
     - "finished the fix for the null check in `orders/service.py`, merge-ready?"
   - **Should not trigger (10 near-misses):**
     - "resolve this merge conflict in `package.json`"
     - "merge `feat/x` into main for me"
     - "review my cover letter"
     - "write a PR description for this branch"
     - "explain what this diff does"
     - "rewrite `parse_dates()` to be faster"
     - "add tests for the change I just made"
     - "what's a good code review checklist for my team?"
     - "squash my last 4 commits"
     - "review the architecture doc in `docs/design.md`"

4. **Show you the test set.**
   - I'd fill `assets/eval_review.html` with the queries, `review-helper` and the new description, write it to `/tmp/eval_review_review-helper.html`, and `open` it.
   - **I'd stop here** until you click "Export Eval Set", then read the newest `~/Downloads/eval_set*.json`.

5. **Run the optimization loop** in the background, and check its output for progress:
   ```bash
   python -m scripts.run_loop --eval-set review-helper-workspace/trigger-eval.json \
     --skill-path skills/review-helper --model claude-opus-5-5 --max-iterations 5 --verbose
   ```
   The loop holds back 40% of the queries and picks `best_description` by its score on those, so the result isn't tuned only to the queries it trained on.

6. **Apply `best_description`** if it beats the step 2 draft on the held-out queries, then show you the before and after with scores. Only the description changed, so the body's behavior doesn't need re-testing.

## Reply to you

> I replaced the description in `skills/review-helper/SKILL.md`:
>
> **Before:** `Helps with reviews.`
> **After:** "Reviews a code diff for correctness and naming problems … Use when the user has just finished a change, asks to check or look over their diff, branch, commit or PR, or is about to merge, push or open a PR — even if they don't say 'review'."
>
> The old one had no "use when", so Claude never connected "I'm done" or "can I merge?" to this skill. The new one names both moments and the casual ways people phrase them.
>
> To check that it fires when it should, and stays quiet on look-alikes like "resolve this merge conflict" or "review my cover letter", I've written 20 test prompts and opened them in your browser (`/tmp/eval_review_review-helper.html`). Edit or flip any you disagree with, click **Export Eval Set**, then tell me. I'll run the trigger test (about 5 rounds, in the background) and report the scores. The original is saved in `review-helper-workspace/skill-snapshot/` if you want to roll back.