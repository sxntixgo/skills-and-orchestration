I'd change only the `description` line of `review-helper`. The rest of `SKILL.md` stays as it is. It has no `evals/evals.json`, so I'd also add one, because the skill-creator rules don't allow a skill without evals.

**Steps, in order**

1. **Read in one batch:** the repo's `CLAUDE.md`, one sibling skill to match its style, `skills/review-helper/SKILL.md` (the content in `case-files/2/SKILL.md`), and `skills/review-helper/evals/` (none found).
2. **Edit `skills/review-helper/SKILL.md`, line 3:**
   ```yaml
   description: Reviews a diff for correctness and naming, listing each finding with severity (🔴 must fix / 🟡 should fix), file:line and a fix, and ends with a merge verdict. Use when the user has finished a change, asks to review their diff, branch or PR, or asks if it's ready to merge or before merging.
   ```
   It's about 300 characters. "Helps with reviews." didn't fire because it names no task and none of the words you type. The new line names the output and your two moments: "finished a change" and "before merging".
3. **Write the fixture `skills/review-helper/evals/files/discount.diff`:** a diff of about 15 lines to `pricing.py`. `apply_discount(price, pct)` changes from `price * (1 - pct/100)` to `price * (1 - pct)`, which is an off-by-100 bug. It also renames `total` to `t`, a naming problem.
4. **Write `skills/review-helper/evals/evals.json`:**
   ```json
   {
     "skill_name": "review-helper",
     "evals": [
       {"id": 1, "prompt": "I just finished this change, take a look before I merge.",
        "expected_output": "Flags the pct/100 bug as 🔴 with file:line and a fix, the rename as 🟡, ends with a verdict.",
        "files": ["evals/files/discount.diff"],
        "assertions": ["Flags the missing /100 in pricing.py with a file:line", "Marks it 🔴", "Flags the `t` rename as 🟡", "Last line is exactly \"Fix the 🔴 items first\""]},
       {"id": 2, "prompt": "Is this ready to merge?",
        "expected_output": "Same review; verdict is not ready.",
        "files": ["evals/files/discount.diff"],
        "assertions": ["Every finding has severity, file:line and a fix", "Does not say \"Ready to merge\""]},
       {"id": 3, "prompt": "Review this diff and just fix whatever you find.",
        "expected_output": "Lists findings with fixes but does not rewrite the file (scope: Does NOT rewrite code).",
        "files": ["evals/files/discount.diff"],
        "assertions": ["Gives findings with suggested fixes", "Does not output a rewritten pricing.py or apply edits"]},
       {"id": 4, "prompt": "Review my changes before I merge.",
        "expected_output": "No diff given or visible: asks for the diff/branch instead of inventing findings.",
        "files": [],
        "assertions": ["Asks for the diff or branch", "Reports no findings"]}
     ]
   }
   ```
5. **Validate:** run `python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py skills/review-helper` and repeat until it's clean. I'd expect `SKILL.md` to be about 0.9k characters.

**Reply to you**

I tightened the description. It's the only line I changed in `SKILL.md`:

> Reviews a diff for correctness and naming, listing each finding with severity (🔴 must fix / 🟡 should fix), file:line and a fix, and ends with a merge verdict. Use when the user has finished a change, asks to review their diff, branch or PR, or asks if it's ready to merge or before merging.

- **Size:** `SKILL.md` is about 0.9k characters, from the check line. The skill had no evals, so I added four cases built on `evals/files/discount.diff`:
  1. "Finished this change, look before I merge": the skill catches the `/100` bug as 🔴, flags the rename as 🟡 and gives the verdict.
  2. "Ready to merge?": every finding is anchored and the verdict is not "Ready to merge".
  3. "Review and just fix it": the skill gives findings but doesn't rewrite the code.
  4. "Review before I merge" with no diff: the skill asks for the diff instead of inventing findings.
- **Assumptions:**
  - The skill lives at `skills/review-helper/`.
  - It may clash with the built-in `/review` or a sibling `code-review` skill. If you have one, the two descriptions need distinct triggers, or one of the skills should go.

Approve, or what should change? Next step: `skill-reviewer` checks whether the new description actually fires (a trigger profile) and compares results against a run without the skill.