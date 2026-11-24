Only the description needs to change. The current one, "Helps with reviews.", has no trigger words and doesn't say what the skill does, so Claude has nothing to match your request against. I'd leave the body alone. This is a dry run, so the steps below are what I would do; nothing has been written or run.

**1. Read in one parallel batch:** `CLAUDE.md`, one sibling skill for house style, the target `skills/review-helper/SKILL.md` (the copy in `case-files/2/SKILL.md`), and `skills/review-helper/evals/evals.json`. That eval file doesn't exist.

**2. Edit the frontmatter only** in `skills/review-helper/SKILL.md`:
```yaml
---
name: review-helper
description: Reviews a finished diff for correctness and naming bugs, one finding per issue with severity (🔴 must fix / 🟡 should fix), file:line and a fix, ending with a merge verdict. Use when the user finishes a change or says "review this", "check my diff", "I'm done", "is this ready to merge", "before I merge" or "before I open a PR".
---
```
That's about 340 characters, under the ~400 limit. It starts with what the skill does, then lists the phrases you'd actually type at both moments you named.

**3. Write `evals/evals.json`**, since the skill has none and evals are required:
```json
{
  "skill_name": "review-helper",
  "evals": [
    {"id": 1, "prompt": "Done with the discount change, can you look it over?", "files": ["evals/files/discount.diff"],
     "expected_output": "Findings with severity, file:line and fix, then a verdict.",
     "assertions": ["Flags the off-by-one at pricing.py:14 as 🔴", "Every finding cites file:line", "Last line is exactly 'Ready to merge' or 'Fix the 🔴 items first'"]},
    {"id": 2, "prompt": "About to merge this, anything blocking?", "files": ["evals/files/discount.diff"],
     "expected_output": "Says 'Fix the 🔴 items first'.",
     "assertions": ["Ends with 'Fix the 🔴 items first'", "Names pricing.py:14"]},
    {"id": 3, "prompt": "Quick check before I open the PR", "files": ["evals/files/rename.diff"],
     "expected_output": "Naming finding marked 🟡, verdict 'Ready to merge'.",
     "assertions": ["Flags the misleading name `tmp2` at util.py:3 as 🟡", "No 🔴 findings", "Ends with 'Ready to merge'"]},
    {"id": 4, "prompt": "Review this and just rewrite the function the way you'd do it.", "files": ["evals/files/discount.diff"],
     "expected_output": "Gives findings, does not rewrite the code.",
     "assertions": ["Contains no full rewritten function body", "Gives at least one finding with file:line and a fix"]}
  ]
}
```
It would also need two fixtures: `evals/files/discount.diff` (about 15 lines, with `range(1, len(items))` at `pricing.py:14` skipping the first item) and `evals/files/rename.diff` (about 8 lines, a correct helper whose variable is named `tmp2`).

**4. Validate:** `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/review-helper`, then fix any FAIL and rerun until it's clean.

---

**My reply to you:**

The description of `review-helper` now names what the skill does and lists the phrases you'd type when you finish a change or are about to merge. Nothing else in `SKILL.md` changed, and its size stays at about 0.8k characters (I'd take the exact number from the check output).

I also added 4 eval cases, because the skill had none:
1. You say you're done with a change → it finds the 🔴 off-by-one and ends with a verdict.
2. You ask before merging → it ends with "Fix the 🔴 items first".
3. You ask before opening a PR, on a clean diff → one 🟡 naming finding, then "Ready to merge".
4. You ask it to rewrite the code → it gives findings and doesn't rewrite.

Assumptions:
- The skill lives at `skills/review-helper/`.
- `frugal-skills:code-review` isn't installed alongside it. If it is, both descriptions trigger on "before merging", and you should pick one skill to own that trigger.
- The name stays `review-helper`.

Approve, or what should change? Next step is `skill-reviewer`. Its trigger check will show whether the new description actually fires on those phrases, and its baseline run will compare results with and without the skill.