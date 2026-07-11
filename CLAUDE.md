# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

`claude-skills` is a collection of reusable [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills),
packaged as a **Claude Code plugin** so it can be installed with:

```bash
/plugin marketplace add sxntixgo/claude-skills
/plugin install claude-skills
```

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

1. **Frontmatter is required.** Each `SKILL.md` starts with YAML frontmatter:
   ```yaml
   ---
   name: kebab-case-name        # matches the directory name
   description: Use when <trigger> - <what it does>. Third person, starts with "Use when".
   ---
   ```
   The `description` is the ONLY thing Claude sees when deciding whether to load
   the skill. Make the trigger explicit and concrete.

2. **Self-contained.** A skill must work with zero dependency on other plugins
   (do not require `superpowers` or any external skill to be installed). If a
   skill references another skill in THIS repo, keep that reference optional.

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

## Working agreements for Claude in this repo

- When creating or editing a skill, invoke `skill-creator`; when finishing one,
  invoke `skill-reviewer`. They are meant to be used in tandem.
- Keep the directory `name` and frontmatter `name` in sync.
- Do not push to a remote or create GitHub resources unless explicitly asked.
- Update `plan.md` task checkboxes as work completes.
