I can't confirm it yet. A description edit changes **when the skill triggers**, not how well it reviews, so the check is a trigger A/B: run the same prompts against the old and new descriptions and compare. I have only the new `SKILL.md`. I'm assuming the old version is the committed one at `HEAD`.

## What I'd do, in order

**1. Get the old version and check what changed.**
```bash
mkdir -p .claude-skills-work/evals/code-review/desc-ab/{old,new}
git diff HEAD -- skills/code-review/SKILL.md
git show HEAD:skills/code-review/SKILL.md > .claude-skills-work/evals/code-review/desc-ab/old/SKILL.md
cp skills/code-review/SKILL.md .claude-skills-work/evals/code-review/desc-ab/new/SKILL.md
```
If the diff touches the body as well as `description:`, I'd stop and ask. That would also need an output-quality A/B using `evals/evals.json`, not just a trigger test.

**2. Write the trigger set** to `.claude-skills-work/evals/code-review/desc-ab/triggers.json`:
```json
{"skill_name":"code-review","trigger_evals":[
 {"id":"t1","prompt":"Review src/orders/discount.ts before I merge it","should_trigger":true},
 {"id":"t2","prompt":"Can you look over PR #42 and tell me what's wrong?","should_trigger":true},
 {"id":"t3","prompt":"Is this login handler safe? (pastes JWT verify code)","should_trigger":true},
 {"id":"t4","prompt":"Sanity-check my diff: git diff main","should_trigger":true},
 {"id":"t5","prompt":"Any bugs in this upload endpoint?","should_trigger":true},
 {"id":"t6","prompt":"Give feedback on this function's readability","should_trigger":true},
 {"id":"t7","prompt":"Before I ship, anything risky in the new file-download route?","should_trigger":true},
 {"id":"t8","prompt":"critique utils/retry.py","should_trigger":true},
 {"id":"n1","prompt":"Add a login endpoint with JWT auth","should_trigger":false},
 {"id":"n2","prompt":"Write a function that reads a config file from disk","should_trigger":false},
 {"id":"n3","prompt":"Fix the failing test in test_cart.py","should_trigger":false},
 {"id":"n4","prompt":"Explain what this regex does","should_trigger":false},
 {"id":"n5","prompt":"Rotate the API secret in .env","should_trigger":false},
 {"id":"n6","prompt":"Refactor the DB access layer to use the repository pattern","should_trigger":false},
 {"id":"n7","prompt":"Merge the feature branch into main","should_trigger":false},
 {"id":"n8","prompt":"Write a review of this paper's methodology","should_trigger":false}
]}
```
The should-not cases (`n1`, `n2`, `n5`, `n6`) are aimed at the new clause "when a change touches auth, input handling, data access, file/network I/O or secrets". That clause could make the skill fire while you're *writing* such code, not reviewing it.

**3. Run each prompt 3 times per arm** in fresh headless sessions, once with each description installed as the plugin:
```bash
for arm in old new; do  # swap arm's SKILL.md into a temp plugin copy first
  for id in ...; do for r in 1 2 3; do
    claude -p "$PROMPT" --plugin-dir "$TMP_PLUGIN_$arm" --output-format stream-json --max-turns 1 \
      > .claude-skills-work/evals/code-review/desc-ab/$arm/$id-$r.jsonl
  done; done
done
```
A run counts as triggered if it contains a `Skill` tool_use for `frugal-skills:code-review`. Only the first turn matters, so `--max-turns 1` keeps the runs cheap. No subagents are needed.

**4. Score** into `.claude-skills-work/evals/code-review/desc-ab/benchmark.json`, per arm:
- **Recall:** how often it fired on the should-trigger prompts.
- **False-positive rate:** how often it fired on the should-not prompts.
- **Description token count.**

**5. Decision rule:** the new version is better only if recall is at least as high as the old one's, false positives are no higher, and at least one of them is strictly better. If both tie, it's only better if it's also shorter. If either gets worse, it isn't better, and I'd show which prompts flipped.

## Problems I can already see in the new description
- **Over-triggering risk:** "when a change touches auth, input handling, data access, file/network I/O or secrets" describes the code, not the review. That matches most backend coding tasks. Suggested fix: "Use when asked to review, audit or check code… especially changes touching auth, input handling…".
- **Wasted words:** "(and an exploit scenario for each vulnerability)" describes what the output contains. It doesn't help the skill decide when to fire, so it costs tokens every session for no benefit.
- **Length:** at about 75 words it isn't obviously "tight". Step 1 will show whether it's actually shorter than the old one.

## Reply after the run
"New vs old description: recall X/24 vs Y/24, false positives A/24 vs B/24, N vs M tokens. **Verdict: better / not better / no measurable difference.** Prompts that flipped: … Full results: `.claude-skills-work/evals/code-review/desc-ab/benchmark.json`."