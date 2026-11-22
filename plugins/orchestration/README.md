# orchestration

Claude Code orchestrates and reviews; **opencode** on a local model (here qwen3.8-flash-next on
atlas) implements small, precise tasks, each in its own git worktree. The format both sides share
is `contract.md`.

| Side | What | Where |
|---|---|---|
| Claude Code | `claude-orchestrate-development`, `claude-write-task`, `claude-dispatch`, `claude-review-merge`, `claude-orchestrate-research`, `claude-fix-dependabot` | `skills/` (this plugin) |
| opencode | agent `implementer`; agent `researcher`; skills `opencode-develop`, `opencode-research` | `opencode/` → copy to `~/.config/opencode/agent/` and `~/.config/opencode/skills/` |

Rules in one breath: tasks are small with an exact test command; opencode edits only the
listed files and never commits or pushes; Claude reruns the tests and reads the diff before
merging; code follows TDD, YAGNI and DRY; after three rejections Claude takes over using the cheapest
capable model (haiku → sonnet → opus); `concurrency` (default 2) runs tasks in parallel, each in its own
git worktree.

Install (Claude side): `/plugin install orchestration@frugal-skills` once this marketplace is added.
In the homestack devcontainers the opencode side is installed by the `devcontainer` repo.
