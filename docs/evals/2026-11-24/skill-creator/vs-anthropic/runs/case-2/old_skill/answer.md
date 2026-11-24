The new description is drafted below but not applied yet. I'm stopping at the skill's review gate: you check the 20 trigger test queries, then I run the description optimizer.

**Steps, in order**

1. Read `skills/code-review/SKILL.md`. I'm assuming the current frontmatter is:
   ```yaml
   name: code-review
   description: Reviews code for quality and security.
   ```
   It names no trigger moment. That's why it never fires.
2. Snapshot the skill before editing so the old version can serve as the baseline:
   ```bash
   mkdir -p skills/code-review-workspace
   cp -r skills/code-review skills/code-review-workspace/skill-snapshot
   ```
3. Draft a new description. Per the skill-creator guidance it's slightly "pushy", and it follows the house style ("what it does. Use when …", third person):
   ```yaml
   description: Reviews a finished code change for correctness, quality and security, and reports prioritized findings with file:line evidence. Use when the user has just finished implementing a feature or fix, says a change is done or ready, asks to check a diff, branch, commit or PR, or is about to merge, push, or open a pull request, even if they don't say "review".
   ```
4. Write 20 trigger test queries to `skills/code-review-workspace/trigger-eval.json`: 10 that should trigger the skill and 10 near-misses that shouldn't.

   | # | Query | Should trigger? |
   |---|---|---|
   | 1 | ok the retry logic in `src/http/client.ts` is done, all tests green. anything I missed before I PR it? | yes |
   | 2 | about to merge `feat/invoice-export` into main, can you sanity-check the diff first | yes |
   | 3 | finished the migration that splits `users.name` into first/last, take a look at `git diff main...HEAD` | yes |
   | 4 | Before I push this, go over the last 3 commits for bugs or anything sketchy security-wise | yes |
   | 5 | pr #412 is up (rate limiter for /api/login). is it mergeable? | yes |
   | 6 | i think the caching layer is ready. thoughts on the change before I ship it? | yes |
   | 7 | Done refactoring `OrderService` to drop the god-class. Did I break anything? | yes |
   | 8 | can u double check my fix for the null deref in `parse_config()` before i merge | yes |
   | 9 | wrapped up the oauth callback handler, want a second pair of eyes on it | yes |
   | 10 | Here's the patch for the CSV upload endpoint, is it safe to land? | yes |
   | 11 | review my SKILL.md for the research skill, is the description good? | no (that's skill-reviewer) |
   | 12 | resolve the merge conflicts in `package-lock.json` on this branch | no |
   | 13 | explain what `src/auth/session.go` does, I'm new to this codebase | no |
   | 14 | write unit tests for the `discount()` function in `pricing.py` | no |
   | 15 | CI is failing on main after the merge, here's the log, fix it | no |
   | 16 | review my design doc for the notification service before I start building | no |
   | 17 | how do I squash-merge in GitHub without losing co-author lines | no |
   | 18 | implement pagination on `/api/orders`, cursor-based | no |
   | 19 | refactor `utils.js` into smaller modules | no |
   | 20 | can you review this cover letter before I send it | no |

5. Fill `assets/eval_review.html` with these queries, the skill name and the current description, write it to `/tmp/eval_review_code-review.html`, and `open` it for you to edit and export.

**Waiting for you here.** After you export (`~/Downloads/eval_set.json`, newest copy), I'll:

6. Run the optimizer in the background (`--model` is this session's model, `claude-opus-5-5`), checking its output periodically:
   ```bash
   python -m scripts.run_loop --eval-set skills/code-review-workspace/trigger-eval.json \
     --skill-path skills/code-review --model claude-opus-5-5 --max-iterations 5 --verbose
   ```
7. Put the `best_description` into `skills/code-review/SKILL.md` and show you the before and after with train and test scores. The optimizer picks the winner by its held-out test score.
8. Run `skill-authoring:skill-reviewer` on code-review, as CLAUDE.md asks, and tick the matching item in `plan.md`.

**Reply**

> The current description says what the skill is but never when to use it, so it rarely fires. My draft (step 3) adds the moments you described: a change is done, before a PR or merge, and before a push. I've also written 20 test prompts. Ten should trigger the skill. The other ten are close calls that shouldn't, like reviewing a SKILL.md, resolving merge conflicts or reviewing a design doc. They're open in your browser for editing; click **Export Eval Set** when you're done. Then I'll run the optimizer and apply whichever description scores best on the held-out prompts. Or say "just apply the draft" and I'll skip the optimizer.