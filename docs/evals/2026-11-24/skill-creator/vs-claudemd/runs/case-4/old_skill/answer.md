I haven't created anything yet. Two things need your answer first.

**1. Evals can't be skipped in this repo.** Rule 8 in CLAUDE.md says every skill must ship `evals/evals.json` and pass a with/without baseline comparison before it counts as done. A simple skill is the one most likely to fail that comparison. The repo's main finding is that skills that restate what the model already knows add nothing: `security-review` scored 0.00 lift twice and was folded into `code-review`. Formatting changelog entries is something I already do well without a skill. The eval is what shows whether this skill does anything beyond that.

The minimum I'd do is 3 short cases (about 15 lines of JSON) and one baseline run. If it shows no lift, we don't ship the skill, and that's still a useful result.

**2. What should the skill encode that I wouldn't do by default?** To be worth adding, it needs a process or house rules specific to you. For example:
- Which format: Keep a Changelog, conventional-commit grouping, or your own?
- Where entries come from: git log since the last tag, PR titles, or text you give it?
- Rules like version and date headers, whether to link PR or issue numbers, and how to wrap lines.
- Does it write to `CHANGELOG.md` directly, or show you the entry first?

Once you answer, I'll run `skill-authoring:skill-creator` to build `skills/changelog-format/` with `SKILL.md` and `evals/evals.json`. Then I'll run `skill-reviewer` for the baseline comparison and tick off the item in `plan.md`.

If you just want changelog entries formatted now, without a skill, paste the changes and I'll do it.