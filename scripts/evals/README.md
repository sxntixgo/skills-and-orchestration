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
- **Profiling:** `run --only new_skill` runs just the current version (no baseline) to find
  failing cases and turn/token hot spots before editing.
- **Grading:** one judge call per run, given only the prompt, the assertions and the answer (not
  which configuration wrote it). A PASS needs quoted evidence.
- **Cost:** each run and each grading is one `claude -p` call (about $0.10 and 20–40 s with Opus);
  `--jobs` sets parallelism.

Results are committed under `docs/evals/<date>/<skill>/` (`benchmark.json`, `report.md`, every
answer, timing and grading), with a summary in `docs/validation-<date>.md`. The scratch workspace
`.claude-skills-work/` stays uncommitted.

Script tests: `bash scripts/tests/test_review_check.sh`.
