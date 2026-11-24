#!/usr/bin/env python3
"""Mechanical checks for a skill folder (the parts of the authoring rules a script can judge).

Usage: python3 check_skill.py <skill dir>
Prints one FAIL/WARN line per problem, then a last line:
  CHECK <name> fail=<n> warn=<n> chars=<SKILL.md chars> refs=<n> cases=<n>
Exit 1 if anything FAILs. Standard library only (Python 3.9+).
"""
import json
import re
import sys
from pathlib import Path

SIZE_WARN = 6000      # chars; ~1.5k tokens. The house target is <= ~4k.
SIZE_FAIL = 20000     # ~500 lines of prose: the official upper bound
DESC_MAX = 1024       # hard limit for the description field
DESC_WARN = 500       # long descriptions cost tokens in every session's skill list
SMALL_REF = 6000      # a reference smaller than this belongs on the page (each read = a turn)


def main(argv):
    if len(argv) != 2:
        print(__doc__.strip().splitlines()[2], file=sys.stderr)
        return 2
    d = Path(argv[1]).resolve()
    fails, warns = [], []
    f, w = fails.append, warns.append

    page = d / "SKILL.md"
    if not page.is_file():
        print(f"FAIL no SKILL.md in {d}")
        print(f"CHECK {d.name} fail=1 warn=0 chars=0 refs=0 cases=0")
        return 1
    text = page.read_text()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    fm = dict(re.findall(r"^(\w+):\s*(.*)$", m.group(1), re.M)) if m else {}
    if not m:
        f("SKILL.md has no YAML frontmatter")
    name, desc = fm.get("name", ""), fm.get("description", "")
    if name != d.name:
        f(f"frontmatter name '{name}' != folder '{d.name}'")
    if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", d.name) or len(d.name) > 64:
        f("folder name is not kebab-case (<= 64 chars)")
    if not desc:
        f("description missing")
    else:
        if len(desc) > DESC_MAX:
            f(f"description is {len(desc)} chars (max {DESC_MAX})")
        elif len(desc) > DESC_WARN:
            w(f"description is {len(desc)} chars; every session pays for it (aim <= ~400)")
        if "use when" not in desc.lower():
            f("description has no 'Use when ...' trigger")
        if re.search(r"\b(I can|I will|you can|you should)\b", desc, re.I):
            f("description is not third person")

    body = text[m.end():] if m else text
    chars = len(text)
    if chars > SIZE_FAIL:
        f(f"SKILL.md is {chars} chars (> {SIZE_FAIL}); split rarely needed detail out")
    elif chars > SIZE_WARN:
        w(f"SKILL.md is {chars} chars; house target <= ~4000")
    for sect, pat in (("Scope", r"^#+\s*Scope"), ("Does NOT line", r"does not"),
                      ("Red flags", r"^#+\s*Red flags"), ("Done when", r"^#+\s*Done when")):
        if not re.search(pat, body, re.I | re.M):
            f(f"missing {sect}")

    refs = sorted((d / "references").glob("*.md")) if (d / "references").is_dir() else []
    for r in refs:
        rel = f"references/{r.name}"
        size = len(r.read_text())
        if rel not in text:
            w(f"{rel} is never named in SKILL.md (dead or unreachable)")
        if size < SMALL_REF:
            w(f"{rel} is {size} chars; inline it (each read costs a turn)")
        if re.search(r"references/[\w.-]+\.md", r.read_text()):
            f(f"{rel} points to another reference (keep references one level deep)")

    cases = []
    ev = d / "evals" / "evals.json"
    if not ev.is_file():
        f("no evals/evals.json")
    else:
        try:
            data = json.loads(ev.read_text())
        except ValueError as e:
            f(f"evals.json is not valid JSON: {e}")
            data = {}
        cases = data.get("evals", [])
        if data and data.get("skill_name") != d.name:
            w(f"evals.json skill_name '{data.get('skill_name')}' != '{d.name}'")
        if data and len(cases) < 3:
            f(f"{len(cases)} eval cases (need >= 3)")
        ids = [c.get("id") for c in cases]
        if len(set(ids)) != len(ids):
            f("duplicate eval ids")
        repo = next((p for p in [d, *d.parents] if (p / ".git").exists()), d)
        for c in cases:
            cid = c.get("id", "?")
            for k in ("prompt", "expected_output"):
                if not c.get(k):
                    f(f"case {cid}: no {k}")
            a = c.get("assertions") or []
            if not a:
                f(f"case {cid}: no assertions")
            elif len(a) > 6:
                w(f"case {cid}: {len(a)} assertions (2-4 sharp ones grade better)")
            for x in a:
                if re.search(r"\b(good|helpful|appropriate|well[- ]written|high[- ]quality)\b", x, re.I):
                    w(f"case {cid}: vague assertion '{x[:50]}'")
            for fp in c.get("files") or []:
                if not ((d / fp).exists() or (repo / fp).exists()):
                    f(f"case {cid}: file '{fp}' not found (skill- or repo-relative)")

    for x in fails:
        print("FAIL", x)
    for x in warns:
        print("WARN", x)
    print(f"CHECK {d.name} fail={len(fails)} warn={len(warns)} chars={chars} refs={len(refs)} cases={len(cases)}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
