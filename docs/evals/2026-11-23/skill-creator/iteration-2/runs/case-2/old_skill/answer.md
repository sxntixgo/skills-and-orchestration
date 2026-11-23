I'd only change the `description` field in the skill's frontmatter, then run a trigger eval to check that it fires when it should and stays quiet otherwise.

**1. Find the skill and read it**
```bash
find . ~/.claude -path '*code-review*/SKILL.md' 2>/dev/null
```
- **Assumed location:** `.claude/skills/code-review/SKILL.md`
- **Assumed current description:** `description: Helps with code review.`
- **Assumed body:** it reads `git diff` against the base branch, checks for bugs, security issues, missing tests and style, and reports findings by severity.

I'd read the whole body so the new description only promises what the skill actually does.

**2. Rewrite the description** (frontmatter only; the body stays as it is)
```yaml
---
name: code-review
description: Reviews the current code changes (uncommitted work, the branch diff against main, or an open PR) for bugs, security issues, missing tests, and style problems, and reports findings by severity. Use this whenever the user finishes a change or is about to merge, even if they don't say "review". Triggers include "done with this feature", "I think that's it", "ready to merge", "can you check before I open a PR", "look over my diff", "anything wrong with this branch?", or finishing an implementation task and asking what's next. Do not use for explaining unfamiliar code, writing new features, or fixing a specific bug the user already identified.
---
```
Why it's worded this way:
- It says both what the skill does and when to use it, in the third person.
- It lists real trigger phrases for the two moments you care about: finishing a change and before merging.
- It's deliberately a little pushy ("even if they don't say 'review'"), because vague descriptions tend to under-trigger.
- It names near-misses to keep false positives down.
- It's under 1024 characters.

**3. Write a trigger eval set** at `.claude/skills/code-review/evals/trigger-evals.json`
```json
[
  {"query": "ok I think the pagination change is done", "should_trigger": true},
  {"query": "ready to merge feature/auth-refresh, anything I missed?", "should_trigger": true},
  {"query": "before I open the PR can you look over my diff", "should_trigger": true},
  {"query": "finished wiring the webhook handler, tests pass", "should_trigger": true},
  {"query": "is this branch safe to merge into main?", "should_trigger": true},
  {"query": "check my uncommitted changes for problems", "should_trigger": true},
  {"query": "that's the last of the refactor I think", "should_trigger": true},
  {"query": "review PR #142", "should_trigger": true},
  {"query": "explain how the retry logic in client.ts works", "should_trigger": false},
  {"query": "add a --dry-run flag to the CLI", "should_trigger": false},
  {"query": "the login test fails with a 401, fix it", "should_trigger": false},
  {"query": "merge main into my branch and resolve conflicts", "should_trigger": false},
  {"query": "write a code review checklist doc for the team wiki", "should_trigger": false},
  {"query": "rename UserSvc to UserService everywhere", "should_trigger": false}
]
```

**4. Run the trigger test**

I'd run each query 3 times through `claude -p` with the skill installed and record whether the Skill tool was called for `code-review`. If skill-creator's description-optimization script is in the repo, I'd use that instead. I'd log a pass rate for each query:
- **If a should-trigger query passes in fewer than 2 of 3 runs:** add its phrasing to the trigger list.
- **If a should-not query fires:** sharpen the exclusions.

I'd allow at most 2–3 revision rounds and keep the description that scores best on held-out queries, not the one tuned hardest to the training set.

**5. Final message**

> I rewrote the `code-review` description in `.claude/skills/code-review/SKILL.md`. It now names the moments it should fire on (finishing a change, "ready to merge", before opening a PR, "check my diff") and excludes explaining code, building features and fixing a known bug. Trigger eval: X/8 should-trigger queries fired and 0/6 near-misses fired (3 runs each, set saved in `evals/trigger-evals.json`). Only the frontmatter changed. If you usually say something else when you finish (e.g. "ship it"), tell me and I'll add it.