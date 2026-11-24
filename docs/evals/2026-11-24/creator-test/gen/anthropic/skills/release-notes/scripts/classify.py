#!/usr/bin/env python3
"""First-pass classifier for a one-commit-per-line Conventional Commits log.

Usage: classify.py <log-file | ->   (prints JSON to stdout)
Accepts lines with or without a leading short hash.
"""
import json
import re
import sys

LINE = re.compile(
    r"^(?:(?P<hash>[0-9a-f]{7,40})\s+)?"
    r"(?P<type>[a-zA-Z]+)(?:\((?P<scope>[^)]*)\))?(?P<bang>!)?:\s*(?P<subject>.+)$"
)
PR = re.compile(r"#(\d+)")
INTERNAL = {"refactor", "test", "tests", "ci", "build", "chore", "style"}
INTERNAL_SCOPES = {"ci", "test", "tests", "build", "deps-dev", "release"}


def strip_hash(line):
    return re.sub(r"^[0-9a-f]{7,40}\s+", "", line).strip()


def main(path):
    text = sys.stdin.read() if path == "-" else open(path, encoding="utf-8").read()
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    out = {"commits": [], "unparsed": [], "reverted": []}

    reverts = [l for l in lines if re.match(r"^(?:[0-9a-f]{7,40}\s+)?(revert[:(]|Revert )", l)]
    reverted_subjects = set()
    for r in reverts:
        m = re.search(r'"(.+?)"', r) or re.search(r"revert(?:\([^)]*\))?:\s*(.+)$", r, re.I)
        if m:
            reverted_subjects.add(PR.sub("", m.group(1)).strip(" ()"))

    for line in lines:
        if line in reverts:
            out["reverted"].append(line)
            continue
        m = LINE.match(line)
        if not m:
            out["unparsed"].append(line)
            continue
        body = strip_hash(line)
        if PR.sub("", body).strip(" ()") in reverted_subjects:
            out["reverted"].append(line)
            continue
        subject = m["subject"]
        typ = m["type"].lower()
        breaking = bool(m["bang"]) or "BREAKING" in line
        out["commits"].append({
            "line": line,
            "type": typ,
            "scope": m["scope"],
            "breaking": breaking,
            "prs": ["#" + n for n in PR.findall(subject)],
            "subject": PR.sub("", subject).strip(" ()"),
            "suggest": "breaking" if breaking else ("drop" if typ in INTERNAL or (m["scope"] or "").lower() in INTERNAL_SCOPES else typ),
        })
    json.dump(out, sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
