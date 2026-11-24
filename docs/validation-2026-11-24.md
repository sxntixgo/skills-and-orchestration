# Validation 2026-11-24 — skill-authoring vs CLAUDE.md and vs Anthropic's skill-creator

`skill-creator` and `skill-reviewer` moved to their own plugin, `skill-authoring` (0.1.0);
`frugal-skills` is 3.0.0 (6 skills). Question: do they earn their place?

Method: `abeval.py run --claudemd` (both sides get the repo's CLAUDE.md, as in a real session
here), Opus, dry runs, blind judge, 1 run per case. Baselines: `none` (CLAUDE.md only) and
`--baseline-skill` = Anthropic's official `skill-creator` (claude-plugins-official, 33k-char
SKILL.md, placed at the same path). Records: `docs/evals/2026-11-24/`.

| Skill | vs | ours | baseline | Δ pass | tokens ours / baseline |
|---|---|:---:|:---:|:---:|:---:|
| skill-reviewer | CLAUDE.md only | 13/13 | 8/13 | **+0.40** | 50.7k / 37.7k |
| skill-reviewer | Anthropic skill-creator | 12/13 | 7/13 | **+0.38** | 55.0k / 101.6k |
| skill-creator | CLAUDE.md only | 8/13 | 9/13 | −0.06 | 19.2k / 9.8k |
| skill-creator | Anthropic skill-creator | 8/13 | 11/13 | **−0.23** | 19.1k / 36.6k |

- **skill-reviewer** wins against both: it always stops for approval with a run count and cost,
  gives file:line findings and a PASS/ITERATE verdict, and never edits the target (Anthropic's
  skill wrote `evals.json` into the skill under review). Caveat: the assertions use this skill's
  own vocabulary (ITERATE, Stage B), which favours it on 1–2 assertions.
- **skill-creator** loses to both. Its Stage 1 gate stops before drafting anything, so it never
  shows a description, SKILL.md or eval cases in the first reply; the other two draft first and
  then ask (Anthropic's also stopped before running evals). Cases 1, 2, 4 expect a finished
  skill in one turn, which penalizes any gate, but the competitors still produced more.
