I can't say yet whether the new description is better. Only the description changed, so the useful test is whether it makes Claude load the skill for the right requests and skip it for the wrong ones. Testing the quality of the review itself wouldn't tell us anything, because both versions have the same instructions. I've drafted 20 test requests and need you to approve them before I run both descriptions against them.

## What I'd do, in order

1. **Get the old version and check the diff.**
   ```bash
   git diff HEAD -- skills/code-review/SKILL.md
   mkdir -p code-review-workspace/skill-snapshot
   git show HEAD:skills/code-review/SKILL.md > code-review-workspace/skill-snapshot/SKILL.md
   ```
   - I'm assuming the old description at HEAD was looser, something like *"Reviews code for quality and security issues. Use when the user asks for a code review."*
   - I'm assuming the instructions themselves didn't change. If the diff shows they did, I'd also run the old and new versions on review tasks and compare the results.

2. **Write 20 test requests.** About half should load the skill and half shouldn't. They go in `code-review-workspace/trigger-eval.json`:
   ```json
   [
    {"query": "can you look over my diff in src/billing/discount.ts before I merge? added percentage discounts, want to make sure nothing's off", "should_trigger": true},
    {"query": "PR #212 changes the login handler to accept a refresh token from a cookie — review it pls", "should_trigger": true},
    {"query": "I added a file upload endpoint in api/uploads.py (saves to /var/data/<filename>). anything I should worry about before shipping?", "should_trigger": true},
    {"query": "sanity check my changes to the orders repo query builder, I switched from the ORM to raw SQL for perf", "should_trigger": true},
    {"query": "is this ok to merge? git diff main...feature/webhooks", "should_trigger": true},
    {"query": "my teammate wrote utils/retry.go, give me feedback I can paste into the PR comments", "should_trigger": true},
    {"query": "we now store the stripe key in config.yaml instead of env, review the change in config/loader.js", "should_trigger": true},
    {"query": "go through handlers/admin.rb and tell me what's wrong with it, it feels messy and I think there's an authz hole", "should_trigger": true},
    {"query": "quick look at this function for bugs? (pasted 40 lines of python computing pro-rated refunds)", "should_trigger": true},
    {"query": "fix the failing test in tests/test_cart.py, it broke after my last commit", "should_trigger": false},
    {"query": "refactor services/notify.ts to use the new EmailClient, keep behaviour the same", "should_trigger": false},
    {"query": "write unit tests for the parseInvoice function in lib/invoice.py", "should_trigger": false},
    {"query": "explain what this regex in validators.js does: ^(?=.*\\d)(?=.*[a-z]).{8,}$", "should_trigger": false},
    {"query": "set up eslint + prettier for this repo with our usual rules", "should_trigger": false},
    {"query": "review my README and tell me if the install section is clear", "should_trigger": false},
    {"query": "add JWT auth to the express app — routes in src/routes, use RS256", "should_trigger": false},
    {"query": "write a code review checklist doc for our team wiki (markdown, ~1 page)", "should_trigger": false},
    {"query": "why is my docker build so slow? Dockerfile is in the root", "should_trigger": false},
    {"query": "resolve the merge conflicts in src/api/users.ts after rebasing on main", "should_trigger": false},
    {"query": "summarize what changed between v1.3 and v1.4 for the release notes", "should_trigger": false}
   ]
   ```
   The requests that shouldn't load the skill are close calls on purpose: reviewing a README, writing a review checklist, building auth, resolving merge conflicts. These are where a tightened description is most likely to gain or lose.

3. **Pause for your review.** I'd fill `assets/eval_review.html` with the requests, the skill name and the current description, save it as `/tmp/eval_review_code-review.html`, and run `open` on it. You'd edit the requests or flip their labels, then click "Export Eval Set". I'd then use the newest `~/Downloads/eval_set*.json`.

4. **Run both descriptions against the same approved set.** Each request runs 3 times per description, using the model this session runs on:
   ```bash
   python -m scripts.run_eval --eval-set code-review-workspace/trigger-eval.json \
     --skill-path code-review-workspace/skill-snapshot --model claude-opus-5-5 \
     > code-review-workspace/old-trigger.json
   python -m scripts.run_eval --eval-set code-review-workspace/trigger-eval.json \
     --skill-path skills/code-review --model claude-opus-5-5 \
     > code-review-workspace/new-trigger.json
   ```
   I'd run these in the background and check the output periodically. I'm not using `run_loop`, because it rewrites the description and you asked for a comparison, not a rewrite.

5. **Report.** A table with, for each version: how many should-load requests loaded the skill, how many should-not requests correctly didn't, and the overall accuracy. I'd also list each request where the old and new versions behaved differently.
   - The new version is better only if it doesn't miss more of the should-load requests. Claude already tends to skip skills it would benefit from, so a tighter description is more likely to lose real reviews than to cut false ones.
   - The new description now names auth, input handling, data access, file/network I/O and secrets, so the upload, Stripe-key and admin-authz requests should show whether that helps.

## Reply to you

> Only the description changed, so I'm testing whether it makes the skill load for the right requests and not the wrong ones. I've written 20 test requests: 9 should load the skill, 11 shouldn't, and several of those are deliberately close calls. They're open at `/tmp/eval_review_code-review.html`. Edit them if they don't match how you actually ask for reviews, then click **Export Eval Set** and tell me when you're done. I'll run the old and new descriptions 3 times each on the same requests and show you which works better and where they differ.