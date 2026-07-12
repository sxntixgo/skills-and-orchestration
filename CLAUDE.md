# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

`frugal-skills` is a collection of reusable [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills),
packaged as a **Claude Code plugin** so it can be installed with:

```bash
/plugin marketplace add sxntixgo/frugal-skills
/plugin install frugal-skills@frugal-skills   # plugin@marketplace
```

Once installed, skills are namespaced by the plugin, e.g. `frugal-skills:skill-creator`.

The skills cover authoring skills, researching, building software, and reviewing
software. They are designed to be **self-contained** and **token-frugal** (see
Principles below).

**Status: v1.3.0.** All 10 skills are shipped, self-contained, and reviewed by
`skill-reviewer` (including itself). Eval results are in
[`docs/validation-2026-07-11.md`](docs/validation-2026-07-11.md). Key learning
to keep in mind when adding or changing skills: **a skill earns its token cost
by encoding a process the model does not already perform** (e.g. `skill-reviewer`
measured +0.73 lift), **not by restating knowledge a frontier model already has**
(`security-review` measured 0.00 detection lift — its value is consistency and
coverage). Prefer process/discipline over re-explaining what the model knows.

## Repository layout

```
frugal-skills/
  CLAUDE.md                     # this file
  plan.md                       # roadmap and task list
  README.md                     # install + usage docs
  .claude-plugin/
    plugin.json                 # plugin manifest
    marketplace.json            # marketplace listing (points at this repo)
  skills/
    <skill-name>/
      SKILL.md                  # required: frontmatter + instructions
      references/*.md           # optional: loaded on demand (progressive disclosure)
      scripts/*                 # optional: helper scripts a skill can run
      evals/evals.json          # required: hand-authored cases (skill_name, evals[])
      evals/files/*             # optional: input fixtures referenced by cases
```

Eval runs and their aggregated `benchmark.json` are generated into a gitignored
workspace (`.claude-skills-work/evals/<skill>/iteration-N/`), not committed.

## Skill authoring conventions

Every skill in `skills/` MUST follow these rules. The `skill-creator` and
`skill-reviewer` skills enforce them — use them.

1. **Frontmatter.** Each `SKILL.md` starts with YAML frontmatter:
   ```yaml
   ---
   name: kebab-case-name        # optional for plugin skills (dir name wins);
                                #   HOUSE RULE: include it and keep it == dir name
   description: <what it does>. Use when <concrete trigger>.   # third person
   ---
   ```
   The `name` + `description` are what Claude sees when deciding whether to load
   the skill (the body is loaded only after it triggers). So the `description`
   must carry an explicit, concrete trigger. House style is "what it does. Use
   when <trigger>." — matches the official docs' third-person format.

2. **Self-contained.** A skill must work with zero dependency on anything
   *outside this plugin* (do not require `superpowers` or any external skill).
   Cross-references *within* this plugin are fine — all skills ship together —
   but do it via the trigger `description`, not a hard "you must invoke X" step,
   so each skill still degrades gracefully on its own.

3. **Progressive disclosure.** Keep `SKILL.md` lean (aim < ~500 lines). Push
   detail into `references/*.md` that the skill tells Claude to read only when
   needed. This keeps the default context small.

4. **Token-frugal / single context window.** Do NOT mandate spawning subagents
   during normal skill *use*. Skills should be executable in a single context
   window. Agents are allowed only when explicitly worth it, never as a hard
   requirement. (The one sanctioned exception is dev-time evals — see rule 8.)

5. **Imperative and concrete.** Write instructions to Claude, not prose about
   the topic. Prefer checklists, tables, decision trees, and short examples.

6. **Checkpointed / resumable.** Any multi-step skill MUST write its
   intermediate outputs to disk (a predictable working file/dir, e.g.
   `./.claude-skills-work/<skill>/<step>.md` or a path the user names) as it
   goes — not only a final answer. Each step states where it wrote its output
   and how to resume from it, so work can be paused and continued from any
   intermediate step in a later session. This also keeps the live context
   small (write it down, don't hold it in context).

7. **Guardrails against drift.** Each skill MUST keep Claude on the expected
   task. Include: an explicit scope ("what this skill does / does NOT do"), a
   checklist of the required steps (surfaced as TodoWrite items so progress is
   tracked and visible), STOP/checkpoint gates where Claude pauses for the user
   instead of expanding scope, and a short "red flags" list of common ways to
   deviate (e.g. skipping tests, inventing requirements, over-engineering) with
   the correction. When in doubt, the skill tells Claude to stop and ask rather
   than guess.

8. **Eval-backed (baseline comparison).** Each skill MUST ship an
   `evals/evals.json` with realistic test cases (prompt, optional input files,
   expected behavior). Before a skill is considered done, prove it helps by a
   **baseline comparison**: run the cases in a fresh session *with* the skill vs.
   *with it disabled*, and compare pass rate against the token/time overhead
   (aggregate into a workspace `benchmark.json`; see below). This is the ONLY place isolated /
   subagent runs are expected — it is a dev-time verification step, never part
   of normal skill use. `skill-reviewer` drives this loop. Eval file format and
   workflow: https://agentskills.io/skill-creation/evaluating-skills.

## Core principles baked into the skills

- **DRY / YAGNI / KISS** drive the `software-development` skill.
- **Tests are first-class** — `writing-tests` is a dedicated skill; the dev
  skill points to it rather than duplicating it.
- **Review is layered** — `code-review` (correctness + quality) and
  `security-review` (vuln classes, authz, secrets) are separate skills.

## Developing skills in this repo

Claude Code does **not** auto-load a bare `skills/` directory at a repo root —
only `.claude/skills/` and *installed* plugins load. So to exercise the skills
while building them (e.g. running `skill-reviewer` on `skill-creator`):

- Launch Claude Code with this repo as a live plugin dir:
  ```bash
  claude --plugin-dir .
  ```
- After editing a skill, run `/reload-plugins` to pick up changes.
- Skills are namespaced: invoke `frugal-skills:skill-reviewer`, etc.
- Before publishing, validate and test locally:
  ```bash
  claude plugin validate .          # check plugin.json / marketplace.json
  /plugin marketplace add ./        # add this repo as a local marketplace
  ```

## Working agreements for Claude in this repo

- When creating or editing a skill, invoke `skill-creator`; when finishing one,
  invoke `skill-reviewer`. They are meant to be used in tandem.
- Keep the directory `name` and frontmatter `name` in sync.
- Do not push to a remote or create GitHub resources unless explicitly asked.
- Update `plan.md` task checkboxes as work completes.
