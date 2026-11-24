#!/usr/bin/env bash
# Tests for plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py.
# Run: bash scripts/tests/test_check_skill.sh
set -uo pipefail
CK="$(cd "$(dirname "$0")/../.." && pwd)/plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0
expect() {  # expect <name> <exit> <grep pattern> <dir>
  local out rc; out=$(python3 "$CK" "$4"); rc=$?
  if [[ $rc -eq $2 ]] && grep -qE "$3" <<<"$out"; then echo "ok   $1"; else echo "FAIL $1 (exit $rc)"; echo "$out" | sed 's/^/     /'; fail=1; fi
}
good() {  # good <dir>: a minimal valid skill
  mkdir -p "$1/evals"
  cat > "$1/SKILL.md" <<EOF
---
name: $(basename "$1")
description: Summarizes a diff into bullets. Use when the user asks for a summary of their changes.
---
# Demo
## Scope
DOES: x. Does NOT: y.
## Red flags
| a | b |
## Done when
z
EOF
  printf '{"skill_name":"%s","evals":[%s]}' "$(basename "$1")" \
    '{"id":1,"prompt":"p","expected_output":"e","files":[],"assertions":["names the file"]},{"id":2,"prompt":"p","expected_output":"e","files":[],"assertions":["a"]},{"id":3,"prompt":"p","expected_output":"e","files":[],"assertions":["a"]}' \
    > "$1/evals/evals.json"
}

good "$tmp/ok-skill"
expect "valid skill passes" 0 "CHECK ok-skill fail=0 warn=0" "$tmp/ok-skill"

good "$tmp/bad-name"; sed -i.bak 's/^name: bad-name/name: other/' "$tmp/bad-name/SKILL.md"
expect "name != folder fails" 1 "FAIL frontmatter name" "$tmp/bad-name"

good "$tmp/no-trigger"; sed -i.bak 's/ Use when the user asks for a summary of their changes\.//' "$tmp/no-trigger/SKILL.md"
expect "missing Use when fails" 1 "FAIL description has no 'Use when" "$tmp/no-trigger"

good "$tmp/few-cases"; printf '{"skill_name":"few-cases","evals":[{"id":1,"prompt":"p","expected_output":"e","files":[],"assertions":[]}]}' > "$tmp/few-cases/evals/evals.json"
expect "too few cases and no assertions fail" 1 "FAIL case 1: no assertions" "$tmp/few-cases"

good "$tmp/small-ref"; mkdir "$tmp/small-ref/references"; echo "tiny" > "$tmp/small-ref/references/x.md"
expect "small, unnamed reference warns" 0 "WARN references/x.md is never named" "$tmp/small-ref"

good "$tmp/no-sections"; printf -- '---\nname: no-sections\ndescription: Does x. Use when y.\n---\n# T\n' > "$tmp/no-sections/SKILL.md"
expect "missing sections fail" 1 "FAIL missing Red flags" "$tmp/no-sections"

exit $fail
