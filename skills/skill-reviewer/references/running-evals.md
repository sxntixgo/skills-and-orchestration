# Running the baseline evals (Stage B)

Only after the user approved at the STOP gate. Reference:
https://agentskills.io/skill-creation/evaluating-skills

## Workspace layout
Put everything under the gitignored working dir (not committed):

```
.claude-skills-work/evals/<skill>/iteration-N/
  <case-id>/
    with_skill/     outputs/  timing.json  grading.json
    without_skill/  outputs/  timing.json  grading.json   # or old_skill/ for an edit A/B
  benchmark.json
```

Use the next free `iteration-N`. Re-reviews increment N so history is kept.

## Spawning runs
Each run starts from a CLEAN context so the agent follows only what `SKILL.md`
says — no leftover state from this review. Spawn one subagent per run.

For each eval case, do two runs:
- **with_skill**: give the agent the skill path, the case `prompt`, its `files`,
  and an output dir under `with_skill/outputs/`.
- **without_skill** (baseline): same prompt and files, NO skill path, output to
  `without_skill/outputs/`. For an EDIT, snapshot the previous version
  (`cp -r <skill> <workspace>/skill-snapshot/`), point this run at the snapshot,
  and save to `old_skill/` instead.

Example run instruction:
```
Execute this task from a clean context.
- Skill path: skills/<skill>        (omit this line for the baseline)
- Task: <case prompt>
- Input files: <case files>
- Save all outputs to: <.../with_skill/outputs/>
Report what you produced.
```

## Capturing timing
When each subagent finishes, its completion notification includes `total_tokens`
and `duration_ms`. Save them immediately — they aren't persisted elsewhere:
```json
{ "total_tokens": 84852, "duration_ms": 23332 }
```

## Grading
Grade each run's outputs against the case's `assertions` (objective PASS/FAIL).
If the case has no assertions yet, grade against `expected_output` and propose
assertions to add. Require concrete evidence for a PASS — quote the output; a
label without substance is a FAIL. Write per-run `grading.json`:
```json
{
  "assertion_results": [
    { "text": "Output is valid JSON", "passed": true, "evidence": "parsed 12 keys" }
  ],
  "summary": { "passed": 3, "failed": 1, "total": 4, "pass_rate": 0.75 }
}
```

## Aggregating
Compute per-configuration means and the delta into `benchmark.json`:
```json
{
  "run_summary": {
    "with_skill":    { "pass_rate": { "mean": 0.83 }, "tokens": { "mean": 3800 }, "time_seconds": { "mean": 45 } },
    "without_skill": { "pass_rate": { "mean": 0.33 }, "tokens": { "mean": 2100 }, "time_seconds": { "mean": 32 } },
    "delta": { "pass_rate": 0.50, "tokens": 1700, "time_seconds": 13 }
  }
}
```
The `delta` is the verdict input: what the skill BUYS (pass-rate gain) vs. what
it COSTS (extra tokens/time). Big pass-rate gain at modest cost → worth it.

## Blind A/B (edits)
When comparing two versions, present both outputs to the judge WITHOUT saying
which is which, and score holistic quality (organization, usability, polish).
This complements assertion grading — two outputs can both pass assertions yet
differ in quality.
