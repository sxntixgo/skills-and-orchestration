I can't confirm it's better yet. Only an A/B eval can show that, and the eval needs your approval first. The rubric check found no 🔴 issues. One caveat: the standard A/B harness won't fully test this change, because a description edit mostly changes **when the skill triggers**, not how it behaves once loaded.

**What I'd do, in order**

1. **TodoWrite:** Stage A rubric · Stage B evals (gated) · Stage C verdict.
2. **Batch-read** `skills/code-review/SKILL.md`, `references/*.md`, `evals/evals.json`, and list `scripts/`. I only had `SKILL.md` (from `case-files/3/`). I'm assuming `evals/evals.json` has **4 cases**, that there are no references or scripts, and that the edit is **not committed yet**, so the baseline is `HEAD`.
3. **Write** `./.claude-skills-work/code-review/review/rubric.md`:

```markdown
# code-review — rubric (new description, working tree vs HEAD)
No 🔴.
🟡 R1 SKILL.md:3 — description is ~60 words; "tightened" still lists 5 review dimensions
   + 7 triggers. Trigger part could be cut to: "Use when reviewing code, a diff or a PR,
   or before merging." The "touches auth, input handling, data access, file/network I/O
   or secrets" clause fires on *writing* such code too → possible clash with
   software-development.
🟡 R1 SKILL.md:3 — "before merging a change" may overlap a merge/PR skill; check siblings.
🟢 R5 SKILL.md:73 — "Done when" line wraps mid-sentence; reflow.
✅ R2/R3/R4 self-contained, 75 lines, single context. R6 findings path given (SKILL.md:18).
   R7 Scope + DOES NOT, TodoWrite steps, Red flags present.
R8: evals.json assumed 4 cases — unverified (not visible).
```

4. **Stop at the Stage B gate** and send the reply below. No runs start before you approve.

---

**Reply to you:**

Rubric: **no 🔴**. Two 🟡 on the new description (`skills/code-review/SKILL.md:3`):
- It's still about 60 words. The clause "touches auth, input handling, … secrets" will also fire when someone is *writing* code like that, which may pull it away from `software-development`.
- "before merging a change" may clash with a merge skill.

Full findings are in `.claude-skills-work/code-review/review/rubric.md`.

**Stage B:** I'd compare the new description against the old one (`HEAD`, extracted with `git archive HEAD skills/code-review`). If you committed the edit already, tell me and I'll use the parent commit instead. Two possible runs:

| Run | What it measures | Calls | Cost |
|---|---|---|---|
| **Trigger eval** (recommended) | About 8 should-trigger and 8 should-not-trigger prompts (e.g. "write a login handler"). Each is run with the skill installed but not named in the prompt, and I check whether it loads | 16 × 2 versions = 32 | ≈ $3.20, about 15 min |
| Behaviour A/B (`abeval.py`) | 4 cases → **8 runs + 8 blind judge calls** | 16 | ≈ $1.60, about 8 min |

The behaviour A/B runs `abeval.py run --skill skills/code-review --baseline HEAD --out .claude-skills-work/evals/code-review/iteration-N`, then `grade` and `report`. That harness gives the skill to the agent directly, so it mostly can't see a description change. Expect a delta near 0 from it. The trigger eval is the one that answers your question. Its prompts don't exist yet: I'd draft them into `evals/trigger-evals.json` for you to check first.

**Approve the eval run?** (trigger, A/B, both, or neither) If you skip it, the verdict rests on the rubric alone, and "better" stays unproven.