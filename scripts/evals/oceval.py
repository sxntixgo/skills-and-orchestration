#!/usr/bin/env python3
"""oceval — run an opencode skill's eval cases for real, with and without the skill, on the local
model, inside a devcontainer. Writes the same layout as abeval.py, so grading and the report reuse it:

  oceval.py run --skill plugins/orchestration/opencode/skills/opencode-develop --out <dir> [--cases 1,3] [--jobs 2]
  abeval.py grade  --out <dir>        # blind Claude judge, as for the Claude-side skills
  abeval.py report --out <dir>

evals.json for an opencode skill:
  "runner": {"kind": "develop"|"research", "container": "<docker name prefix>", "agent": "implementer"}
  each case: "prompt" (what the judge reads as the case), "task" (the task file, Markdown),
  "assertions", and for develop "fixture" (dir under evals/files: a repo, committed before the run)
  and "test_cmd" (rerun by the harness after the run); for research optional "files" (copied to
  the run's files/ dir).

Isolation: each run has its own XDG config dir (the container's opencode.json + the agent, + the
skill only for new_skill) and its own data dir (fresh session database), and Claude Code
skills/prompts disabled. The no-skill baseline is the agent's own prompt alone: the delta is what
the skill adds. The judge gets the agent's final reply, every tool call in order, and for develop
the diff, RESULT.md and an independent rerun of the test command.
"""
import argparse, concurrent.futures as cf, json, shlex, subprocess, sys, time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
AGENTS = REPO / "plugins/orchestration/opencode/agent"
CONFIGS = ("new_skill", "old_skill")
MSG = {
    "develop": "Implement the attached task. Use the opencode-develop skill; it ends with writing RESULT.md.",
    "research": "Research the attached sub-question with the opencode-research skill. Your final reply must be the findings in that skill's format, nothing else.",
}


def container(prefix):
    names = subprocess.run(["docker", "ps", "--format", "{{.Names}}"], capture_output=True, text=True, check=True).stdout.split()
    hits = [n for n in names if n == prefix or n.startswith(prefix + "-")]
    if len(hits) != 1:
        sys.exit(f"need exactly one running container named {prefix}[-*], found {hits or 'none'}")
    return hits[0]


def dx(ctr, script, timeout=1800, inp=None):
    """bash -lc <script> as vscode in the container."""
    return subprocess.run(["docker", "exec", "-i", "-u", "vscode", ctr, "bash", "-lc", script],
                          input=inp, capture_output=True, text=True, timeout=timeout)


def put(ctr, src: Path, dest: str):
    dx(ctr, f"mkdir -p {shlex.quote(dest)}")
    subprocess.run(["docker", "cp", f"{src}/.", f"{ctr}:{dest}"], check=True, capture_output=True)
    subprocess.run(["docker", "exec", "-u", "root", ctr, "chown", "-R", "vscode:vscode", dest], check=True, capture_output=True)


def events(log):
    out = []
    for line in log.splitlines():
        if line.startswith("{"):
            try:
                out.append(json.loads(line))
            except ValueError:
                pass
    return out


def tail(s, n):
    lines = (s or "").rstrip().splitlines()
    return "\n".join(lines[-n:])


def summarize(ev):
    """final reply, numbered tool calls, token total, step count"""
    types = [e.get("type") for e in ev]
    last = max((i for i, t in enumerate(types) if t == "step_start"), default=None)
    final = "" if last is None else "".join(e["part"].get("text") or "" for e in ev[last:] if e.get("type") == "text")
    calls, tok, steps = [], 0, 0
    for e in ev:
        p = e.get("part") or {}
        if e.get("type") == "step_finish":
            t = p.get("tokens") or {}; steps += 1
            tok += sum(v for k, v in t.items() if k != "total" and isinstance(v, int)) + sum((t.get("cache") or {}).values())
        if e.get("type") != "tool_use":
            continue
        st = p.get("state") or {}; inp = st.get("input") or {}; tool = p.get("tool")
        if tool in ("bash", "shell"):  # opencode 1: bash, metadata.exit; opencode 2: shell, metadata.metadata.exit
            out = st.get("output") or ""
            md = st.get("metadata") or {}
            code = md.get("exit", (md.get("metadata") or {}).get("exit"))
            calls.append(f"shell `{inp.get('command', '')}`" + (f" → exit {code}" if code is not None else "")
                         + ("\n```text\n" + tail(out, 8) + "\n```" if out.strip() else ""))
        else:
            arg = inp.get("filePath") or inp.get("path") or inp.get("pattern") or inp.get("name") or ""
            calls.append(f"{tool} {arg}".strip() + (" [error]" if st.get("status") == "error" else ""))
    return final.strip(), calls, tok, steps


def cmd_run(a):
    skill = (REPO / a.skill).resolve()
    spec = json.loads((skill / "evals" / "evals.json").read_text())
    rn = spec["runner"]; kind = rn["kind"]; agent = rn["agent"]
    ctr = container(a.container or rn["container"])
    only = {int(x) for x in a.cases.split(",")} if a.cases else None
    cases = [c for c in spec["evals"] if not only or c["id"] in only]
    for c in cases:
        if not c.get("assertions"):
            sys.exit(f"case {c['id']} has no assertions")
    out = Path(a.out).resolve(); out.mkdir(parents=True, exist_ok=True)
    tag = f"oceval-{int(time.time())}"
    base = f"/tmp/{tag}"
    model = a.model or rn.get("model", "atlas/qwen3.8-flash-next")
    (out / "meta.json").write_text(json.dumps({
        "skill": spec["skill_name"], "skill_path": str(skill.relative_to(REPO)), "model": model,
        "runner": f"opencode {kind} runs on {model} in the {rn['container']} devcontainer, real tools, blind Claude judge",
        "baseline": "none", "claudemd": False, "evals_file": "",
        "new_rev": subprocess.run(["git", "-C", str(REPO), "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip() + "+worktree",
        "date": time.strftime("%Y-%m-%d"), "cases": [c["id"] for c in cases]}, indent=2) + "\n")

    # one config dir per configuration: container opencode.json + agent (+ skill)
    stage = out / "stage"
    for cfg in CONFIGS:
        d = stage / cfg / "opencode"
        (d / "agent").mkdir(parents=True, exist_ok=True)
        (d / "agent" / f"{agent}.md").write_text((AGENTS / f"{agent}.md").read_text())
        if cfg == "new_skill":
            sd = d / "skills" / skill.name; sd.mkdir(parents=True, exist_ok=True)
            (sd / "SKILL.md").write_text((skill / "SKILL.md").read_text())
        put(ctr, stage / cfg, f"{base}/cfg-{cfg}")
        dx(ctr, f"cp ~/.config/opencode/opencode.json {base}/cfg-{cfg}/opencode/ && "
                f"ln -sfn ~/.config/opencode/node_modules {base}/cfg-{cfg}/opencode/node_modules")

    def one(case, cfg):
        rd = out / "runs" / f"case-{case['id']}" / cfg
        if (rd / "answer.md").exists() and (rd / "timing.json").exists() and not a.force:
            return f"case-{case['id']}/{cfg}: kept"
        rd.mkdir(parents=True, exist_ok=True)
        for f in ("grading.json", "judge-raw.txt"):
            (rd / f).unlink(missing_ok=True)
        cid = case["id"]
        if kind == "develop":
            wt = f"{base}/{cfg}/case-{cid}/wt"; taskf = f"{base}/{cfg}/case-{cid}/task.md"
            put(ctr, skill / "evals" / "files" / case["fixture"], wt)
            # bytecode the tests write is noise, not a change: drop stray copies, exclude it from git status
            dx(ctr, f"cd {wt} && find . -name __pycache__ -type d -prune -exec rm -rf {{}} + ; git init -q -b main && "
                    f"printf '__pycache__/\\n*.pyc\\n' >> .git/info/exclude && git add -A && "
                    f"git -c user.name=eval -c user.email=eval@example.invalid commit -qm fixture")
        else:
            wt = f"/workspaces/research/runs/_{tag}-{cfg}-{cid}"; taskf = f"{wt}/tasks/T{cid}.md"
            dx(ctr, f"mkdir -p {wt}/tasks {wt}/files {wt}/findings")
            for f in case.get("files", []):
                subprocess.run(["docker", "cp", str(skill / f), f"{ctr}:{wt}/files/"], check=True, capture_output=True)
            subprocess.run(["docker", "exec", "-u", "root", ctr, "chown", "-R", "vscode:vscode", wt], check=True, capture_output=True)
        dx(ctr, f"cat > {taskf}", inp=case["task"])
        env = (f"XDG_CONFIG_HOME={base}/cfg-{cfg} XDG_DATA_HOME={base}/data-{cfg}-{cid} "
               "OPENCODE_DISABLE_CLAUDE_CODE=1 OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1")
        t0 = time.time()
        # --standalone: a private server that reads this run's config (opencode 2 otherwise uses a shared
        # background service); opencode 2 has no --dir, it works in the current directory
        r = dx(ctr, f"cd {wt} && {env} timeout {a.timeout_min}m opencode run --standalone --archived --agent {agent} "
                    f"--model {model} --format json --title eval-{cid} {shlex.quote(MSG[kind])} -f {taskf} 2>&1",
               timeout=a.timeout_min * 60 + 120)
        wall = round(time.time() - t0, 1)
        (rd / "log.jsonl").write_text(r.stdout)
        ev = events(r.stdout)
        final, calls, tok, steps = summarize(ev)
        parts = [f"## Final reply\n{final or '(none)'}",
                 "## Tool calls, in order\n" + ("\n".join(f"{i}. {c}" for i, c in enumerate(calls, 1)) or "(none)")]
        if kind == "develop":
            g = dx(ctr, f"cd {wt} && git status --porcelain --untracked-files=all && echo '---DIFF---' && "
                        f"git add -A -N && git diff -- . ':!RESULT.md' | head -c 8000").stdout
            status, _, diff = g.partition("---DIFF---")
            res = dx(ctr, f"cat {wt}/RESULT.md 2>/dev/null || echo '(no RESULT.md)'").stdout
            rr = dx(ctr, f"cd {wt} && timeout 300 {case['test_cmd']} 2>&1; echo \"EXIT=$?\"")
            parts += [f"## Files changed vs the fixture (git status)\n```text\n{status.strip() or '(none)'}\n```",
                      f"## Diff (RESULT.md excluded)\n```diff\n{diff.strip()}\n```",
                      f"## RESULT.md\n{res.strip()}",
                      f"## Independent rerun of `{case['test_cmd']}` by the eval harness after the run\n```text\n{tail(rr.stdout, 15)}\n```"]
        (rd / "answer.md").write_text("\n\n".join(parts) + "\n")
        (rd / "timing.json").write_text(json.dumps({
            "duration_ms": int(wall * 1000), "num_turns": steps, "tool_calls": len(calls),
            "exit": r.returncode, "tokens": {"total": tok}, "cost_usd": None,
            **({"is_error": True} if not ev else {})}, indent=2) + "\n")
        return f"case-{cid}/{cfg}: exit {r.returncode}, {steps} steps, {len(calls)} tool calls, {tok} tokens, {wall}s"

    jobs = [(c, cfg) for c in cases for cfg in CONFIGS]
    try:
        with cf.ThreadPoolExecutor(a.jobs) as ex:
            for line in ex.map(lambda j: one(*j), jobs):
                print(line, flush=True)
    finally:
        dx(ctr, f"rm -rf {base} /workspaces/research/runs/_{tag}-* 2>/dev/null; true")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sp = ap.add_subparsers(dest="cmd", required=True)
    r = sp.add_parser("run"); r.add_argument("--skill", required=True); r.add_argument("--out", required=True)
    r.add_argument("--cases", default=""); r.add_argument("--jobs", type=int, default=2, help="the model server serves 2 at once")
    r.add_argument("--container", default="", help="docker name prefix; default: evals.json runner.container")
    r.add_argument("--model", default=""); r.add_argument("--timeout-min", type=int, default=20)
    r.add_argument("--force", action="store_true", help="rerun cases that already have an answer")
    a = ap.parse_args()
    {"run": cmd_run}[a.cmd](a)


if __name__ == "__main__":
    main()
