I can't confirm the new version is better yet. The rubric check comes first, and the old-vs-new comparison only runs once you approve it. The rubric finds nothing that must be fixed.

**What I'd do, in order**

1. **TodoWrite** with three items: Stage A rubric · Stage B A/B evals (needs your approval) · Stage C verdict.
2. **Find the baseline:** run `git status --short skills/code-review/` and `git diff HEAD -- skills/code-review/SKILL.md`. I'm assuming the edit isn't committed yet, so the old version is at `HEAD`. If it's already committed, the old version is `HEAD~1`.
3. **Read these in parallel:** `skills/code-review/SKILL.md` (from case-files/3), `skills/code-review/evals/evals.json` and `ls skills/code-review/scripts/`. I'm assuming `evals.json` has 3 realistic cases with assertions and that there's no `scripts/` folder. `references/checklist.md` was deleted and nothing points to it any more, which is fine.
4. **Write the rubric** to `./.claude-skills-work/code-review/review/rubric.md`:

```markdown
# Rubric: code-review (edited description)
No 🔴.
🟡 R7 SKILL.md:18 — no "ask instead of guessing": what to do when no diff/file/PR is identifiable ("review my code") → ask for the target.
🟡 R6 SKILL.md:37 — step 4 "Report" doesn't say to write findings.md; the path appears only in the Steps heading (l.18) → "write to findings.md, then show it".
🟡 R1 SKILL.md:3 — "or before merging a change" may overlap with a sibling merge/review skill's trigger → check sibling descriptions; drop or narrow.
🟢 R6 SKILL.md:18 — `<target>` undefined for a diff/PR (branch? PR#?) → define the slug.
🟢 R7 — no STOP gate for very large diffs (ask to narrow scope).
✅ R1 third-person + concrete "Use when"; R3 61 lines, no dangling refs; R4/R5 lean, imperative, tables; R7 Scope with Does NOT, Red flags, Done when.
```

5. **Reply to you** with the message below. I won't start anything after it until you say yes.

---

**Final message:**

**Rubric for code-review:** no 🔴 findings. The new description is third-person and has a concrete "Use when…" clause (`SKILL.md:3`). The skill is 61 lines, imperative and has a proper scope section.
- 🟡 `SKILL.md:18`: the skill never says to ask when the review target is unclear.
- 🟡 `SKILL.md:37`: the Report step doesn't say to write `findings.md`.
- 🟡 `SKILL.md:3`: "before merging a change" may overlap with the trigger of a sibling merge or review skill.
- 🟢 `<target>` is undefined for a diff or PR, and there's no gate for very large diffs.

Full findings are in `.claude-skills-work/code-review/review/rubric.md`.

**Whether the new version is better can only come from the A/B run.** Your change is to the description, and the description mostly controls *when* the skill gets picked. This A/B gives both versions the skill directly, so it mainly tests output quality, and the result may be close to zero. If you want to measure triggering itself, I'd add a few eval cases that should and shouldn't trigger the skill (for example, a security-audit prompt that must not trigger it).

**Proposed run:** 3 cases → 6 runs (new vs old version) plus 6 blind judge calls = **12 isolated `claude -p` calls, about $1.20 and 4–8 minutes**. The old version is extracted from `HEAD` with `git archive`, not copied from the working tree.
```
python3 scripts/evals/abeval.py run    --skill skills/code-review --baseline HEAD --out .claude-skills-work/evals/code-review/iteration-N
python3 scripts/evals/abeval.py grade  --out .claude-skills-work/evals/code-review/iteration-N
python3 scripts/evals/abeval.py report --out .claude-skills-work/evals/code-review/iteration-N
```
If the edit is already committed, the baseline becomes `HEAD~1`.

Approve the eval run?