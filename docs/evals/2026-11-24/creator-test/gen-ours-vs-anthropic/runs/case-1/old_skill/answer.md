I wrote the `incident-postmortem` skill and its evals to `skills/incident-postmortem/`. `evals.json` parses (3 cases), but I couldn't run the frontmatter validator (`quick_validate.py`) because PyYAML isn't installed. I haven't run the evals yet.

**Files:**
- `SKILL.md` (~120 lines): the trigger description, what it does and doesn't do, a 5-step checklist, the postmortem template, a self-check and a red-flags table. Each step saves its output to `./.claude-skills-work/incident-postmortem/<slug>/` (`notes.md`, `timeline.md`, `facts.md`, `postmortem.md`), so a stopped run can pick up where it left off.
- `evals/evals.json`: 3 test cases with 5–6 pass/fail checks each.
- `evals/files/`: 3 sample sets of incident notes, one per case:

| Case | What it tests |
|---|---|
| `checkout-5xx-slack.txt` | Pacific times in November converted at UTC-8, using the stated numbers (18,400 failed requests / ~3,100 customers / ~$41k), rewriting the engineer's "my bad", and an action item with no owner becoming `TBD` |
| `search-outage-teams.txt` | +02:00 times converted to UTC, a "this is on Tom" message, no impact numbers given (must be `Unknown`, not made up), and no owners or dates for any action item |
| `login-latency-notes.txt` | No date or timezone given (the assumption must be stated), a relative deadline ("end of next week"), and an action item with no owner |

What the skill adds beyond what the model would do anyway: it never makes up numbers, owners or dates. It also converts every time to UTC and writes down any timezone it had to assume. Anything missing goes into a required "Open gaps" section, and people's names never appear as a cause.

**Next step, the with/without comparison** (not run here, since this is a dry run):
1. In one turn, start 6 subagents on `claude-opus-5-5`: each test case run once with the skill and once without it. Prompt for each: "Execute this task: Skill path: skills/incident-postmortem (omit for baseline) · Task: <eval prompt> · Input files: <fixture> · Save outputs to: `skills/incident-postmortem-workspace/iteration-1/<eval-name>/{with_skill|without_skill}/outputs/`". Also write an `eval_metadata.json` for each case.
2. Save each run's tokens and duration to `timing.json` as it finishes.
3. Score each run against its checks and save to `grading.json` (using `agents/grader.md`). Then run `python -m scripts.aggregate_benchmark …/iteration-1 --skill-name incident-postmortem`.
4. Open the results viewer (`eval-viewer/generate_review.py … --benchmark …/benchmark.json`) for you to review, then revise the skill based on your feedback.

Repo checklist still open: run `skill-reviewer`, add `"incident-postmortem"` to the skill list in the README and `plan.md`, and add `pyyaml` to the dev requirements so the validator can run.