**Not ready to ship: there's no `skills/debugging/evals/evals.json`, so the skill has no eval cases and no baseline comparison.** The `SKILL.md` itself is in good shape, with three structural fixes needed. Since this is a dry run, nothing below was actually executed.

## What I'd do, in order
1. Invoke `skill-authoring:skill-reviewer` on `skills/debugging/`, as the repo's CLAUDE.md asks.
2. Create TodoWrite items: conventions check, evals check, baseline run, write-up.
3. Read `skills/debugging/SKILL.md` and look for `evals/evals.json`. It's not there, and there's no `references/` or `scripts/`. The evals check fails, so the baseline step can't run.
4. Write the findings below to `./.claude-skills-work/skill-reviewer/debugging/review.md`.
5. Stop and ask before drafting eval cases or spawning baseline subagents.

## Findings

**Blocker**
- **Missing evals (rule 8).** There are no cases and no lift measurement. This matters more than usual here: like the old `security-review`, most of this skill is discipline a frontier model already claims to follow (reproduce, bisect, find the root cause). It needs to show lift on cases where a model without the skill skips steps, or it shouldn't ship. Cases that would test this:
  1. "Fix this crash" with an obvious null-guard bait. Pass = it reproduces the crash and finds the upstream cause instead of adding a guard.
  2. A flaky test. Pass = it makes the timing source deterministic and adds no sleeps or retries.
  3. A regression with git history available. Pass = it uses `git bisect` or a working-vs-failing diff.
  4. A bug it can't reproduce. Pass = it gathers logs and versions, or asks, without guessing a fix.
  5. A user who asks for "just a quick patch". Pass = it states the symptom-patch trade-off explicitly.

**Must fix (conventions)**
- **Rule 6, resumability:** `notes.md` is named, but the skill doesn't say what each step writes there or how to resume. `<bug>` also needs a defined slug. Add something like: "After each step, append `## Step N` with commands and outputs; on resume, read notes.md and continue from the last step written."
- **Rule 7, STOP gates:** the ⛔ on step 1 has no explanation. Make the gates explicit:
  - Still can't reproduce after gathering evidence: stop and ask.
  - The verified cause needs more than a minimal fix (design change, API change): stop and ask before step 5.
- **Rule 7, scope:** the Does NOT list should also say "fix other bugs found along the way". Log them in notes instead.

**Should consider**
- **The "usual suspects" list in step 3** is restated knowledge, about 5 lines. Cut it, or A/B it in the baseline run. The house rule is that process earns its tokens and knowledge usually doesn't.
- **Trigger overlap:** check the `software-development` description for bug-fix triggers so the two skills don't compete.

**Passes**
- Frontmatter: the name matches the directory, and the description is third person with a concrete trigger.
- It's 53 lines, uses no subagents, and is written as imperative checklists and tables.
- The red-flags table and "Done when" section are good.

## Housekeeping (assumed not done yet)
- Add the skill to the README skill list.
- Add a `plan.md` checkbox for it.
- Change "8 skills" in CLAUDE.md to 9.

Should I draft `evals/evals.json` with the five cases above and then run the with-skill vs without-skill baseline?