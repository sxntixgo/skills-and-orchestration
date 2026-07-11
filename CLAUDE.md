# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

`claude-skills` is a collection of reusable [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills),
packaged as a **Claude Code plugin** so it can be installed with:

```bash
/plugin marketplace add sxntixgo/claude-skills
/plugin install claude-skills@claude-skills   # plugin@marketplace
```

Once installed, skills are namespaced by the plugin, e.g. `claude-skills:skill-creator`.

The skills cover authoring skills, researching, building software, and reviewing
software. They are designed to be **self-contained** and **token-frugal** (see
Principles below).

## Repository layout

```
claude-skills/
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
```

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

4. **Token-frugal / single context window.** Do NOT mandate spawning subagents.
   Skills should be executable in a single context window. Agents are allowed
   only when explicitly worth it, and never as a hard requirement.

5. **Imperative and concrete.** Write instructions to Claude, not prose about
   the topic. Prefer checklists, tables, decision trees, and short examples.

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
- Skills are namespaced: invoke `claude-skills:skill-reviewer`, etc.
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
