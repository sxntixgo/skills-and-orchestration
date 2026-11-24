Static review is done and I've drafted 3 test prompts. I need your OK on them before I run the comparison with and without the skill.

**Assumptions:** `skills/debugging/` contains only `SKILL.md` (53 lines, matching `case-files/1/SKILL.md`). It has **no `evals/evals.json`**. This dry run treats it as a new skill, so the baseline is no skill at all.

## What I'd do, in order

1. **Read the skill.** Read `skills/debugging/SKILL.md` and look for `evals/`, `references/` and `scripts/`. Only `SKILL.md` exists.

2. **Static review** against the `CLAUDE.md` rules:

| Rule | Verdict |
|---|---|
| Frontmatter: `name` matches the dir, third-person "Use when…" | ✅ |
| Self-contained, no external skills | ✅ |
| Lean (53 lines) | ✅ |
| Checkpointed (`./.claude-skills-work/debugging/<bug>/notes.md`) | ⚠️ There's one notes file but no per-step output or "resume from" instruction. Add something like "append each step's result under `## <step>`; on resume, read notes.md and continue from the last completed step." |
| Guardrails: scope, TodoWrite steps, red flags | ✅ |
| STOP gates | ⚠️ The ⛔ on Reproduce is never explained. Say what it means, e.g. "STOP and ask the user if you can't reproduce after gathering logs/inputs; don't fix blind." Step 4's "Wrong → back to 3" has no cap; add one, e.g. "after 3 disproven hypotheses, report findings and ask." |
| Eval-backed | ❌ **No `evals/evals.json`.** The skill isn't done under rule 8. |
| Process vs. known knowledge | ⚠️ The process parts (reproduce first, verify before fixing, regression test) are what should give lift. The "usual suspects" list in step 3 is knowledge the model already has, which is the same pattern that gave `security-review` 0.00 lift. If the baseline shows no gain on those cases, cut it. |
| Wording | Minor: "(unless that's a stated, deliberate choice)" has no owner; make it "the user's stated choice." |

3. **Write `skills/debugging/evals/evals.json`** with prompts only. Assertions come in step 6.
```json
{
  "skill_name": "debugging",
  "evals": [
    {"id": 1,
     "prompt": "test_invoice_total in tests/test_billing.py started failing after yesterday's merge. Fix it.",
     "expected_output": "Runs the failing test first, isolates (bisect or diff), verifies a specific cause, makes a minimal fix, reruns the test and the surrounding suite.",
     "files": ["evals/files/billing/"]},
    {"id": 2,
     "prompt": "Our CI flakes on test_session_expiry maybe 1 in 10 runs. Can you just add a retry so it stops blocking merges?",
     "expected_output": "Pushes back on the retry; reproduces with repeated runs and varied seed/clock; finds the timing dependency; injects the clock rather than adding sleeps/retries.",
     "files": ["evals/files/session/"]},
    {"id": 3,
     "prompt": "Users say the dashboard sometimes shows 'undefined' for their name right after login. Here's the component.",
     "expected_output": "Forms a testable hypothesis (unawaited fetch / render before data), verifies it, and fixes the cause rather than null-guarding the display.",
     "files": ["evals/files/dashboard/Profile.tsx"]}
  ]
}
```
   Fixtures under `evals/files/` would each hold a small repo with a real, seeded bug.

4. **Checkpoint: ask you to confirm the 3 cases**, then continue.

5. **Run everything in one turn: 6 subagents**, one with-skill and one baseline per case. All use `claude-opus-5-5`, the model this session runs on, so the results match what you'd actually get. Outputs go to `.claude-skills-work/evals/debugging/iteration-1/<eval-name>/{with_skill,without_skill}/outputs/`. Eval names: `regression-after-merge`, `flaky-ci-retry-request`, `undefined-after-login`.
   - With-skill prompt: `Execute this task: Skill path: skills/debugging/ · Task: <prompt> · Input files: <files> · Save outputs to: <dir> · Outputs to save: the final diff, the commands you ran with their output, and your final report.`
   - Baseline prompt: the same, without the skill path.
   - Write `eval_metadata.json` in each eval dir with `eval_id`, `eval_name`, `prompt` and `"assertions": []`.

6. **Draft assertions while the runs are going**, add them to `evals.json` and the metadata files, and explain each to you. Examples:
   - "Ran the failing test before editing code."
   - "Stated a specific root cause and verified it before the fix."
   - "Did not add a retry/sleep" (case 2).
   - "Did not add only a null-guard" (case 3).
   - "Reran the repro after the fix and it passed."
   - "Left a regression test in place."

7. **As each run finishes,** save `total_tokens` and `duration_ms` to that run's `timing.json`.

8. **Grade, aggregate and open the viewer:**
   - Grade each run per `agents/grader.md` into `grading.json` (`text`/`passed`/`evidence`). Check "ran tests before editing" with a script over the transcripts.
   - Build the benchmark: `python -m scripts.aggregate_benchmark <ws>/iteration-1 --skill-name debugging`
   - Analyst pass: flag assertions both configs pass (no signal), and check whether the "usual suspects" list drives any of the difference.
   - Open the viewer: `nohup python <skill-creator>/eval-viewer/generate_review.py <ws>/iteration-1 --skill-name debugging --benchmark <ws>/iteration-1/benchmark.json >/dev/null 2>&1 &`

9. **Hand off to you:** point you at the viewer, wait for `feedback.json`, then revise and run iteration 2.

## Reply to you

The skill is well structured: clear scope, ordered steps, red flags and a definition of done. Three things to fix:

1. **It has no `evals/evals.json`,** so it can't count as done until a with/without comparison shows it helps. I've drafted 3 cases above: a regression after a merge, a flaky-CI "just add a retry" request, and a UI showing "undefined". **Do these look right, or do you want to add or change any?**
2. **The ⛔ on Reproduce is never defined,** and the hypothesis loop in step 4 has no cap. Add explicit STOP-and-ask points.
3. **Resuming is underspecified.** Have each step append to `notes.md` and say how to pick up from the last completed step.

The **"usual suspects" list may be dead weight:** the model already knows those bug patterns, and the same kind of content gave `security-review` zero lift. The baseline run will show whether it earns its tokens.

Once you confirm the cases, I'll run all 6 and open the results viewer.