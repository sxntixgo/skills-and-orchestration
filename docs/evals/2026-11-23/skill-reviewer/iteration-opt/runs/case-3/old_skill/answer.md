Not confirmed yet. The new description passes the static rubric, but I need your approval before running the evals that would show whether it's actually better. Here is what I'd do, in order.

**1. Todos** (TodoWrite): Stage A rubric · Stage B A/B evals (gated) · Stage C verdict.

**2. Find the old version**
```bash
cd /workspaces/<repo>
git status --short skills/code-review/
git diff HEAD -- skills/code-review/SKILL.md
git log --oneline -3 -- skills/code-review/
```
Assumptions:
- The edit is uncommitted, so the old version is at `HEAD`.
- The old description was looser. I'm guessing something like "Helps review code for quality."
- `skills/code-review/evals/evals.json` exists with 3 cases. I couldn't see it.

If the diff touches more than the frontmatter (for example, `references/checklist.md` was deleted and its content moved into `SKILL.md`), the A/B test measures the whole change, not just the description. I'd tell you that up front.

**3. Stage A rubric on the new `SKILL.md`**, written to `./.claude-skills-work/code-review/review/rubric.md`:
```
🟡 Rule 1 — The trigger "reviewing code, a diff, or a PR, or before merging a change" (SKILL.md:3) may overlap with sibling skills: `security-review` (also "reviewing code") and any review/merge skill ("before merging"). The security exclusion is only in the body (SKILL.md:10). Add "not for security audits" to the description.
🟡 Rule 8 — This edit only changes the description, which decides WHEN the skill loads. evals.json only tests output quality once the skill is loaded. Add should-trigger and should-not-trigger prompts (e.g. "audit this for SQL injection" should not trigger it).
🟡 Rule 5 — The examples "> 1 for ratios" (SKILL.md:23) and "discount > 1 making totals negative" (SKILL.md:35) look fitted to one eval case. Make them general, or check that no eval depends on them.
🟢 Rule 7 — No stop-and-ask when the review target is missing or ambiguous (no diff or path given). Add a red flag for that.
🟢 Rule 6 — The findings path is in the Steps header (SKILL.md:18), but no step says when to write to it.
```
Rules 2, 3 (61 lines) and 4 pass. No 🔴 findings.

**4. Stage B gate.** I stop here and send you this:

> Rubric is above. For the evals I'd compare the new version against the old one from git, blind:
> - `git archive HEAD skills/code-review | tar -x -C .claude-skills-work/evals/code-review/iteration-N/skill-snapshot/`
> - 3 cases × 2 versions (`with_skill` = new, `old_skill` = HEAD) = **6 runs**. Each run is a fresh isolated subagent with its own token and time cost.
>
> One caveat: each run is given the skill path directly, so the description is barely read. Those 6 runs will likely show almost no difference and can't prove a description change is better. The meaningful test is triggering. I'd add about 6 should/shouldn't-trigger prompts and check which version gets picked, for about 12 more runs.
>
> Approve: (a) the 6 runs only, (b) 6 runs plus the trigger check, or (c) skip the evals?

Nothing gets spawned until you answer.

**5. After approval:** one subagent per run, using the clean-context instruction from `running-evals.md`, with outputs going to `iteration-N/<case-id>/{with_skill,old_skill}/`. For each run I save `timing.json` and grade against the case assertions with quoted evidence in `grading.json`. A blind judge compares each pair. Results are aggregated into `benchmark.json` with the `delta`.

**6. Verdict:**
- **PASS**: no 🔴 findings, and the new version wins on pass rate or triggering at similar cost.
- **ITERATE**: if there's no measurable gain, the edit isn't shown to be better. I'd list the 🟡 fixes above and any cases that got worse.