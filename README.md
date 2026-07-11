# claude-skills

A collection of reusable [Claude Code](https://code.claude.com/docs) skills,
packaged as a Claude Code plugin. The skills cover authoring skills, online
research, software development, testing, and reviewing software.

Every skill is designed to be:

- **Self-contained** — no dependency on any other plugin.
- **Token-frugal** — runnable in a single context window; detail lives in
  `references/*.md` loaded only when needed.
- **Checkpointed / resumable** — multi-step skills write intermediate outputs to
  disk so you can pause and continue from any step.
- **Guarded** — explicit scope, a required-steps checklist, and STOP gates keep
  Claude on task.
- **Eval-backed** — each skill ships `evals/evals.json` and is validated by a
  baseline comparison (with-skill vs. skill-disabled).

## Install

```bash
/plugin marketplace add sxntixgo/claude-skills
/plugin install claude-skills@claude-skills
```

After installing, run `/reload-plugins`. Skills are namespaced by the plugin,
e.g. `claude-skills:skill-creator`.

## Skills

| Skill | Use it when… |
|-------|--------------|
| `skill-creator` | authoring a new skill or editing an existing one |
| `skill-reviewer` | reviewing a skill and running its baseline evals |
| `online-research` | doing structured web research with cited sources |
| `software-development` | building backend/frontend software (TDD + DRY/YAGNI/KISS) |
| `writing-tests` | designing and writing test cases |
| `code-review` | reviewing code for correctness and quality |
| `security-review` | reviewing code for security vulnerabilities |

> Status: under active development. See [`plan.md`](./plan.md) for the roadmap
> and which skills exist yet.

## Developing / contributing

Claude Code does not auto-load a bare `skills/` directory, so to work on these
skills locally:

```bash
claude --plugin-dir .        # load this repo as a live plugin
/reload-plugins              # after editing a skill
claude plugin validate .     # check the manifests
```

See [`CLAUDE.md`](./CLAUDE.md) for the full authoring conventions (the 8 rules
every skill must follow) and the eval workflow.

## License

[MIT](./LICENSE)
