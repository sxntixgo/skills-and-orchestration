---
name: skill-creator
description: Writes or edits a lean, token-frugal Claude Code skill (one self-contained SKILL.md holding only the process the model wouldn't follow on its own, plus evals with objective assertions), drafts first, then asks, and hands it to skill-reviewer. Use when the user asks to create, write, add, edit, fix or slim down a skill.
---

# Skill Creator

Draft first, then ask. You build; `skill-reviewer` measures. A skill earns its tokens only by
changing what the model does; every extra file read is a turn that re-reads the whole context.

## Scope
DOES: write or edit a skill's `SKILL.md`, `evals/evals.json` and scripts; validate them.
Does NOT: run evals or judge (→ `skill-reviewer`); invent the domain's requirements; push.

## Steps (TodoWrite items; the skill's files are the checkpoint)
1. **Read only what you'll change:** editing → the target's `SKILL.md`, `references/*` and
   `evals/evals.json` in ONE parallel batch. New skill → nothing; the skeleton below is the house
   style. `CLAUDE.md` is already in your context: don't open it.
2. **Too vague to draft** (no task, no trigger)? Ask ONE question offering 2–3 concrete skills,
   each with its trigger. Otherwise draft; put small assumptions in the reply.
3. **Draft** into the skill's folder with the rules below. Editing: change only what was asked.
4. **Evals** (asked to skip → write them anyway, one sentence why): 3–5 cases
   `{id, prompt, expected_output, files, assertions}`; one case where the skill must stop or
   refuse; 2–4 evidence-only assertions each ("names file:line", never "is helpful"); a fixture in
   `evals/files/` whenever the skill works on input.
5. **Validate:** `python3 <this skill>/scripts/check_skill.py <skill dir>`; fix FAILs, rerun.
6. **Reply, short:** description, the CHECK line, one line per eval case, assumptions; ask
   "Approve, or what should change?"; next step: `skill-reviewer`. Don't grade your own skill.

## Writing rules
- **Description:** third person, ≤ ~400 chars, what it does + "Use when <words the user types>".
- **Content:** only what changes behaviour: step order, stop points, decision tables, output
  formats, mistakes the model really makes. Cut what it already knows (measured: 0 lift).
- **One page, ≤ ~4k chars.** `references/` only for big, rarely needed detail, one level deep,
  read in the same turn. Never "read X first".
- **Scripts** for deterministic steps: run, not read; give the command and the line to check.
- **⛔ stops** only to protect something (cost, irreversible or outward actions, a real design
  choice); otherwise act and state assumptions.
- **Fixed output format** when a script, reviewer or agent reads the result.
- No mandatory subagents; another plugin's skill only "(if installed)" with a fallback.

## Skeleton
```markdown
---
name: <kebab-case = folder>
description: <Does X for Y>. Use when <trigger phrases>.
---
# <Title>
<the point, 1–2 lines>
## Scope
DOES: … Does NOT: … (→ other skill)
## Steps (TodoWrite items; output in `./.claude-skills-work/<name>/`)
1. …
## Red flags
| If you notice… | Do this |
## Done when
…
```

## Red flags
| If you notice… | Do this |
|---|---|
| Asking before drafting a clear request | Draft; ask after |
| Opening `CLAUDE.md` or sibling skills | Don't; you have what you need |
| Background the model knows; a small `references/` file | Cut it; inline it |
| Vague assertions, or a case with no input | Evidence-only; add a fixture |
| Rewriting untouched parts in an edit | Change only what was asked |
| Judging your own skill | Hand off to `skill-reviewer` |

## Done when
`check_skill.py` passes; the reply asks for approval and names `skill-reviewer` next.
