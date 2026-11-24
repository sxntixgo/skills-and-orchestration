The skill fails review with 2 🔴 must-fix findings and 1 🟡 should-fix. No evals can run until it has `evals/evals.json`. I haven't edited the skill.

## What I'd do, in order

1. **TodoWrite:** three items: `Stage A — rubric`, `Stage B — eval gate`, `Stage C — verdict`.
2. **Read the target's files at the same time.** You didn't give a path, so I assume `skills/<skill>/`. I'd read `SKILL.md` and every `references/*.md`, try `evals/evals.json` (you said it doesn't exist, so this fails), and list `scripts/`. I assume the rest of the skill is an ordinary, short `SKILL.md` with no references and no scripts.
3. **Score it against the 8 rules** (findings below).
4. **Write the findings** to `./.claude-skills-work/<skill>/review/rubric.md`:

```markdown
# Rubric review — <skill>

| Sev | Rule | Location | Finding | Fix |
|---|---|---|---|---|
| 🔴 | 1 Frontmatter | SKILL.md:3 | `description: Helps with stuff` is vague: no third-person "what it does", no concrete "Use when …", so it can't be triggered reliably and may clash with sibling skills | Rewrite: "<Verb>s <specific thing>. Use when <concrete trigger/situation>." |
| 🔴 | 8 Eval-backed | evals/evals.json (missing) | No eval cases, so Stage B (baseline comparison) can't run | Add ≥ 3 realistic cases with `id`, `prompt`, `expected_output`, `files`, objective `assertions` |
| 🟡 | 7 Guardrails | SKILL.md (no `## Scope`) | No DOES / does NOT boundary, so scope can grow unchecked and there are no STOP gates tied to it | Add `## Scope` with a DOES line and a "Does NOT" line (→ name the sibling skill that handles it) |

Rules 2–6: no problems found (assuming a short, self-contained SKILL.md with no subagents and no multi-step pipeline).
```

5. **Stage C:** no verdict yet. Based on the checklist alone it's **ITERATE**, and a PASS also needs a positive eval result, which is impossible without cases. I'd hand these fixes to `skill-creator`.

## Reply to the user

**<skill>: ITERATE (checklist only). 2 🔴, 1 🟡.** Full findings: `.claude-skills-work/<skill>/review/rubric.md`

- 🔴 **Rule 1** (`SKILL.md:3`): "Helps with stuff" doesn't say what the skill does or when to use it. It needs a third-person summary plus a concrete "Use when …" trigger.
- 🔴 **Rule 8:** there's no `evals/evals.json`, so nothing can be benchmarked. It needs at least 3 realistic cases (`id`, `prompt`, `expected_output`, `files`, objective `assertions`).
- 🟡 **Rule 7:** there's no `## Scope` section. Add a DOES line and a "Does NOT" line that names where out-of-scope work goes.

`skill-creator` can make these fixes; I don't edit the skill under review.

**⛔ Stage B (comparing results with and without the skill)**
- **Eval cases:** there are 0, so I can't run anything yet.
- **Baseline:** `none` for a new skill. If this is an edit, the baseline is the previous git revision (`HEAD`), graded blind.
- **Cost with the minimum 3 cases:**
  - 3 × 2 = 6 runs, plus 3 × 2 = 6 judge calls, so 12 calls.
  - Each call is a fresh `claude -p` (about $0.10 and 20–40 s), so roughly **$1.20** in total.

Can you send at least 3 eval cases, or have `skill-creator` add them? Once they exist: **approve the eval run?**