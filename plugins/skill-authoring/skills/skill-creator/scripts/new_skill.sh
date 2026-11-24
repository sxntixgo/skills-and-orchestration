#!/usr/bin/env bash
#
# new_skill.sh — deterministically scaffold a new skill directory.
#
# Usage:  scripts/new_skill.sh <skill-name>
#   <skill-name> must be kebab-case (lowercase letters, digits, hyphens).
#
# Creates skills/<skill-name>/ with a SKILL.md skeleton, an evals/evals.json
# stub (agentskills.io format), and empty references/ + evals/files/ dirs.
# Refuses to overwrite an existing skill. Idempotent only in that it will
# never clobber: re-running on an existing skill exits non-zero.

set -euo pipefail

NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "error: skill name required" >&2
  echo "usage: scripts/new_skill.sh <skill-name>" >&2
  exit 2
fi

if [[ ! "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: '$NAME' is not kebab-case (lowercase letters, digits, hyphens)" >&2
  exit 2
fi

# The skill lands in the git repo you run this from (skills/<name>), not next to this script,
# which now lives in the skill-authoring plugin.
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILL_DIR="$REPO_ROOT/skills/$NAME"

if [[ -e "$SKILL_DIR" ]]; then
  echo "error: $SKILL_DIR already exists — refusing to overwrite" >&2
  exit 1
fi

mkdir -p "$SKILL_DIR/references" "$SKILL_DIR/evals/files"
touch "$SKILL_DIR/references/.gitkeep" "$SKILL_DIR/evals/files/.gitkeep"

# Title-case the name for the H1 (my-skill -> My Skill).
TITLE="$(echo "$NAME" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}}1')"

cat > "$SKILL_DIR/SKILL.md" <<EOF
---
name: $NAME
description: TODO — <what it does>. Use when <concrete trigger the user would hit>.
---

# $TITLE

## Scope
This skill DOES: TODO
This skill does NOT: TODO

## Steps
<!-- Surface these as TodoWrite items when the skill runs. -->
1. TODO

## Checkpoints
Write intermediate output to \`./.claude-skills-work/$NAME/\` at each step, and
say where it was written so work can resume from any step.

## Red flags (stop and correct)
- TODO — a common way this skill drifts, and the correction.

## Done when
- TODO — observable success criteria.
- Evals pass a baseline comparison (run \`skill-reviewer\`).
EOF

cat > "$SKILL_DIR/evals/evals.json" <<EOF
{
  "skill_name": "$NAME",
  "evals": [
    {
      "id": 1,
      "prompt": "TODO — a realistic user message that should trigger this skill.",
      "expected_output": "TODO — human-readable description of what success looks like.",
      "files": []
    }
  ]
}
EOF

echo "Scaffolded skill at: skills/$NAME"
echo "  - SKILL.md            (fill the TODOs in stages 2-3)"
echo "  - evals/evals.json    (fill the stub case in stage 4)"
echo "  - references/         (add reference docs as needed)"
echo "  - evals/files/        (add input fixtures if cases need them)"
