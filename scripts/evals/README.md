# Evals

Formal, reproducible skill evals: each case in a skill's `evals/evals.json` (with objective
`assertions`) is run twice, with the skill and with a baseline, then graded blind.

```bash
# A/B an edit against the committed version (baseline = skill at HEAD)
python3 scripts/evals/abeval.py run    --skill plugins/orchestration/skills/claude-review-merge --baseline HEAD --out .claude-skills-work/evals/claude-review-merge/iteration-1
# or measure a skill against no skill at all
python3 scripts/evals/abeval.py run    --skill skills/code-review --baseline none --out .claude-skills-work/evals/code-review/iteration-1
python3 scripts/evals/abeval.py grade  --out <same dir>
python3 scripts/evals/abeval.py report --out <same dir>     # benchmark.json + report.md
```

How it works (this is `skill-reviewer`'s Stage B, scripted):
- **Isolation:** every run is a fresh `claude -p --safe-mode` process (no CLAUDE.md, installed
  plugins, skills, hooks or memory), tools limited to `Read`, working directory = a snapshot of
  the skill's plugin root with all `evals/` folders removed, so a run can't see expected outputs.
- **Baseline:** `none` (no skill) or a git revision (the skill before an edit).
- **Dry runs:** the model writes exactly what it would do (commands, files, subagents, replies);
  nothing is executed. Good for process skills; skills whose value is in doing (debugging on real
  code) need fixture cases under `evals/files/`.
- **Real tools (opt-in):** `evals.json` may set `eval_tools` (e.g. `"Read,WebSearch,WebFetch"`)
  and `eval_allowed` (e.g. `["Bash(python3:*)","Edit"]`) at the top level or per case; those runs
  really use the tools inside the snapshot (online-research, debugging cases 5–6).
- **Resuming:** rerun the same `run` command; finished runs and the snapshots are kept. After editing the skill, delete the runs to redo and pass `--resnapshot`.
- **Profiling:** `run --only new_skill` runs just the current version (no baseline) to find
  failing cases and turn/token hot spots before editing.
- **Grading:** one judge call per run, given only the prompt, the assertions and the answer (not
  which configuration wrote it). A PASS needs quoted evidence.
- **Cost:** each run and each grading is one `claude -p` call (about $0.10 and 20–40 s with Opus);
  `--jobs` sets parallelism.

## opencode skills (`oceval.py`)

`opencode-develop` and `opencode-research` run for real, on the local model, inside the
devcontainer that has their tools; grading and the report reuse `abeval.py`:

```bash
python3 scripts/evals/oceval.py run --skill plugins/orchestration/opencode/skills/opencode-develop --out .claude-skills-work/oceval/develop
python3 scripts/evals/abeval.py grade  --out .claude-skills-work/oceval/develop
python3 scripts/evals/abeval.py report --out .claude-skills-work/oceval/develop
```

- `evals.json` names the runner: `"runner": {"kind": "develop"|"research", "container": "<docker
  name prefix>", "agent": "implementer"|"researcher"}`. Develop cases point at a fixture repo
  (`evals/files/<fixture>/`, committed fresh per run) and give `test_cmd`; research cases may copy
  `files` into the run's `files/` dir. Each case has the task file (`task`) and `assertions`.
- **Isolation:** every run gets its own opencode config dir (the container's `opencode.json`, the
  agent, and the skill only for `new_skill`) and its own data dir; Claude Code prompts and skills
  are off. The baseline is the agent prompt alone, so the delta is what the skill adds.
- **What the judge sees:** the final reply, every tool call in order (shell commands with exit
  code and output tail), and for develop the git status, the diff, `RESULT.md` and the harness's
  own rerun of the test command.
- **Cost = Claude tokens only.** opencode's tokens (local model) are free and reported separately
  as `local_tokens`. A run's Claude cost is what Claude reads downstream (findings; RESULT.md,
  status, diff, test output), ≈ chars/4; `oceval.py retime --out <dir>` recomputes it. The
  eval itself spends one Claude judge call per run; `--jobs 2` = the model server's slots. A develop run takes a few minutes, a research run up to 20.

Results are committed under `docs/evals/<date>/<skill>/` (`benchmark.json`, `report.md`, every
answer, timing and grading), with a summary in `docs/validation-<date>.md`. The scratch workspace
`.claude-skills-work/` stays uncommitted.

Script tests: `for t in scripts/tests/*.sh; do bash "$t"; done` (or `bash scripts/ci.sh`).
