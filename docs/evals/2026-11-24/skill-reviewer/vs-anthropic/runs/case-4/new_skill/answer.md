I couldn't run the benchmark because `skills/online-research/` has no `evals/evals.json`. The review found 1 must-fix (that missing file) and 4 smaller issues; no eval has run yet. I'm assuming no eval file exists because I could only see `SKILL.md`. If you have one, point me to it.

## What I'd do, in order
1. Create TodoWrite items: Stage A rubric · Stage B evals (gated) · Stage C verdict.
2. Read the skill's files in one batch: `skills/online-research/SKILL.md` (55 lines), all of `references/` (none), `evals/evals.json` (not found) and `scripts/` (none).
3. Write `./.claude-skills-work/online-research/review/rubric.md` with the findings below.
4. Stop at the Stage B gate. Nothing has run.

## Stage A — rubric findings (most severe first)

🔴 **Rule 8, no eval cases.** There is no `skills/online-research/evals/evals.json`, so the with-skill vs. without-skill comparison has no cases to run.

🟡 **Rule 6, the work can't be resumed.** `SKILL.md:18` names one notes file, `notes.md`. No step says what it writes there, and nothing says how to pick up again after a pause (for example: "re-read notes.md and continue at the first step not yet done"). Steps 3–4 (gathering and checking sources) are where long research runs usually get cut off.

🟡 **Rules 7 and 4, no limit on searching.** Steps 3–4 (`SKILL.md:23-30`) never say when to stop gathering, such as a maximum number of searches or pages, or "stop once every key claim has 2 independent sources." Without a stop gate, a run can keep growing and use too many tokens.

🟡 **Rule 1, the trigger may overlap with a sibling skill.** The description triggers on "research, investigate". Recent commits mention a sibling `opencode-research` skill, so check that the two descriptions don't fire on the same requests (for example, add "on the public web, with citations").

🟢 **Rule 5, formatting.** The answer template (`SKILL.md:32-39`) is a code block that isn't indented under step 5, so it breaks the numbered list.

🟢 **Value risk.** The skill is mostly process (checking each claim against independent sources, never citing a page it didn't open), which is the kind of skill that tends to measure a gain. A strong model already cites sources by default, though, so the benchmark is what will show whether the skill helps. A `security-review`-style 0.00 gain is possible.

Rules 2 (falls back to labelling claims unverified when there's no web tool), 3 (lean) and 5 (otherwise imperative) pass. Rule 7 is otherwise fine: it has Scope / does NOT, ⛔ Clarify, and Red flags.

## Stage B — ⛔ stop gate
I can't give a run count until cases exist. For scale: 4 cases means 4 × 2 = 8 runs plus 8 grading calls, so 16 isolated `claude -p` calls. Each costs about $0.10 and takes 20–40 s, so roughly **$1.60** in total, and more if pages are slow to fetch. This is a new skill, so the comparison is against no skill at all (`--baseline none`).

To unblock it, add 3–4 cases with `skill-authoring:skill-creator`. Write assertions the grader can check objectively, without depending on what the live web returns. For example:
- Every key claim cites ≥ 2 sources from different publishers.
- There is a Confidence line and a Gaps line.
- Only opened pages are listed in Sources.
- One-off or disputed claims are flagged.
- `notes.md` was written.

Suggested prompts:
- One time-sensitive question, e.g. the current LTS version of some tool.
- One fact-check where the only source is a single press release reprinted by many sites.
- One contested claim.
- One case with no web tool available, which should label every claim unverified.

Once `evals.json` exists I'll run `abeval.py run --skill skills/online-research --baseline none --out .claude-skills-work/evals/online-research/iteration-1`, then `grade` and `report`.

**Approve the eval run once the cases are added?**

## Stage C — verdict (rubric only for now)
**ITERATE.** It can't PASS until the 🔴 is fixed and the benchmark shows a positive gain in pass rate. Top fixes: (1) add `evals/evals.json`, (2) say what each step writes and how to resume, (3) add a stopping rule for searching.