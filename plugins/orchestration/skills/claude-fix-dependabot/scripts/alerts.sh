#!/bin/bash
# Open Dependabot alerts of a GitHub repo as a TSV table (one row per alert), sorted by manifest.
# Usage: alerts.sh <owner/repo>            (live, needs gh logged in)
#        alerts.sh --file <alerts.json>    (offline, a saved `gh api .../dependabot/alerts` reply)
# Columns: number severity scope ecosystem manifest package vulnerable_range first_patched ghsa
set -euo pipefail
if [ "${1:-}" = --file ]; then cat "$2"; else
  gh api --paginate "repos/$1/dependabot/alerts?state=open&per_page=100"; fi |
jq -r '.[] | [.number, .security_advisory.severity, .dependency.scope, .dependency.package.ecosystem,
  .dependency.manifest_path, .dependency.package.name, .security_vulnerability.vulnerable_version_range,
  (.security_vulnerability.first_patched_version.identifier // "none"), .security_advisory.ghsa_id] | @tsv' |
sort -t$'\t' -k5,5 -k6,6 -k1,1n
