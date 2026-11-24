The description was too vague to match anything. "Helps with reviews." doesn't name an action, an object or a trigger, so Claude has nothing to match against "I'm done" or "ready to merge". I'd replace line 3 and leave the body alone.

**Steps, in order:**

1. Invoke `skill-authoring:skill-creator`, as CLAUDE.md requires for skill edits.
2. Edit `skills/review-helper/SKILL.md:3`. I'm assuming the directory is `review-helper`, which matches `name`. New frontmatter:

```yaml
---
name: review-helper
description: Reviews a diff for correctness and naming bugs, giving one severity-ranked finding per issue with file:line and a fix, plus a merge verdict. Use when a code change is finished, when asked to review a diff, branch or PR, or before merging, committing or opening a pull request.
---
```

   - The first sentence says what it does, using the words the body uses (diff, finding, merge).
   - The second sentence covers your two triggers ("finish a change" and "before merging") plus the common ways people phrase them (review this, commit, PR).
   - It's in the third person, per house style.

3. Add trigger cases to `skills/review-helper/evals/evals.json`. If that file doesn't exist I'd create it, because rule 8 requires it.

```json
{
  "skill_name": "review-helper",
  "evals": [
    {"id": "trigger-finished", "prompt": "Done with the retry logic in fetch.ts, take a look?", "expected": "Skill loads; findings with 🔴/🟡, file:line, fix; ends with merge verdict."},
    {"id": "trigger-premerge", "prompt": "About to merge feature/auth into main.", "expected": "Skill loads before merge; verdict line present."},
    {"id": "trigger-pr", "prompt": "Review my PR diff before I open it.", "expected": "Skill loads."},
    {"id": "no-trigger-write", "prompt": "Write a function that parses ISO dates.", "expected": "Skill does NOT load."},
    {"id": "no-trigger-explain", "prompt": "Explain what this regex does.", "expected": "Skill does NOT load."}
  ]
}
```

4. Invoke `skill-authoring:skill-reviewer` on the edited skill. Running the with-skill vs. without-skill trigger comparison is a dev-time eval, so I'd offer it rather than start it.

**Final message to you:**

> I've replaced the `review-helper` description at `SKILL.md:3`. It now names what the skill does (correctness and naming review, file:line, merge verdict) and triggers on "finished a change", "review this diff/PR" and "before merging, committing or opening a PR". I also added 3 should-trigger and 2 should-not-trigger cases to `evals/evals.json`.
>
> One risk: if `frugal-skills:code-review` is installed too, the two descriptions compete for the same prompts. If that's the case, either narrow this one (for example, to naming plus correctness only) or drop it.
>
> Want me to run the trigger eval to confirm it fires now?