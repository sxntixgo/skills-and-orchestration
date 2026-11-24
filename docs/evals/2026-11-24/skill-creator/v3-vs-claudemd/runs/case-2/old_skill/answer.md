The description was the problem. "Helps with reviews." says nothing about what the skill does or when to use it, so Claude never has a reason to load it. Here's the change. This is a dry run, so nothing has been run or written to disk yet.

**Steps, in order**

1. Invoke `skill-authoring:skill-creator`, as CLAUDE.md requires for editing a skill.
2. Edit only the frontmatter of the skill. I'm assuming it lives at `skills/review-helper/SKILL.md`, with the contents in `case-files/2/SKILL.md`:

```yaml
---
name: review-helper
description: Reviews a code diff for correctness and naming bugs, returning severity-ranked findings (🔴 must fix / 🟡 should fix) with file:line and a concrete fix, ending in a merge verdict. Use when the user finishes a change or a task, asks to review their changes, a diff, branch or PR, or is about to merge, open a PR or ask "is this ready to merge?". Not for writing or rewriting code.
---
```

   The new description follows the house "what it does. Use when …" format. It names the user's two triggers ("finishes a change" and "before merging") plus the words people actually say, and it says what the skill isn't for, so it won't fire while you're writing code.

3. Add `skills/review-helper/evals/evals.json`. The skill doesn't have one, and CLAUDE.md rule 8 requires it. These cases test whether the skill triggers:

```json
{
  "skill_name": "review-helper",
  "evals": [
    {"id": 1, "prompt": "Done with the auth refactor, take a look before I merge.",
     "expected_output": "Skill triggers; findings with severity, file:line, fix; ends with merge verdict."},
    {"id": 2, "prompt": "I just finished the pagination change in api/list.py.",
     "expected_output": "Skill triggers and reviews the diff."},
    {"id": 3, "prompt": "Is this branch ready to merge?",
     "expected_output": "Skill triggers; last line is 'Ready to merge' or 'Fix the 🔴 items first'."},
    {"id": 4, "prompt": "Write a function that parses ISO dates.",
     "expected_output": "Skill does NOT trigger."},
    {"id": 5, "prompt": "Rename getUser to fetchUser everywhere.",
     "expected_output": "Skill does NOT trigger; no review output."}
  ]
}
```

4. Invoke `skill-authoring:skill-reviewer`. It runs the cases in a fresh session against the old description ("Helps with reviews.") and the new one, then records the trigger rate on cases 1–3 and the false-trigger rate on cases 4–5 in `.claude-skills-work/evals/review-helper/iteration-1/benchmark.json`.
5. Run `/reload-plugins`, then tick the matching checkbox in `plan.md` if there is one.

**Reply to you**

I rewrote the `review-helper` description so it names what the skill does and when to use it: after you finish a change, when you ask for a review of a diff, branch or PR, and before a merge or PR. It also says it isn't for writing code, so it won't fire while you're coding. The skill body is unchanged. I added 5 test cases: 3 where the skill should trigger and 2 where it shouldn't.

If it still doesn't trigger after this, check that the plugin is actually loaded (`claude --plugin-dir .`, then `/reload-plugins`). A skill that isn't loaded can't trigger, however good the description is.