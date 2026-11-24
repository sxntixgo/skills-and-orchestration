#!/usr/bin/env python3
"""abeval — run a skill's eval cases with and without (or old vs new) the skill, grade them blind,
and write benchmark.json + report.md. Python 3.9 stdlib only; runs `claude -p` headless.

  abeval.py run    --skill <path to skill dir> --baseline <git-rev|none> --out <dir> [--model opus] [--jobs 4] [--cases 1,3]
  abeval.py grade  --out <dir> [--model opus] [--jobs 4]
  abeval.py report --out <dir>

Isolation: every run is a fresh `claude -p --safe-mode` (no CLAUDE.md, installed skills/plugins,
hooks or memory), tools limited to Read, cwd = a snapshot of the skill's plugin root with every
evals/ dir removed (so the run can't see expected outputs). The baseline is either no skill
(`none`) or the skill as of a git revision (an edit A/B). Runs are dry runs: the model describes
exactly what it would do; nothing is executed.

Grading: one judge call per run, given only the case prompt, assertions and the answer (not
which configuration produced it). PASS needs quoted evidence.
"""
import argparse, concurrent.futures as cf, json, os, re, shutil, subprocess, sys, tarfile, io, time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CONFIGS = ("new_skill", "old_skill")  # old_skill = baseline (no skill when --baseline none)

RUN_PROMPT = """Skill eval run (dry run).

Setting: you are Claude Code working in a software project. When the task mentions an
orchestration run, you are the orchestrator inside a devcontainer (git repo at /workspaces/<repo>;
you have the Agent tool with a `model` parameter, Bash, and opencode on a local model via a
dispatch script). Nothing in the task exists on disk: do NOT try to run commands or open project
files. Where the task depends on files or state you can't see, assume plausible contents and say
what you assume. Assume plausible contents for files the user names; if the task needs an input
the user neither named nor gave (e.g. a plan for "Phase 3"), treat it as not found.
{tools_line}{skill_line}
Respond to the user's message below as you would in the real session. Write down, in order,
exactly what you would do: commands, files you'd write (with content if under ~40 lines),
subagents you'd spawn (model + prompt), what you'd log, and your final message or reply.
{files_line}
User's message:
\"\"\"{prompt}\"\"\"

Your whole reply is the answer; no preamble."""

SKILL_LINE = """
First read the skill at `{skill_rel}/SKILL.md` (relative to your working directory) and follow it,
including the files it references. Read only files under your working directory.
"""

JUDGE_PROMPT = """You grade one answer from a skill evaluation. Be strict and objective.

Case prompt:
\"\"\"{prompt}\"\"\"

Answer to grade:
\"\"\"{answer}\"\"\"

Assertions (each PASS or FAIL):
{assertions}

Rules: PASS only with concrete evidence in the answer: quote it (max ~25 words). Intent or
vague wording is FAIL. Judge each assertion independently.
Reply with JSON only, no code fence:
{{"assertion_results": [{{"text": "<assertion>", "passed": true|false, "evidence": "<quote or why not>"}}]}}"""


def sh(cmd, **kw):
    return subprocess.run(cmd, check=True, capture_output=True, **kw)


def claude(prompt, cwd, model, tools, allowed=()):
    t0 = time.time()
    extra = ["--allowedTools", *allowed, "--permission-mode", "acceptEdits"] if allowed else ["--permission-mode", "default"]
    p = subprocess.run(
        ["claude", "-p", "--safe-mode", "--model", model, "--output-format", "json",
         "--tools", tools, *extra],
        input=prompt.encode(), cwd=cwd, capture_output=True, timeout=1800)
    wall = int((time.time() - t0) * 1000)
    try:
        j = json.loads(p.stdout.decode())
    except ValueError:
        return {"error": (p.stderr or p.stdout).decode()[-2000:], "wall_ms": wall}
    u = j.get("usage") or {}
    return {
        "result": j.get("result", ""), "is_error": j.get("is_error", False),
        "duration_ms": j.get("duration_ms", wall), "num_turns": j.get("num_turns"),
        "cost_usd": j.get("total_cost_usd"),
        "tokens": {k: u.get(k, 0) for k in ("input_tokens", "output_tokens",
                                             "cache_read_input_tokens", "cache_creation_input_tokens")},
    }


def plugin_root(skill: Path) -> Path:
    # .../<root>/skills/<name> → <root>; works for plugins/<p>/skills/<s> and top-level skills/<s>.
    # evals.json "snapshot_root" (repo-relative, e.g. ".") overrides it for skills that work on
    # the whole repo (skill-authoring).
    try:
        root = json.loads((skill / "evals" / "evals.json").read_text()).get("snapshot_root")
    except (OSError, ValueError):
        root = None
    return (REPO / root).resolve() if root else skill.parent.parent


def snapshot(out: Path, cfg: str, skill: Path, baseline: str, baseline_skill: str = ""):
    """Copy the skill's plugin root (working tree for new_skill, git rev for old_skill) to out/snap/<cfg>."""
    dest = out / "snap" / cfg
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    root_rel = plugin_root(skill).relative_to(REPO)
    skip = shutil.ignore_patterns(".git", ".claude-skills-work", "node_modules", "__pycache__", ".DS_Store")
    if cfg == "old_skill" and baseline_skill:
        # another skill as the baseline (e.g. Anthropic's skill-creator): same tree, the skill's
        # folder replaced by that skill, so the run reads it at the same path
        shutil.copytree(REPO / root_rel, dest / root_rel, ignore=skip, dirs_exist_ok=True)
        target = dest / skill.relative_to(REPO)
        shutil.rmtree(target)
        shutil.copytree(Path(baseline_skill).expanduser(), target, ignore=skip)
    elif cfg == "new_skill" or baseline == "none":
        # no-skill baseline = the same tree without the skill, so both runs see the same repo
        shutil.copytree(REPO / root_rel, dest / root_rel, ignore=skip, dirs_exist_ok=True)
        if cfg == "old_skill":
            shutil.rmtree(dest / skill.relative_to(REPO))
    else:
        data = sh(["git", "-C", str(REPO), "archive", baseline, str(root_rel)]).stdout
        tarfile.open(fileobj=io.BytesIO(data)).extractall(dest)
    for d in sorted(dest.rglob("evals"), reverse=True):
        if d.is_dir():
            shutil.rmtree(d)
    return dest


LIMIT_RE = re.compile(r"hit your .*limit|usage limit|rate limit", re.I)


def good_run(rd: Path) -> bool:
    """A finished run worth keeping: an answer, no error, not a usage-limit message (rerun resumes)."""
    try:
        t = json.loads((rd / "timing.json").read_text())
        ans = (rd / "answer.md").read_text()
    except (OSError, ValueError):
        return False
    return bool(ans.strip()) and not t.get("is_error") and "error" not in t and not LIMIT_RE.search(ans[:300])


def rel(p: Path) -> str:
    """Repo-relative or ~-relative path for records that get committed (no local user paths)."""
    p = p.resolve()
    for base, label in ((REPO, ""), (Path.home(), "~/")):
        try:
            return label + str(p.relative_to(base))
        except ValueError:
            pass
    return str(p)


def load_cases(skill: Path, only, evals_file=""):
    d = json.loads((Path(evals_file) if evals_file else skill / "evals" / "evals.json").read_text())
    cases = [c for c in d["evals"] if not only or c["id"] in only]
    for c in cases:  # optional per-file defaults: "eval_tools" (e.g. "Read,WebSearch,WebFetch"), "eval_allowed" (e.g. ["Bash(python3:*)"])
        c.setdefault("eval_tools", d.get("eval_tools", "Read")); c.setdefault("eval_allowed", d.get("eval_allowed", []))
    for c in cases:
        if not c.get("assertions"):
            sys.exit(f"case {c['id']} has no assertions; add them first")
    return d["skill_name"], cases


def cmd_run(a):
    skill = (REPO / a.skill).resolve()
    out = Path(a.out).resolve()
    only = {int(x) for x in a.cases.split(",")} if a.cases else None
    name, cases = load_cases(skill, only, a.evals)
    skill_rel = skill.relative_to(REPO)
    cfgs = [c for c in CONFIGS if not a.only or c == a.only]
    # A rerun (resume) reuses the existing snapshots: runs may have written files there (real-tool
    # cases) that kept runs still need. --resnapshot copies them fresh (e.g. after editing the skill).
    snaps = {cfg: (out / "snap" / cfg) if (out / "snap" / cfg).is_dir() and not a.resnapshot
             else snapshot(out, cfg, skill, a.baseline, a.baseline_skill) for cfg in cfgs}
    meta = {"skill": name, "skill_path": str(skill_rel), "model": a.model, "claudemd": a.claudemd,
            "evals_file": rel(Path(a.evals).resolve()) if a.evals else "",
            "baseline": f"skill:{rel(Path(a.baseline_skill).expanduser())}" if a.baseline_skill else a.baseline,
            "new_rev": sh(["git", "-C", str(REPO), "rev-parse", "--short", "HEAD"]).stdout.decode().strip() + "+worktree",
            "date": time.strftime("%Y-%m-%d"), "cases": [c["id"] for c in cases]}
    (out / "meta.json").write_text(json.dumps(meta, indent=2) + "\n")

    limited = []

    def one(case, cfg):
        rd = out / "runs" / f"case-{case['id']}" / cfg
        if good_run(rd):
            return f"case-{case['id']}/{cfg}: kept"
        if limited:
            return f"case-{case['id']}/{cfg}: SKIPPED (usage limit)"
        for f in ("answer.md", "timing.json", "grading.json", "judge-raw.txt"):
            (rd / f).unlink(missing_ok=True)
        rd.mkdir(parents=True, exist_ok=True)
        cwd = snaps[cfg]
        has_skill = cfg == "new_skill" or a.baseline != "none" or bool(a.baseline_skill)
        # no skill: the run still works in the repo snapshot, it just isn't pointed at a skill
        files_line = ""
        if case.get("files"):
            fdir = cwd / "case-files" / str(case["id"])
            fdir.mkdir(parents=True, exist_ok=True)
            for f in case["files"]:
                src = skill / f if (skill / f).exists() else REPO / f  # skill-relative or repo-relative
                (shutil.copytree if src.is_dir() else shutil.copy)(src, fdir / Path(f).name)
            files_line = f"\nInput files for this task are in `case-files/{case['id']}/` (you may read them).\n"
        tools_line = "" if case["eval_tools"] == "Read" else (
            f"Exception: you really have these tools: {case['eval_tools']}"
            + (f" (allowed: {', '.join(case['eval_allowed'])}, only inside your working directory)" if case["eval_allowed"] else "")
            + ". Use them for real (e.g. run the tests, search the web) instead of only describing.\n")
        claudemd = ("\nThe project's CLAUDE.md (Claude Code loads it automatically; follow it):\n<claude_md>\n"
                    + (REPO / "CLAUDE.md").read_text() + "\n</claude_md>\n") if a.claudemd else ""
        prompt = claudemd + RUN_PROMPT.format(tools_line=tools_line, skill_line=SKILL_LINE.format(skill_rel=skill_rel) if has_skill else "",
                                   files_line=files_line, prompt=case["prompt"])
        r = claude(prompt, cwd, a.model, case["eval_tools"], case["eval_allowed"])
        (rd / "answer.md").write_text(r.get("result") or r.get("error", ""))
        (rd / "timing.json").write_text(json.dumps({k: v for k, v in r.items() if k != "result"}, indent=2) + "\n")
        if LIMIT_RE.search((r.get("result") or r.get("error", ""))[:300]):
            limited.append(1)
            return f"case-{case['id']}/{cfg}: USAGE LIMIT"
        return f"case-{case['id']}/{cfg}: {'ERROR' if 'error' in r or r.get('is_error') else 'ok'}"

    jobs = [(c, cfg) for c in cases for cfg in cfgs]
    with cf.ThreadPoolExecutor(a.jobs) as ex:
        for line in ex.map(lambda j: one(*j), jobs):
            print(line, flush=True)
    if limited:
        sys.exit("usage limit reached: rerun the same command later; finished runs are kept")


def cmd_grade(a):
    out = Path(a.out).resolve()
    meta = json.loads((out / "meta.json").read_text())
    skill = REPO / meta["skill_path"]
    ef = meta.get("evals_file", "")
    ef = str(Path(ef).expanduser()) if ef.startswith("~/") else (str(REPO / ef) if ef else "")
    _, cases = load_cases(skill, set(meta["cases"]), ef)
    byid = {c["id"]: c for c in cases}

    def one(rd: Path):
        case = byid[int(rd.parent.name.split("-")[1])]
        answer = (rd / "answer.md").read_text()
        prompt = JUDGE_PROMPT.format(prompt=case["prompt"], answer=answer,
                                     assertions="\n".join(f"- {x}" for x in case["assertions"]))
        if (rd / "grading.json").exists() and not a.regrade:
            return f"{rd.parent.name}/{rd.name}: already graded"
        if not good_run(rd):
            return f"{rd.parent.name}/{rd.name}: NOT GRADED (run failed or hit a usage limit; rerun `run`)"
        if limited:
            return f"{rd.parent.name}/{rd.name}: SKIPPED (usage limit)"
        g = None
        for _ in range(3):
            r = claude(prompt, out, a.model, "")
            raw = r.get("result") or r.get("error") or ""
            if LIMIT_RE.search(raw[:300]):
                limited.append(1)
                (rd / "judge-raw.txt").write_text(raw)
                return f"{rd.parent.name}/{rd.name}: USAGE LIMIT"
            txt = raw.strip().strip("`")
            txt = txt[txt.find("{"):txt.rfind("}") + 1]
            try:
                g = json.loads(txt)
                break
            except ValueError:
                (rd / "judge-raw.txt").write_text(raw)  # kept for diagnosis
        if not g:
            return f"{rd}: judge reply unparsable (see judge-raw.txt)"
        (rd / "judge-raw.txt").unlink(missing_ok=True)
        res = g["assertion_results"]
        n = sum(1 for x in res if x["passed"])
        g["summary"] = {"passed": n, "failed": len(res) - n, "total": len(res),
                        "pass_rate": round(n / len(res), 3) if res else 0}
        g["judge_tokens"] = r.get("tokens")
        (rd / "grading.json").write_text(json.dumps(g, indent=2, ensure_ascii=False) + "\n")
        return f"{rd.parent.name}/{rd.name}: {n}/{len(res)}"

    limited = []
    rds = sorted(p for p in (out / "runs").glob("case-*/*") if (p / "answer.md").exists())
    with cf.ThreadPoolExecutor(a.jobs) as ex:
        for line in ex.map(one, rds):
            print(line, flush=True)


def mean(xs):
    xs = [x for x in xs if x is not None]
    return round(sum(xs) / len(xs), 3) if xs else None


def cmd_report(a):
    out = Path(a.out).resolve()
    meta = json.loads((out / "meta.json").read_text())
    rows, summ = [], {}
    present = [c for c in CONFIGS if (out / "runs" / f"case-{meta['cases'][0]}" / c / "grading.json").exists()]
    if len(present) == 1:  # --only run: per-case scores, totals and failures, no delta
        cfg = present[0]; tot = [0, 0]; toks = []; lines = [f"# {meta['skill']} — {cfg} only"]
        for cid in meta["cases"]:
            rd = out / "runs" / f"case-{cid}" / cfg
            g = json.loads((rd / "grading.json").read_text()); t = json.loads((rd / "timing.json").read_text())
            tot[0] += g["summary"]["passed"]; tot[1] += g["summary"]["total"]; toks.append(sum((t.get("tokens") or {}).values()))
            lines.append(f"case {cid}: {g['summary']['passed']}/{g['summary']['total']} turns={t.get('num_turns')} tokens={toks[-1]}")
            lines += [f"  FAIL {x['text']} — {x['evidence']}" for x in g["assertion_results"] if not x["passed"]]
        lines.insert(1, f"total {tot[0]}/{tot[1]}, tokens mean {mean(toks)}")
        (out / "report.md").write_text("\n".join(lines) + "\n"); print("\n".join(lines)); return
    for cfg in CONFIGS:
        pr, tok, loc, tim, cost, p_all, t_all = [], [], [], [], [], 0, 0
        for cid in meta["cases"]:
            rd = out / "runs" / f"case-{cid}" / cfg
            g = json.loads((rd / "grading.json").read_text())["summary"]
            t = json.loads((rd / "timing.json").read_text())
            tk = t.get("tokens") or {}
            total = sum(tk.values()) if tk else None
            pr.append(g["pass_rate"]); tok.append(total); tim.append((t.get("duration_ms") or 0) / 1000)
            loc.append((t.get("local_tokens") or {}).get("total"))  # local model (opencode): free, not cost
            cost.append(t.get("cost_usd")); p_all += g["passed"]; t_all += g["total"]
        summ[cfg] = {"pass_rate": {"mean": mean(pr)}, "assertions": f"{p_all}/{t_all}",
                     "tokens": {"mean": mean(tok)}, "local_tokens_free": {"mean": mean(loc)},
                     "time_seconds": {"mean": mean(tim)},
                     "cost_usd": {"mean": mean(cost)}}
    n, o = summ["new_skill"], summ["old_skill"]
    delta = {k: (round(n[k]["mean"] - o[k]["mean"], 3) if n[k]["mean"] is not None and o[k]["mean"] is not None else None)
             for k in ("pass_rate", "tokens", "time_seconds", "cost_usd")}
    bench = {"meta": meta, "run_summary": {**summ, "delta": delta}}
    (out / "benchmark.json").write_text(json.dumps(bench, indent=2) + "\n")

    b = meta["baseline"]
    base = "no skill" if b == "none" else (f"another skill ({b[6:]})" if b.startswith("skill:") else f"skill at {b}")
    if meta.get("claudemd"):
        base += "; both with the repo's CLAUDE.md"
    lines = [f"# {meta['skill']} — eval {meta['date']}", "",
             f"new = working tree ({meta['new_rev']}), baseline = {base}; model {meta['model']}; "
             + (meta.get("runner") or "`claude -p --safe-mode`, dry runs, blind judge") + ".", "",
             "| Case | new | baseline |", "|---|:---:|:---:|"]
    for cid in meta["cases"]:
        cells = []
        for cfg in CONFIGS:
            g = json.loads((out / "runs" / f"case-{cid}" / cfg / "grading.json").read_text())["summary"]
            cells.append(f"{g['passed']}/{g['total']}")
        lines.append(f"| {cid} | {cells[0]} | {cells[1]} |")
    local = summ["new_skill"]["local_tokens_free"]["mean"] is not None
    # cost = Claude tokens only; for opencode runs that is the estimated downstream read, and the
    # local model's tokens are shown separately as free
    tcol = "Claude tokens ≈ (mean)" if local else "tokens (mean)"
    lines += ["", f"| | pass rate | assertions | {tcol} |" + (" local tokens, free (mean) |" if local else "") + " time s (mean) |",
              "|---|:---:|:---:|:---:|" + (":---:|" if local else "") + ":---:|"]
    for cfg, label in (("new_skill", "new"), ("old_skill", "baseline")):
        s = summ[cfg]
        lines.append(f"| {label} | {s['pass_rate']['mean']} | {s['assertions']} | {s['tokens']['mean']} |"
                     + (f" {s['local_tokens_free']['mean']} |" if local else "") + f" {s['time_seconds']['mean']} |")
    lines.append(f"| **delta** | **{delta['pass_rate']:+}** | | {delta['tokens']:+} |" + (" |" if local else "") + f" {delta['time_seconds']:+} |")
    lines += ["", "Failed assertions:", ""]
    for cid in meta["cases"]:
        for cfg, label in (("new_skill", "new"), ("old_skill", "baseline")):
            g = json.loads((out / "runs" / f"case-{cid}" / cfg / "grading.json").read_text())
            for x in g["assertion_results"]:
                if not x["passed"]:
                    lines.append(f"- case {cid} {label}: {x['text']} — {x['evidence']}")
    (out / "report.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines[:len(meta['cases']) + 12]))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sp = ap.add_subparsers(dest="cmd", required=True)
    r = sp.add_parser("run"); r.add_argument("--skill", required=True); r.add_argument("--baseline", required=True)
    r.add_argument("--out", required=True); r.add_argument("--model", default="opus")
    r.add_argument("--jobs", type=int, default=4); r.add_argument("--cases", default="")
    r.add_argument("--baseline-skill", default="", help="a skill dir used as the baseline instead (implies --baseline none semantics for has_skill)")
    r.add_argument("--resnapshot", action="store_true", help="copy the snapshots fresh instead of reusing them on a rerun")
    r.add_argument("--evals", default="", help="use this evals.json instead of the skill's own (held-out cases)")
    r.add_argument("--claudemd", action="store_true", help="give both configurations the repo's CLAUDE.md, as Claude Code would load it")
    r.add_argument("--only", choices=CONFIGS, help="run one configuration (e.g. new_skill to profile the current skill)")
    g = sp.add_parser("grade"); g.add_argument("--out", required=True); g.add_argument("--model", default="opus")
    g.add_argument("--jobs", type=int, default=4)
    g.add_argument("--regrade", action="store_true", help="grade runs that already have grading.json too")
    p = sp.add_parser("report"); p.add_argument("--out", required=True)
    a = ap.parse_args()
    {"run": cmd_run, "grade": cmd_grade, "report": cmd_report}[a.cmd](a)


if __name__ == "__main__":
    main()
