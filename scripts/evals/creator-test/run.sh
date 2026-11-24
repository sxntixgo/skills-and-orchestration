#!/usr/bin/env bash
# Creator test: does a skill-creator write skills that help, at low token cost?
# 1. Each creator writes the same skills (generate.json) with real Write/Edit tools:
#    ours (skill-authoring:skill-creator), Anthropic's skill-creator, and CLAUDE.md alone.
# 2. Each generated skill is scored on held-out cases the creators never saw
#    (heldout-<skill>.json), against no skill, with the same blind judge.
# Usage: bash scripts/evals/creator-test/run.sh [workdir]   (resumable; stops at a usage limit)
# Needs: claude CLI logged in. Cost: about 50 isolated calls.
set -uo pipefail
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
T=scripts/evals/creator-test
W=${1:-.claude-skills-work/creator-test}
ANTHROPIC=${ANTHROPIC_SKILL_CREATOR:-$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator}
OURS=plugins/skill-authoring/skills/skill-creator
SKILLS="incident-postmortem release-notes"
AB="python3 scripts/evals/abeval.py"
mkdir -p "$W"

# 1. generate (no grading: the output is the skill folder)
[[ -d "$ANTHROPIC" ]] || { echo "Anthropic skill-creator not found: $ANTHROPIC"; exit 2; }
$AB run --skill $OURS --evals $T/generate.json --claudemd --baseline none --baseline-skill "$ANTHROPIC" \
  --out "$W/gen-ours-vs-anthropic" --jobs 4 || exit 1
$AB run --skill $OURS --evals $T/generate.json --claudemd --baseline none --only old_skill \
  --out "$W/gen-claudemd" --jobs 2 || exit 1

# 2. collect the generated skills
for pair in "ours:gen-ours-vs-anthropic/snap/new_skill" "anthropic:gen-ours-vs-anthropic/snap/old_skill" "claudemd:gen-claudemd/snap/old_skill"; do
  c=${pair%%:*}; snap=$W/${pair#*:}
  for s in $SKILLS; do
    src=$(find "$snap" -path "*/$s/SKILL.md" -not -path "*/case-files/*" | head -1)
    dst=$W/gen/$c/skills/$s
    if [[ -z "$src" ]]; then echo "$c: no $s generated"; continue; fi
    rm -rf "$dst"; mkdir -p "$(dirname "$dst")"; cp -R "$(dirname "$src")" "$dst"
    echo "$c/$s: $(python3 $OURS/scripts/check_skill.py "$dst" | tail -1)"
  done
done

# 3. score each generated skill on the held-out cases (no-skill baseline once per skill)
for s in $SKILLS; do
  for c in ours anthropic claudemd; do
    d=$W/gen/$c/skills/$s; o=$W/score/$s/$c
    [[ -f $d/SKILL.md ]] || continue
    if [[ $c == ours ]]; then extra="--baseline none"; else extra="--baseline none --only new_skill"; fi
    $AB run --skill "$d" --evals $T/heldout-$s.json $extra --out "$o" --jobs 3 || exit 1
    $AB grade --out "$o" --jobs 3 >/dev/null || exit 1
    $AB report --out "$o" >/dev/null || exit 1
  done
done

# 4. summary
python3 - "$W" $SKILLS <<'EOF'
import json, sys
from pathlib import Path
W, skills = Path(sys.argv[1]), sys.argv[2:]
rows = ["| skill | creator | pass | tokens/run | SKILL.md chars | refs |", "|---|---|:---:|---:|---:|---:|"]
for s in skills:
    for c in ("none", "ours", "anthropic", "claudemd"):
        src = W / "score" / s / ("ours" if c == "none" else c)
        cfg = "old_skill" if c == "none" else "new_skill"
        runs = sorted((src / "runs").glob(f"case-*/{cfg}"))
        if not runs:
            continue
        g = [json.loads((r / "grading.json").read_text())["summary"] for r in runs if (r / "grading.json").exists()]
        t = [sum(json.loads((r / "timing.json").read_text())["tokens"].values()) for r in runs]
        p = sum(x["passed"] for x in g); n = sum(x["total"] for x in g)
        page = W / "gen" / c / "skills" / s / "SKILL.md"
        refs = list((page.parent / "references").glob("*")) if page.exists() else []
        rows.append(f"| {s} | {'no skill' if c == 'none' else c} | {p}/{n} | {round(sum(t)/len(t)/1000,1)}k | "
                    f"{len(page.read_text()) if page.exists() else '-'} | {len(refs)} |")
out = "\n".join(rows)
(W / "summary.md").write_text(out + "\n")
print(out)
EOF
