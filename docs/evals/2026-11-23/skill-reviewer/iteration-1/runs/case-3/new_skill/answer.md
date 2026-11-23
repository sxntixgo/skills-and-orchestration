I can't confirm it's better yet. I've run the static rubric, and the comparison runs against the old version need your approval first.

**Assumptions** (I can only see `SKILL.md`):
- `skills/code-review/evals/evals.json` exists and has 3 cases.
- `references/checklist.md` exists.
- Only the `description:` line (SKILL.md:3) changed.

## What I'd do

1. **TodoWrite:** Stage A rubric · Stage B A/B evals (gated) · Stage C verdict.
2. **Find the old version:**
   - `git status --short skills/code-review/` and `git log -3 --oneline -- skills/code-review/`
   - `git diff HEAD -- skills/code-review/SKILL.md` (or `HEAD~1` if the edit is already committed), to confirm only the description changed.
   - The old version is `HEAD` if the edit is uncommitted, or `HEAD~1` if it's committed. I won't copy the working directory as the baseline, because it already contains the edit.
3. **Stage A:** read `SKILL.md`, `references/checklist.md` and `evals/evals.json`, then write the findings below to `./.claude-skills-work/code-review/review/rubric.md`.
4. **Stage B:** stop and ask (below).

## Stage A — rubric findings (new version)

```
🟡 Rule 8 — For a description-only edit, the current evals don't test what changed. Every run is handed the skill path, so the description never decides whether the skill loads. Add trigger cases: prompts that should trigger it ("review this PR before I merge") and prompts that shouldn't ("audit this for SQL injection", "write tests for X").
🟢 Rule 1 — "Use when reviewing code" is broad. It may overlap with a security-review skill if you have one. Consider adding "not for security audits" to the description (SKILL.md:3); the body already says this (SKILL.md:10, 30).
🟢 Rule 5/4 — "Where this skill adds value" (SKILL.md:12-20) is prose about the skill rather than instructions to Claude. Its one useful instruction is "deliver a complete, uniformly rated review"; cut the section down to that.
🟢 Rule 4 — "Review dimensions" (SKILL.md:46-59) probably repeats references/checklist.md. Keep only one copy.
🟢 Rule 7 — There's no stop-and-ask for a missing or huge target (no diff given, or a 5k-line PR). Add a red flag for this.
```

Passing:
- Rule 1: name matches the directory, third person, concrete "Use when".
- Rule 3: 95 lines.
- Rule 6: checkpoint path is given.
- Rule 7: Scope with a "does NOT" list, TodoWrite, and a red-flags table are all present.

No 🔴 findings.

## Stage B — ⛔ approval needed

Assuming 3 cases, I'd run **3 cases × 2 = 6 runs**: each case once with the new version and once with the old one. Each run is a fresh isolated subagent with its own token and time cost. Outputs go to `./.claude-skills-work/evals/code-review/iteration-N/<case-id>/{new_skill,old_skill}/`. The old version gets extracted with:

```
git archive <pre-edit-rev> skills/code-review | tar -x -C .claude-skills-work/evals/code-review/iteration-N/skill-snapshot/
```

I'd grade each run against the case's assertions, quoting the output as evidence, then do a blind A/B comparison and write the results to `benchmark.json`.

**This alone won't show whether the description got better.** Both versions get the skill path directly, so their outputs will probably be about the same. To test the description, I'd also add about 6 trigger cases (3 should-trigger, 3 should-not). Those runs list both descriptions as available skills without forcing either one. I'd score whether each version loads at the right times and stays out of the way otherwise. That adds roughly 12 runs, so about **18 in total**.

**Shall I run the 6 A/B runs, the 18 runs including the trigger cases, or skip evals?** If you skip them, the verdict will say the change wasn't measured and can't be confirmed as better.