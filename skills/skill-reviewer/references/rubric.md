# The rubric (Stage A)

Score the skill against all 8 authoring rules. For each, record a finding only
if something is wrong, rated:

- 🔴 **Must fix** — breaks the skill, a safety/scope violation, or blocks evals.
- 🟡 **Should fix** — real quality problem; the skill works but weakly.
- 🟢 **Consider** — minor polish or a judgment call.

Cite `file:line` where you can. Do not rewrite anything — report only.

## Checks per rule

**Rule 1 — Frontmatter**
- `name` present, kebab-case, and equal to the directory name.
- `description` is third person, states what it does, and has a CONCRETE
  "Use when …" trigger (not "helps with X"). 🔴 if the trigger is missing/vague.
- Trigger doesn't collide with a sibling skill's trigger.

**Rule 2 — Self-contained**
- No dependency on anything outside this plugin (no "requires superpowers", no
  external skill). 🔴 if it hard-depends on another skill.
- Cross-references to sibling skills go through the description, not a hard
  "you must invoke X".

**Rule 3 — Progressive disclosure**
- `SKILL.md` is lean (< ~500 lines). 🟡 if bloated with material that belongs in
  `references/`.
- References are named at the point of use, not dumped up front.

**Rule 4 — Token-frugal**
- Runnable in one context window. 🔴 if it mandates subagents during normal use
  (evals are the only allowed exception).
- No needless repetition; every line earns its token cost.

**Rule 5 — Imperative & concrete**
- Instructions TO Claude (checklists, tables, steps), not prose ABOUT the topic.
  🟡 if it's an essay.

**Rule 6 — Checkpointed / resumable**
- Multi-step skills write intermediate output to disk each step and say where.
  🔴 for a multi-step skill with no checkpointing.

**Rule 7 — Guardrails**
- Has an explicit Scope with a "does NOT" line.
- Steps are surfaced as TodoWrite items; STOP gates exist where scope could
  expand; a Red-flags list is present.
- Prefers stop-and-ask over guessing. 🟡 if guardrails are thin.

**Rule 8 — Eval-backed**
- `evals/evals.json` exists with ≥3 realistic cases in the correct format
  (`skill_name`, `evals[]`, each with `id`/`prompt`/`expected_output`/`files`).
  🔴 if missing — Stage B cannot run.
- Prompts are realistic and would plausibly trigger THIS skill.

## Output
Write a findings list to `review/rubric.md`, most severe first, e.g.:

```
🔴 Rule 1 — description has no trigger (SKILL.md:3): "Helps with tests."
🟡 Rule 3 — SKILL.md is 640 lines; move the format tables to references/.
🟢 Rule 7 — consider adding a red flag for the empty-input case.
```

Then report the same list to the user before Stage B.
