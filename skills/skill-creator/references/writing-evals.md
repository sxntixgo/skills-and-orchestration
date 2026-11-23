# Writing evals (Stage 4)

Evals prove the skill actually helps versus no skill at all. You author
`evals/evals.json`; `skill-reviewer` runs the baseline comparison later.

Reference: https://agentskills.io/skill-creation/evaluating-skills

## evals.json format

Top level: `skill_name` (string) and `evals` (array). Each case:

| Field | Required | Meaning |
|-------|----------|---------|
| `id` | yes | Number, unique within the file. |
| `prompt` | yes | A realistic user message — what someone would actually type. |
| `expected_output` | yes | Human-readable description of what success looks like. |
| `files` | yes (may be `[]`) | Input fixtures the case needs, as paths like `evals/files/foo.csv`. |
| `assertions` | yes | Array of objective PASS/FAIL statements, written with the case (`scripts/evals/abeval.py` refuses cases without them). Refine them after the first run, once you've seen real output. |

```json
{
  "skill_name": "csv-analyzer",
  "evals": [
    {
      "id": 1,
      "prompt": "I have monthly sales in data/sales_2025.csv — find the top 3 months by revenue and make a bar chart.",
      "expected_output": "A bar chart image of the top 3 months by revenue, axes labeled.",
      "files": ["evals/files/sales_2025.csv"]
    }
  ]
}
```

## Picking good cases
- **Start with 3–5.** Don't over-invest before the first results.
- **Vary phrasing** — some casual ("hey can you…"), some precise.
- **Cover an edge case** — a malformed input, an ambiguous request, a boundary.
- **Be realistic** — mention real file paths, names, context. "Process this
  data" tests nothing.
- Each prompt should plausibly trigger THIS skill's description, not a sibling's.

## Assertions (added after the first run)
Objective, checkable statements — not vibes.

| Good | Weak |
|------|------|
| "The output file is valid JSON" | "The output is good" |
| "The chart has labeled axes" | "The chart looks nice" |
| "The report lists at least 3 recommendations" | "Uses the exact phrase '…'" (too brittle) |

Reserve assertions for what can be checked objectively; leave style/feel for
human review during `skill-reviewer`.

## How the baseline run works (context — skill-reviewer drives it)
Each case runs twice from a clean context: once WITH the skill, once WITHOUT
(the baseline). Results aggregate into a workspace `benchmark.json` with
`with_skill`, `without_skill`, and a `delta` (pass-rate gain vs. token/time
cost). A skill that adds a little latency but lifts pass rate a lot is worth it;
one that doubles tokens for a marginal gain is not.
