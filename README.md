# skills-and-orchestration

Claude Code plugins, each skill small, self-contained and measured:

| Plugin | What it is |
|---|---|
| **frugal-skills** (3.0.0) | 6 skills for building software: design, plan, build (TDD), debug, review, research |
| **orchestration** (0.5.0) | Claude plans, reviews and merges; [opencode](https://opencode.ai) on a local model implements small tasks in git worktrees (also research and Dependabot fixes) |
| **skill-authoring** (0.2.0) | `skill-creator` and `skill-reviewer`: write lean skills and prove they help |

Every skill is:

- **Self-contained and token-frugal** — one page that holds only the process the model
  wouldn't follow on its own; every extra file read is a turn that re-reads the whole context.
- **Checkpointed** — multi-step skills write their progress to disk, so work can resume.
- **Guarded** — explicit scope, steps, stop points only where they protect something, red flags.
- **Eval-backed** — each skill ships `evals/evals.json`; it stays only if a measured comparison
  shows it helps (see [Evaluation results](#evaluation-results)).

## Install

```bash
/plugin marketplace add sxntixgo/skills-and-orchestration
/plugin install frugal-skills@frugal-skills
/plugin install orchestration@frugal-skills      # optional: Claude + opencode
/plugin install skill-authoring@frugal-skills    # optional: to write skills
```

Run `/reload-plugins` afterwards. Skills are namespaced, e.g. `frugal-skills:code-review`.

## frugal-skills

| Skill | Use it when… |
|-------|--------------|
| `brainstorming` | turning a vague idea into a validated design through dialogue |
| `writing-plans` | turning a spec/design into a phased, verifiable implementation plan |
| `software-development` | building backend/frontend software (TDD + DRY/YAGNI/KISS), one planned phase (honoring per-task models), or adding tests |
| `debugging` | diagnosing a bug before fixing: reproduce, isolate, verify the cause, fix, confirm |
| `code-review` | reviewing code for correctness, security and quality |
| `online-research` | web research with independent, cited sources |

## orchestration

Claude Code orchestrates and reviews; opencode on a local model implements. See
[`plugins/orchestration/README.md`](./plugins/orchestration/README.md). The dispatch scripts check
the model server only when `ORCHESTRA_LLM_URL` (and optionally `ORCHESTRA_LLM_TOKEN_FILE`) is set.

| Skill | Role |
|---|---|
| `claude-orchestrate-development` | plan gate → task graph → write/dispatch/review/merge loop, one session per phase |
| `claude-write-task` | one precise task spec for the implementer |
| `claude-dispatch` | run one task with opencode in its own worktree |
| `claude-review-merge` | check scope, tests and lint, then merge, send back or take over |
| `claude-orchestrate-research` | split a research question across opencode researchers, verify, report |
| `claude-fix-dependabot` | triage Dependabot alerts and fix them through the same loop |

## Evaluation results

Every number comes from `scripts/evals/abeval.py`: each case runs in a fresh isolated
`claude -p --safe-mode` (Opus), once with and once without the skill (or against the previous
version, or another skill); a blind judge grades each answer against objective assertions and
must quote evidence. Raw answers, gradings and timings are in [`docs/evals/`](./docs/evals/).

| Round | Result | Report |
|---|---|---|
| Token cut, all 15 Claude-side skills (2026-11-23) | 228/256 → **250/256** assertions, **−23 %** tokens per run (−35 to −46 % where a reference file was read) | [validation-2026-11-23](./docs/validation-2026-11-23.md) |
| Consolidation (2026-11-23) | security-review **0.00** vs no skill (twice) and writing-tests +0.08 → folded; merged code-review 33/33, software-development 41/42 | same, Round 3 |
| Skill authoring vs CLAUDE.md and Anthropic's skill-creator (2026-11-24) | skill-reviewer **+0.40** / **+0.38**; rewritten skill-creator 17/17 vs 13/17, and the skills it writes score 19/19 on held-out cases with the smallest pages | [validation-2026-11-24](./docs/validation-2026-11-24.md) |
| First baselines (2026-07-11) | process skills help (+0.19 to +0.73); knowledge-restating skills don't | [validation-2026-07-11](./docs/validation-2026-07-11.md) |

The main lesson: a skill earns its tokens by encoding a **process** the model doesn't already
follow (stop points, ordering, formats, the mistakes it really makes), not by restating
knowledge. Rerun or extend the evals with [`scripts/evals/README.md`](./scripts/evals/README.md).

## Developing / contributing

```bash
claude --plugin-dir .                      # load this repo as a live plugin
/reload-plugins                            # after editing a skill
claude plugin validate .                   # check the manifests
python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py <skill dir>
for t in scripts/tests/*.sh; do bash "$t"; done
bash scripts/ci.sh                         # everything CI runs (no model calls)
```

See [`CLAUDE.md`](./CLAUDE.md) for the authoring rules and the eval workflow, and
[`plan.md`](./plan.md) for the history.

## License

[MIT](./LICENSE)
