I'd only rewrite the `description:` line (frontmatter line 3). The body stays the same. I'd also add evals, because the skill doesn't have any yet.

**1. Edit `skills/review-helper/SKILL.md`, line 3.** I'm assuming the skill lives at that path in your repo.

Old:
```yaml
description: Helps with reviews.
```
New (347 chars):
```yaml
description: Reviews a finished change or diff for correctness and naming bugs, listing each finding with severity, file:line and a fix, and ending with a merge verdict. Use when the user finishes a change, says "done", "review this", "check my diff/changes", "is this ready to merge", "before I merge" or "before I open a PR", or asks for a code review.
```
"Helps with reviews." never fired because it gives Claude no task and no words to match. The new description says what the skill does and lists the phrases you actually type at those two moments.

**2. Write `skills/review-helper/evals/evals.json`.** There was no evals file. You only asked for the description, but the house rules require evals, and the trigger fix can't be measured without them.

```json
{
  "skill_name": "review-helper",
  "evals": [
    {"id": "finish-change", "prompt": "Done with the retry logic in fetch.py, take a look.",
     "expected_output": "Skill triggers; findings with severity and file:line; verdict line.",
     "files": ["evals/files/fetch.diff"],
     "assertions": ["Names the off-by-one at fetch.py:14 as 🔴",
                    "Every finding cites file:line",
                    "Last line is exactly \"Ready to merge\" or \"Fix the 🔴 items first\""]},
    {"id": "pre-merge", "prompt": "Is this ready to merge?",
     "expected_output": "Skill triggers on the merge question and reviews the diff.",
     "files": ["evals/files/fetch.diff"],
     "assertions": ["Names the off-by-one at fetch.py:14",
                    "Ends with \"Fix the 🔴 items first\""]},
    {"id": "naming-only", "prompt": "Review my diff before I open a PR.",
     "expected_output": "🟡 naming finding with a concrete rename.",
     "files": ["evals/files/rename.diff"],
     "assertions": ["Flags `tmp2` at util.py:7 as 🟡 with a suggested name",
                    "Contains no rewritten code blocks over 5 lines"]},
    {"id": "no-trigger", "prompt": "Write a function that parses ISO dates.",
     "expected_output": "Skill does not trigger; no review output.",
     "files": [],
     "assertions": ["Response has no 🔴/🟡 findings", "No merge-verdict line"]},
    {"id": "no-diff", "prompt": "Review my change before merging.",
     "expected_output": "No diff or changes exist, so it stops and asks which change to review.",
     "files": [],
     "assertions": ["Asks which diff/branch to review", "Reports no findings"]}
  ]
}
```

**3. Write the two fixtures:**
- `evals/files/fetch.diff`: about 20 lines. It adds `for i in range(retries + 1)` at fetch.py:14 even though the docstring says "retries total".
- `evals/files/rename.diff`: about 10 lines. It adds `tmp2 = parse(row)` at util.py:7.

**4. Validate:** `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/review-helper`. I'd fix any FAILs and rerun until it prints `CHECK: PASS`. This is a dry run, so that result is expected, not actually run.

---

**Reply to you:**

I've rewritten the `review-helper` description; nothing else in the `SKILL.md` changed.
> Reviews a finished change or diff for correctness and naming bugs, listing each finding with severity, file:line and a fix, and ending with a merge verdict. Use when the user finishes a change, says "done", "review this", "check my diff/changes", "is this ready to merge", "before I merge" or "before I open a PR", or asks for a code review.

The check should print `CHECK: PASS`, but I haven't actually run it.

I added evals because there weren't any:
- `finish-change`: "done, take a look" triggers the skill and it finds the 🔴 bug at fetch.py:14.
- `pre-merge`: "ready to merge?" triggers the skill and the verdict line is correct.
- `naming-only`: "before I open a PR" gets a 🟡 rename finding at util.py:7.
- `no-trigger`: an unrelated coding request does not fire the skill.
- `no-diff`: when there's no diff, it stops and asks which change to review.

Assumptions:
- The skill is at `skills/review-helper/`.
- I kept the name `review-helper`. Renaming it to something like `code-review` would also help it trigger, but you didn't ask for that.

Approve, or what should change? Next step: run `skill-reviewer` to measure whether it triggers more often with the new description than with the old one.