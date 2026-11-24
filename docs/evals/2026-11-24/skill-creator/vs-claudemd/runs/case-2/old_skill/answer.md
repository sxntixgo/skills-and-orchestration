I'd rewrite the `description:` line in `skills/code-review/SKILL.md` so it names your two moments, "finished a change" and "before merging", as triggers.

**Assumption:** the current frontmatter is roughly `description: Reviews code for quality and security.` It says what the skill does but gives no "Use when…" trigger. I'd confirm this by reading the file before editing.

### Steps, in order

1. **Invoke `skill-authoring:skill-creator`**, as CLAUDE.md asks for any skill edit. It would load `references/writing-descriptions.md` for the "what it does. Use when <trigger>." house style.
2. **Read `skills/code-review/SKILL.md`** to check the current description and scope, and keep `name: code-review` matching the directory name.
3. **Edit the frontmatter. Only the description changes:**
   ```yaml
   ---
   name: code-review
   description: Reviews a code change for correctness, quality and security, and reports findings ranked by severity with file:line references. Use when a change, feature or bug fix is finished, before committing or opening a pull request, before merging a branch, or when the user asks to review a diff, PR or branch.
   ---
   ```
   - It's in the third person and keeps the "Use when" format.
   - It lists the actual words you'd say when you finish a change or are about to merge ("finished", "before merging", "PR", "diff", "branch").
   - "Security" is still in it because `security-review` was folded into this skill.
4. **Add trigger cases to `skills/code-review/evals/evals.json`** next to the existing cases:
   - Should fire: "I'm done with the auth refactor, anything wrong before I merge?", "ready to open a PR for this branch", "review my diff".
   - Should not fire: "write a function that parses ISO dates", "explain how this module works".
5. **Invoke `skill-authoring:skill-reviewer`.** It would do a static check of the frontmatter and conventions, then run a trigger eval comparing the old and new descriptions on the cases from step 4. That eval uses isolated runs, which is the one place CLAUDE.md allows them. I'd log the pass rates to `.claude-skills-work/evals/code-review/iteration-N/benchmark.json`.
6. **Tick any related task in `plan.md`.** No commit and no push.

### Final reply

> I rewrote the description in `skills/code-review/SKILL.md` so it fires when you finish a change, before you commit or open a PR, before you merge, and when you ask for a review of a diff, PR or branch. I added 3 should-fire and 2 should-not-fire trigger cases to `evals/evals.json`. In skill-reviewer's trigger eval, the new description fired on <x>/3 positive cases and stayed quiet on <y>/2 negative ones; the old one fired on <a>/3. Nothing is committed yet. Should I commit it?