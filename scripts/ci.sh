#!/usr/bin/env bash
# Repo checks, no model calls: the same command runs locally and in GitHub Actions.
# Usage: bash scripts/ci.sh            (needs bash, git, jq, python3; `claude` for manifest validation)
set -uo pipefail
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
fails=0
step() { printf '\n== %s\n' "$1"; }
bad() { echo "FAIL: $*"; fails=$((fails + 1)); }

step "plugin manifests"
if command -v claude >/dev/null; then
  for p in . plugins/*/; do
    [[ -f "$p/.claude-plugin/plugin.json" ]] || continue
    out=$(claude plugin validate "$p" 2>&1) && echo "ok   $p" || { echo "$out"; bad "claude plugin validate $p"; }
  done
else
  echo "skip: claude CLI not installed (CI installs it)"
fi
for f in .claude-plugin/*.json plugins/*/.claude-plugin/*.json; do
  jq -e . "$f" >/dev/null 2>&1 || bad "invalid JSON: $f"
done
# every plugin in the marketplace exists, and its version matches its plugin.json
jq -r '.plugins[] | "\(.name) \(.source) \(.version)"' .claude-plugin/marketplace.json |
while read -r name src ver; do
  pj="$src/.claude-plugin/plugin.json"
  [[ -f "$pj" ]] || { echo "FAIL: marketplace plugin $name: no $pj"; continue; }
  pv=$(jq -r .version "$pj")
  [[ "$pv" == "$ver" ]] && echo "ok   $name $ver" || echo "FAIL: $name: marketplace $ver != plugin.json $pv"
done | tee /dev/stderr | grep -q '^FAIL' && bad "marketplace entries"

step "skills (check_skill.py)"
for d in skills/*/ plugins/*/skills/*/; do
  [[ -f "$d/SKILL.md" ]] || continue
  out=$(python3 plugins/skill-authoring/skills/skill-creator/scripts/check_skill.py "$d")
  rc=$?; echo "$out" | grep -E '^(FAIL|CHECK)'
  [[ $rc -eq 0 ]] || bad "check_skill.py $d"
done

step "eval and data files are valid JSON"
while IFS= read -r f; do
  jq -e . "$f" >/dev/null 2>&1 || bad "invalid JSON: $f"
done < <(git ls-files '*.json' | grep -v '^docs/evals/')
echo "checked $(git ls-files '*.json' | grep -vc '^docs/evals/') files"

step "scripts parse"
while IFS= read -r f; do
  bash -n "$f" || bad "bash -n $f"
done < <(git ls-files '*.sh')
while IFS= read -r f; do
  python3 -m py_compile "$f" 2>/dev/null || bad "py_compile $f"
done < <(git ls-files '*.py')
echo "checked $(git ls-files '*.sh' '*.py' | wc -l | tr -d ' ') scripts"

step "script tests"
for t in scripts/tests/*.sh; do
  out=$(bash "$t" 2>&1); rc=$?
  echo "$out" | grep -E '^(ok|FAIL)'
  [[ $rc -eq 0 ]] || bad "$t"
done

step "no private data"
# credentials, local user paths, and private hosts must never land in the public repo
pat='(ghp_|github_pat_|gho_|sk-ant-|xox[abp]-|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|Bearer [A-Za-z0-9._-]{24,}|/Users/[a-z]|/home/[a-z][a-z0-9_-]*/|\.h\.[a-z0-9-]+\.com)'
if git grep -nIE "$pat" -- . ':!scripts/ci.sh' | head -5 | grep .; then bad "private data found (see above)"; else echo "ok"; fi

echo
if [[ $fails -eq 0 ]]; then echo "ALL CHECKS PASSED"; else echo "$fails CHECK(S) FAILED"; exit 1; fi
