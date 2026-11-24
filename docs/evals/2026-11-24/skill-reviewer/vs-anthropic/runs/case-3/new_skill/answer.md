I can't confirm it's better yet. Below is the review up to the approval gate. One problem shapes the plan: you only changed the description, and the description controls *when the skill loads*, not what it does once loaded. The usual old-vs-new eval gives the agent the skill directly, so both versions would produce the same output and the comparison would show no difference whether or not your edit helped. Answering your question takes a trigger test instead.

## What I'd do, in order

**1. TodoWrite:** Stage A rubric · Stage B eval gate · Stage C verdict.

**2. Read the target in one parallel batch:**
- `skills/code-review/SKILL.md` (the new version I was given)
- `skills/code-review/references/*.md`
- `skills/code-review/evals/evals.json`
- list `skills/code-review/scripts/`

I'd also run `git diff HEAD -- skills/code-review/` to see the old description and confirm only the frontmatter changed.

**Assumptions** (I can't see these files):
- The edit isn't committed yet, so the old version is `HEAD`. If it is committed, the old version is `HEAD~1`.
- The diff shows only line 3 (the description) changed.
- `evals.json` has 4 cases that test review output, not when the skill triggers.

**3. Write `./.claude-skills-work/code-review/review/rubric.md`:**
```markdown
# code-review — rubric (new description)
## 🟡 Should fix
1. SKILL.md:3 — Rule 1 trigger clash: "before merging a change" overlaps the sibling
   review-merge skill. Drop it or narrow it to "reviewing the diff itself".
2. SKILL.md:3 — Rule 1 over-trigger risk: "when a change touches auth, input handling, data
   access, file/network I/O or secrets" also matches *writing* such code, which belongs to
   software-development. Scope it: "when reviewing a change that touches …".
3. Rule 8 — evals.json has no trigger cases (should / should-not load), so a description
   edit can't be measured by the existing cases.
## 🟢 Consider
4. SKILL.md:3 — "(and an exploit scenario for each vulnerability)" describes the body's
   output. It spends description tokens without helping Claude decide whether to load the skill.
5. SKILL.md:18–47 — no STOP gate to ask when the review target is unclear
   (e.g. "review my code" with no diff or path).
## No issues
Rules 2–6: self-contained, 75 lines, imperative steps, writes findings to disk, Scope with a
"Does NOT" line, Red flags table.
```

**4. Stop. Nothing runs until you approve.** (Final reply below.)

---

## Reply to user

**Rubric:** no 🔴. Three 🟡:
- **Overlaps `review-merge`** (`SKILL.md:3`): "before merging a change" also describes that skill.
- **May trigger while writing code** (`SKILL.md:3`): "when a change touches auth, input handling…" also fits writing such code, which belongs to `software-development`.
- **Your evals can't measure this edit:** `evals.json` only has cases that check review output, none that check whether the skill loads.

Two 🟢: the exploit-scenario wording belongs in the body, not the description, and there's no question to ask when the review target is unclear. Full list: `.claude-skills-work/code-review/review/rubric.md`.

**Why the normal eval won't answer your question:** the old-vs-new run gives the agent the skill directly, so the description never decides anything. Expected difference: about 0, even if your edit is a real improvement.

**Proposed eval: does the right version load at the right time?**
- **Old version:** the description at `HEAD`, recovered with `git archive HEAD skills/code-review` into a separate snapshot folder (not a copy of the edited files).
- **Prompts:** 12 short prompts.
  - 6 should load the skill: "review this PR", "anything wrong with this diff?", "check this login handler for vulns", and similar.
  - 6 should not: "write an auth middleware", "merge this branch once CI passes" (`review-merge`'s job), "explain this function", and similar.
- **Runs:** each prompt runs in a fresh, separate `claude -p` session with only the description installed, once with the old description and once with the new one. That's 12 × 2 = **24 calls**. Each is graded pass/fail on whether the skill loaded, so no judge calls are needed.
- **Cost:** about **$2.40**, 20–40 s per call.
- **Result:** the share of correct load/no-load decisions for each version, and the difference between them.

**Optional:** the standard old-vs-new run on your existing cases. With 4 cases that's 4 × 2 runs + 8 judge calls = 16 calls, about $1.60. It only confirms the review output didn't change. I'd skip it if the diff shows only line 3 changed.

I'd save the 12 trigger prompts to `skills/code-review/evals/` so future description edits can be measured.

**Approve the eval run?** (trigger eval only / trigger eval + standard run / neither)

Until it runs, I can't call the new description better. Without the run, the verdict rests on the rubric only, and the 🟡 overlaps suggest the new description may load in cases where it shouldn't.