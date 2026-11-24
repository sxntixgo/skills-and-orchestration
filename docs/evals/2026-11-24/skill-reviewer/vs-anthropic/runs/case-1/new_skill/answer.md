**What I'd do, in order:**

1. TodoWrite: `Stage A — rubric`, `Stage B — baseline evals (gated)`, `Stage C — verdict`.
2. Read in one parallel batch: `skills/debugging/SKILL.md`, `skills/debugging/references/*.md`, `skills/debugging/evals/evals.json`, and list `skills/debugging/scripts/`. I'm assuming the case files match what's on disk: only `SKILL.md` (53 lines) exists. There is no `references/`, no `scripts/` and **no `evals/evals.json`**.
3. Write `./.claude-skills-work/debugging/review/rubric.md`:

```markdown
# debugging — rubric review (Stage A)
Target: skills/debugging/ (SKILL.md only; no references/, scripts/, evals/)

## 🔴 Must fix
- R8 Eval-backed: evals/evals.json missing. Stage B can't run. Need ≥3 realistic cases
  (id, prompt, expected_output, files, objective assertions), with fixtures in evals/files/.

## 🟡 Should fix
- R6 Checkpointed (SKILL.md:16): one notes.md path but no per-step output and no resume rule.
  Say what each step appends (repro command + output, isolation result, hypothesis, verification
  evidence, diff, after-output) and "on resume, read notes.md and continue at the first unfinished step".
- R7 Guardrails (SKILL.md:17): the ⛔ on Reproduce is undefined. Make the gate explicit.
- R7 Guardrails (SKILL.md:20): "Can't reproduce → gather logs" has no exit. Add STOP: after N
  failed attempts, report what was tried and ask the user. Don't fix blind.
- R7 Guardrails (SKILL.md:32): no STOP before a fix that grows scope (design change, API change,
  touches many files). Add a gate: present the verified cause and the proposed fix, then ask.

## 🟢 Consider
- House principle (SKILL.md:24-28): the "usual suspects" list restates knowledge the model already
  has (cf. security-review 0.00 lift). Keep it only if evals show it helps. Otherwise cut it.
- R7 (SKILL.md:13-14): "unless that's a stated, deliberate choice" — say who states it (the user).
- R1: "test failure" may overlap with software-development's testing triggers. Check that both
  descriptions don't fire on "my test is failing".

## OK
R1 name/description, R2 self-contained, R3 lean (53 lines), R4 single context, R5 imperative.
```

4. Stage B can't be gated with real numbers because there are no cases. I start nothing.

---

**Final reply to the user:**

**debugging: ITERATE.** There's one blocker: `skills/debugging/evals/evals.json` doesn't exist, so the baseline eval can't run. The full findings are in `.claude-skills-work/debugging/review/rubric.md`.

**🔴 Must fix**
- **Rule 8:** there's no `evals/evals.json`. Add at least 3 realistic cases, each with `id`, `prompt`, `expected_output`, `files` and objective assertions. Good candidates:
  - an off-by-one boundary bug with a failing test
  - an unawaited async value
  - a flaky test caused by shared state or the clock
  - a "just add a null check" request, to test that the skill refuses to patch the symptom

**🟡 Should fix**
- **Rule 6** (`SKILL.md:16`): `notes.md` is named, but no step says what to write there, and there's no rule for resuming.
- **Rule 7** (`SKILL.md:17`): the ⛔ on Reproduce isn't defined. Say what it gates.
- **Rule 7** (`SKILL.md:20`): "can't reproduce" has no stop. After a bounded number of attempts, report what was tried and ask the user.
- **Rule 7** (`SKILL.md:32`): there's no gate before a fix that grows scope. Show the verified cause and the proposed fix, then ask before making it.

**🟢 Consider**
- `SKILL.md:24-28`: the "usual suspects" list repeats what the model already knows. Keep it only if the evals show lift.
- `SKILL.md:13-14`: "stated, deliberate choice" should say the user makes that choice.
- "Test failure" in the description may also trigger `software-development`. Check that the two skills don't both fire on it.

Rules 1–5 pass: frontmatter, self-contained, lean at 53 lines, one context window, imperative.

**Stage B ⛔:** I can't give the run count or cost yet because there are 0 cases. With N cases it takes N × 2 runs plus N × 2 judge calls, each about $0.10 and 20–40 s. The baseline is `none` because this is a new skill. For example, 4 cases = 16 calls ≈ $1.60.

Add the eval cases yourself, or use `skill-creator` to draft them. Once they exist, I'll give the exact count and cost and ask you to approve the eval run. Until then the verdict rests on the rubric only.