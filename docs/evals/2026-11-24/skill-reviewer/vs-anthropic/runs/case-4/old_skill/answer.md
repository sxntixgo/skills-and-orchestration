I couldn't find an `evals/evals.json` in the case files, so `online-research` currently has no eval cases. I'd draft 3 cases and confirm them with you before spawning any runs. A review of `SKILL.md` and the full run plan follow.

## 1. Review of `skills/online-research/SKILL.md` (56 lines)

The skill is lean and has scope, steps, red flags and a "done when" section. Issues:

| # | Issue | Fix |
|---|---|---|
| 1 | **Risk that it adds little:** much of it is source-quality advice a frontier model already knows. That's how `security-review` scored 0.00. The parts likely to earn their tokens are the process rules: open the page rather than trusting the snippet, ≥2 *independent* sources, collapse wire-story reprints into one source, and the fixed output template. | Have the evals test those process rules, not general knowledge. |
| 2 | Step 1 is marked ⛔ (stop) but also says "Ask only if ambiguous." Those conflict. | Make it a conditional stop: "If scope is ambiguous, STOP and ask." |
| 3 | `notes.md` is written, but nothing says how to resume from it (house rule 6). | Add: "On resume, read `notes.md` and continue from the first unchecked step." |
| 4 | `<topic>` slug isn't defined. | Say "kebab-case slug of the question." |
| 5 | `evals/evals.json` is missing (house rule 8). | Add it (section 2 below). |

## 2. Draft eval cases (needs your OK)

I'd write this to `skills/online-research/evals/evals.json`:

```json
{
  "skill_name": "online-research",
  "evals": [
    {"id": 1, "prompt": "What's the current LTS version of Node.js and when does it reach end-of-life? I need it for a migration doc.",
     "expected_output": "Dated answer from primary sources (nodejs.org release schedule), cited, with confidence.",
     "files": [],
     "expectations": [
       "Cites the official Node.js release page or GitHub release schedule as a source",
       "Gives an as-of date for the time-sensitive fact",
       "Output has Answer, Evidence, Confidence, Gaps and Sources sections",
       "Every cited URL was actually fetched in the transcript (no snippet-only citations)"]},
    {"id": 2, "prompt": "Fact-check this: 'A study found 4-day work weeks increased productivity by 40%.' Is that true?",
     "expected_output": "Traces the claim to the primary source (Microsoft Japan 2019), flags that the original was a trial, and notes caveats and disagreement.",
     "files": [],
     "expectations": [
       "Identifies the primary source behind the 40% figure rather than citing only news coverage",
       "Treats news reprints of the same press release as one source",
       "States limitations or contested points explicitly",
       "Confidence level is justified with a reason"]},
    {"id": 3, "prompt": "Research which vector databases support hybrid (BM25 + vector) search natively as of this year, and give me a short comparison.",
     "expected_output": "Comparison built from vendor docs and an independent source, with vendor bias flagged and single-source claims marked.",
     "files": [],
     "expectations": [
       "Each product's hybrid-search claim cites the vendor docs page that was opened",
       "Flags vendor self-description as a potential bias or seeks an independent source",
       "Marks at least one claim as single-source or unverified where applicable",
       "Contains no fabricated URLs (every URL appears in a fetch in the transcript)"]}
  ]
}
```

**STOP:** "Here are 3 test cases: a time-sensitive fact, a fact-check with a wire-story trap, and a vendor-comparison bias trap. Do these look right, or should I add or change any?"

## 3. After your OK: the run

**Workspace:** `.claude-skills-work/evals/online-research/iteration-1/`, following this repo's CLAUDE.md (gitignored). I'm not using the skill-creator default of a sibling `-workspace/` dir. One directory per case:
- `node-lts-eol/`
- `four-day-week-factcheck/`
- `hybrid-search-vectordb/`

Each gets an `eval_metadata.json` with `eval_id`, `eval_name`, `prompt` and the assertions above.

**Spawn all 6 subagents in one turn** (model `claude-opus-5-5`, matching this session). Since we're benchmarking the skill itself, not an edit, the baseline is `without_skill`.

- **With skill:**
  ```
  Execute this task:
  - Skill path: skills/online-research
  - Task: <eval prompt>
  - Input files: none
  - Save outputs to: .claude-skills-work/evals/online-research/iteration-1/<eval-name>/with_skill/outputs/
  - Outputs to save: final answer as answer.md, transcript.md (incl. every WebSearch/WebFetch call + URL), metrics.json
  ```
- **Without skill:** the same prompt with no skill path, saved to `without_skill/outputs/`.

**As each run finishes:** write `timing.json` (`total_tokens`, `duration_ms`, `total_duration_seconds`) to that run's directory straight from the completion notification. That's the only chance to capture it.

**Grading:**
- One grader subagent per run, following `agents/grader.md`. It writes `grading.json` with `text`/`passed`/`evidence`.
- "Every cited URL was fetched" is checked by a script instead (`check_urls.py`, kept outside the outputs dirs, run with `python -I`). It diffs the URLs in `answer.md` against the WebFetch calls in `transcript.md`.

**Aggregate:**
```bash
python -m scripts.aggregate_benchmark .claude-skills-work/evals/online-research/iteration-1 --skill-name online-research
```
This produces `benchmark.json` and `benchmark.md`: pass rate, time and tokens per configuration, with with_skill listed before without_skill.

**Analyst pass** (`agents/analyzer.md`) looks for:
- Assertions that pass in both configurations and so measure nothing (the section-format one is most at risk).
- Cases with high variance between runs.
- The token cost against the pass-rate gain.

**Viewer:**
```bash
nohup python plugins/skill-authoring/skills/skill-reviewer/eval-viewer/generate_review.py \
  .claude-skills-work/evals/online-research/iteration-1 --skill-name online-research \
  --benchmark .claude-skills-work/evals/online-research/iteration-1/benchmark.json > /dev/null 2>&1 &
VIEWER_PID=$!
```
This assumes the skill-creator's `scripts/` and `eval-viewer/` folders exist under the skill-reviewer dir; I haven't verified that.

**Final message:**
> "Results are open in your browser. The **Outputs** tab lets you step through each case and leave feedback; the **Benchmark** tab shows with-skill vs. without-skill pass rate, tokens and time. Lift: `<Δ pass_rate>` for `<Δ tokens>`. Analyst notes: `<non-discriminating assertions / variance>`. If lift is about 0, like `security-review`, I'd recommend trimming the skill down to the process rules from issue 1 or folding it into another skill. Tell me when you've reviewed it."

**Then:** read `feedback.json`, run `kill $VIEWER_PID`, apply fixes 2–4 plus anything from the feedback, rerun as `iteration-2` with `--previous-workspace`, and tick the box in `plan.md`.