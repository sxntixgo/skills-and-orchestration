#!/usr/bin/env bash
# Tests for plugins/orchestration/skills/claude-fix-dependabot/scripts/alerts.sh:
# offline --file mode, and live mode with a stub `gh` that returns two pages (as --paginate does).
# Run: bash scripts/tests/test_alerts.sh
set -uo pipefail
AL="$(cd "$(dirname "$0")/../.." && pwd)/plugins/orchestration/skills/claude-fix-dependabot/scripts/alerts.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0
ok() { echo "ok   $1"; }
no() { echo "FAIL $1"; printf '%s\n' "$2" | sed 's/^/     /'; fail=1; }

alert() {  # alert <number> <severity> <manifest> <package> <patched|null>
  local fp='null'; [[ $5 != null ]] && fp="{\"identifier\":\"$5\"}"
  printf '{"number":%s,"security_advisory":{"severity":"%s","ghsa_id":"GHSA-%s"},
    "dependency":{"scope":"runtime","manifest_path":"%s","package":{"ecosystem":"npm","name":"%s"}},
    "security_vulnerability":{"vulnerable_version_range":"< 2.0","first_patched_version":%s}}' \
    "$1" "$2" "$1" "$3" "$4" "$fp"
}
# unsorted on purpose: the output must sort by manifest, then package, then number (numerically)
echo "[$(alert 12 high web/package.json zlib 2.0), $(alert 3 low api/package.json yaml null),
       $(alert 10 critical api/package.json axios 1.9), $(alert 9 medium api/package.json axios 1.9)]" > "$tmp/page1.json"
echo "[$(alert 2 high api/package-lock.json qs 6.1)]" > "$tmp/page2.json"

T=$'\t'
want1="9${T}medium${T}runtime${T}npm${T}api/package.json${T}axios${T}< 2.0${T}1.9${T}GHSA-9
10${T}critical${T}runtime${T}npm${T}api/package.json${T}axios${T}< 2.0${T}1.9${T}GHSA-10
3${T}low${T}runtime${T}npm${T}api/package.json${T}yaml${T}< 2.0${T}none${T}GHSA-3
12${T}high${T}runtime${T}npm${T}web/package.json${T}zlib${T}< 2.0${T}2.0${T}GHSA-12"

out=$(bash "$AL" --file "$tmp/page1.json" 2>&1)
[[ "$out" == "$want1" ]] && ok "--file: sorted TSV, missing patch -> none" || no "--file output" "$out"

echo '[]' > "$tmp/empty.json"
out=$(bash "$AL" --file "$tmp/empty.json" 2>&1); rc=$?
[[ $rc -eq 0 && -z "$out" ]] && ok "--file: no alerts -> empty, exit 0" || no "--file empty (rc=$rc)" "$out"

bash "$AL" --file "$tmp/missing.json" >/dev/null 2>&1 && no "--file missing file should fail" "" \
  || ok "--file: missing file -> non-zero"

# live mode: stub gh prints both pages back to back and records its arguments
mkdir -p "$tmp/bin"
cat > "$tmp/bin/gh" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" > "$tmp/gh-args"; cat "$tmp/page1.json" "$tmp/page2.json"
EOF
chmod +x "$tmp/bin/gh"
out=$(PATH="$tmp/bin:$PATH" bash "$AL" owner/repo 2>&1)
lines=$(printf '%s\n' "$out" | wc -l | tr -d ' ')
first=$(printf '%s\n' "$out" | head -1 | cut -f1,5)
[[ $lines == 5 && "$first" == "2${T}api/package-lock.json" ]] && ok "live: both pages, merged and sorted" \
  || no "live output ($lines lines)" "$out"
grep -qx -- --paginate "$tmp/gh-args" && grep -qx 'repos/owner/repo/dependabot/alerts?state=open&per_page=100' "$tmp/gh-args" \
  && ok "live: open alerts, paginated" || no "gh args" "$(cat "$tmp/gh-args")"

exit $fail
