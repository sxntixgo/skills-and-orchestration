## Verdict: ITERATE. The skill has 3 must-fix (🔴) problems, and the baseline eval can't run until it has eval cases.

**What I'd do, in order:**

1. **TodoWrite:** add "Stage A rubric", "Stage B baseline evals (gated)" and "Stage C verdict".
2. **Read the skill's files in one parallel batch:** `SKILL.md`, `references/*.md`, `evals/evals.json` (the read fails because the file doesn't exist), and the `scripts/` listing. You didn't give a path, so I'm assuming the skill is at `skills/<skill>/`. I'm also assuming the frontmatter `name` matches the directory, and that there are no references, scripts or dependencies outside the plugin. I can only score what you described, so rules 2–6 are marked as not checked.
3. **Write** `./.claude-skills-work/<skill>/review/rubric.md`:

```markdown
# Rubric review: <skill>  (2026-11-24)

## 🔴 Must fix
1. Rule 1 Frontmatter (SKILL.md:3): the description "Helps with stuff" doesn't say what the skill does and has no "Use when …" trigger. Claude can't tell when to load it, and it may clash with sibling skills. Fix: "<Does X>. Use when <concrete trigger>." Write it in the third person.
2. Rule 7 Guardrails (SKILL.md): there's no Scope section. Without a "does NOT" line, nothing stops scope from growing. Fix: add a Scope section with DOES and Does NOT lines, plus STOP gates where scope could grow.
3. Rule 8 Eval-backed (evals/evals.json is missing): Stage B can't run. Fix: add ≥3 realistic cases, each with `id`, `prompt`, `expected_output`, `files` and objective `assertions`.

## 🟡 Should fix
4. Rule 7: check for TodoWrite steps and a Red flags table. They're probably missing too, since the Scope section is.

## Not checked (from the description only)
Rules 2–6: no hard dependencies outside the plugin, SKILL.md under ~500 lines, no mandatory subagents, written as imperative steps, each step's output written to disk.
```

4. **Reply to you:**

---

**Stage A findings for `<skill>`.** Full details are in `.claude-skills-work/<skill>/review/rubric.md`.

- 🔴 **Rule 1:** the description "Helps with stuff" has no concrete "Use when …" trigger, so the skill won't load reliably.
- 🔴 **Rule 7:** there's no Scope section and no "does NOT" line.
- 🔴 **Rule 8:** `evals/evals.json` is missing.
- 🟡 **Rule 7:** confirm the skill has TodoWrite steps, STOP gates and a Red flags table.
- **Rules 2–6:** not checked. Send me the skill's path and I'll read the files to score them.

**Stage B ⛔ gate:** I can't run the baseline eval yet because there are **0 cases**. That means 0 × 2 runs plus 0 × 2 judge calls, so there's nothing to compare.

Once there are N cases (minimum 3), the run is N × 2 runs plus N × 2 judge calls. Each call is a fresh `claude -p` at about $0.10 and 20–40 s. For example, 3 cases make 12 calls, about $1.20; 4 cases make 16 calls, about $1.60. The baseline is `none` for a new skill, or `HEAD` if you're editing an existing one.

To fix the skill, use `skill-authoring:skill-creator`. I don't edit the skill under review.

**Next step:** send the skill's path and add ≥3 eval cases, or tell me which tasks the skill should handle and I'll suggest some. **Approve the eval run** once the cases exist?

---

Stage C stops here. The verdict is **ITERATE** because of the 3 🔴 items. It's based on the rubric only, since no eval was possible.