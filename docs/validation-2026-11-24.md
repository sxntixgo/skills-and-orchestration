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

## skill-creator rewrite (skill-authoring 0.2.0)

Rewritten as a lean, draft-first creator: one page (3.7k chars, was 5.2k + 4 references), no
scaffold script, a validator `scripts/check_skill.py` (frontmatter, trigger, size, sections,
references, eval format; tests in `scripts/tests/test_check_skill.sh`) that `skill-reviewer`
now runs first too. New cases: two-turn-free (clear briefs draft at once), a vague brief, an
edit, a "skip evals" request, and slimming a bloated skill (fixtures in `evals/files/`).

**The creator itself** (both sides with CLAUDE.md):

| Version | vs | ours | baseline | tokens ours / baseline |
|---|---|:---:|:---:|:---:|
| rewrite (5.2k page) | CLAUDE.md only | 17/17 | 12/17 | 34.2k / 18.5k |
| rewrite (5.2k page) | Anthropic skill-creator | 16/17 | 13/17 | 33.7k / 53.5k |
| trimmed (3.7k page, no CLAUDE.md/sibling reads) | CLAUDE.md only | **17/17** | 13/17 | **28.6k** / 18.9k |

The remaining gap (~+10k) is one turn to load the page plus writing and validating the files,
which the CLAUDE.md-only side often skipped.

**What it produces** (`scripts/evals/creator-test/`): each creator wrote the same two skills
from the same brief; each skill was scored on held-out cases the creators never saw (fixtures:
incident notes, git logs), against no skill.

| Skill | Creator | Pass | Tokens per use | SKILL.md chars | House check |
|---|---|:---:|---:|---:|---|
| incident-postmortem | no skill | 8/10 | 12.1k | – | – |
| | **ours** | **10/10** | **15.2k** | **3317** | pass |
| | Anthropic | 10/10 | 16.6k | 5192 | 4 FAIL |
| | CLAUDE.md only | 9/10 | 15.5k | 4686 | 2 FAIL |
| release-notes | no skill | 7/9 | 10.9k | – | – |
| | **ours** | **9/9** | **13.2k** | **3444** | pass |
| | Anthropic | 9/9 | 18.8k | 3928 | 4 FAIL |
| | CLAUDE.md only | 9/9 | 13.5k | 4052 | 2 FAIL |

Reading: all three creators write skills that help (15/19 → 18–19/19). Ours writes the
smallest pages and the cheapest skills to use (−0.3k per use vs CLAUDE.md only, −1.4k to −5.6k vs
Anthropic's), with every case passing, and only its skills pass the house validator. Against
CLAUDE.md only, the quality and token edge per use is small; the creation cost (+10k) pays back
after ~30 uses on tokens alone. Against Anthropic's it is cheaper both to run and to use.
Caveat: 2 skills, 1 run per case.

**Decision (2026-11-24, user):** keep the rewritten skill-creator and skill-reviewer in the `skill-authoring` plugin.

## opencode skills: first real measurement (opencode 2.4.1)

Until now `opencode-develop` and `opencode-research` had only dry-run cases and no numbers. New
runner `scripts/evals/oceval.py`: each case runs **for real** with opencode 2.4.1 on the local
model (qwen3.8-flash-next) inside the devcontainer that has the tools (homestack for develop,
research for research), once with the skill and once with the agent prompt alone; same blind
Claude judge as the other skills. The judge sees the final reply, every tool call, and for
develop the diff, `RESULT.md` and the harness's own rerun of the test command. Develop cases are
7 small fixture repos (`evals/files/<fixture>/`); research cases are 10 live sub-questions,
3 with local files (one with a planted prompt injection). Records:
[`docs/evals/2026-11-24/opencode-develop`](./evals/2026-11-24/opencode-develop/report.md),
[`opencode-research`](./evals/2026-11-24/opencode-research/report.md) (raw opencode logs not committed).

| Skill | with skill | agent only | delta | tokens/run | time/run |
|---|:---:|:---:|:---:|---:|---:|
| opencode-develop | **33/34** | 28/34 | **+0.14** | 67k vs 73k (−8 %) | 79 s vs 114 s |
| opencode-research | **44/47** | 16/47 | **+0.59** | 434k vs 75k (5.8×) | 374 s vs 120 s |

Reading:
- **develop** helps and costs nothing: the agent alone mostly does the work but skips the
  RESULT.md contract (no frontmatter, no Tests section) that `claude-review-merge` reads, and
  when the task's test command can't run (case 5: pytest only in another venv) it declares
  success with a different command; with the skill it reports `blocked`. Neither noticed the
  out-of-scope bug in case 3 (the only miss with the skill).
- **research** is the skill that matters most: without it the researcher often doesn't find or
  use `search`/`fetch-text` (case 1: no search at all, "tooling was unavailable"), answers from
  memory, and never uses the findings format the orchestrator parses. The extra tokens are the
  research itself (pages read); they cost local-model time, not API money. Worth trimming later
  (fetch fewer pages, smaller slices); case 5 with the skill still derived a number no source
  quoted.
- Harness fix during the round: Python bytecode showed up as changed files; the runner now
  excludes `__pycache__`/`*.pyc` and the develop round was rerun clean.
- Caveat: 1 run per case, one model.

### opencode 2 upgrade (same day)
opencode 2 changed what the plugin relies on: `opencode run` has no `--dir` (the dispatchers now
run it inside the worktree / run dir), the shell tool is `shell`, some text events have
`text: null`, and agents start from allow-all with new tools (Code Mode `execute`, worktree,
automations, image/video generation). The two agents now use v2's native `permissions` list,
deny by default, then allow only what each role needs; `"automations": false` in the
containers' `opencode.json`. Both dispatchers were tested end to end on 2.4.1 (dispatch, research
with `--continue` on the same session). npm's `opencode-ai` package stays on 1.x: v2 is
`@opencode/cli` or the GitHub release tarballs.
