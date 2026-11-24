**What I'd do, in order:**

1. **TodoWrite:** Capture intent → Draft SKILL.md → Write evals.json + fixtures → Confirm with user → Spawn with-skill and baseline runs → Draft assertions while they run → Record timing.json for each run → Grade, aggregate, analyst pass → Run generate_review.py → Iterate on feedback → Offer description optimization → skill-reviewer.

2. **Capture intent.** The request answers what the skill does, when it fires and what it outputs. I'll assume the rest and ask about it in my reply:
   - "Uncommitted" means staged changes, unstaged changes and untracked files.
   - The output is 3–6 summary bullets plus a separate "Risky" section.
   - The skill only reads. It never edits, stages or commits.

3. **Placement.** Under the house rules this is a general-purpose skill, so it goes in the main plugin at `skills/diff-summary/`. The directory name and the `name` field are both `diff-summary`.

4. **Write `skills/diff-summary/SKILL.md`:**

```markdown
---
name: diff-summary
description: Summarizes uncommitted git changes (staged, unstaged and untracked) into a few bullets and flags risky changes such as secrets, deleted tests, migrations, auth or dependency edits. Use when the user asks for a summary or recap of their changes, "what did I change", or a pre-commit overview, even if they don't say "diff".
---

# Diff Summary

**Does:** read the working tree and summarize it, then flag risks. **Does NOT:** edit, stage, commit, fix issues, or review code style. If the user wants fixes, say so and stop.

## Steps
1. Gather all three sources. Untracked files are easy to miss, and they're often where secrets end up.
   - `git status --porcelain`
   - `git diff --stat HEAD` (or `git diff --cached --stat` plus `git diff --stat` if there's no HEAD yet)
   - `git diff HEAD` for content. If it runs over ~1500 lines, read per file, starting with the riskiest paths (see table).
   - New untracked files: read the head of each one.
2. Group the changes by intent (feature, fix, refactor, config), not by file. 3–6 bullets.
3. Check every file against the risk table. Only flag what you saw in the diff. Don't speculate.
4. Write the output using the template below.

## Risk table
| Flag | Look for |
|---|---|
| Secret | keys/tokens/passwords, `.env`, `*.pem`, high-entropy strings |
| Tests removed/weakened | deleted test files, `skip`/`xit`, loosened asserts |
| Data | migrations, schema changes, `DROP`/`DELETE`, data backfills |
| Security surface | auth, permissions, CORS, crypto, input validation |
| Dependencies/build | lockfiles, version bumps, CI config, Dockerfile |
| Broad blast radius | public API signatures, deleted exports, mass renames |
| Debug leftovers | `console.log`/`print`/`debugger`, commented-out code, TODO hacks |

## Output
**Summary** (N files, +A/−D)
- <intent-level bullet>

**Risky** (or "None found")
- ⚠ <flag>: `path:line` (one-line reason)

## Red flags
- Summarizing only `git diff` and missing staged or untracked changes → run step 1 in full.
- Listing every file → group by intent.
- Starting to fix things → report only, offer to fix.
- No repo, or a clean tree → say so in one line and stop.
```

5. **Write `skills/diff-summary/evals/evals.json`.** It has prompts only. Assertions come later. The fixture `evals/files/setup_repo.sh` builds a repo in a temp dir for each case. I'm assuming that layout.

```json
{
  "skill_name": "diff-summary",
  "evals": [
    {"id": 1, "prompt": "can you give me a quick summary of my changes before I commit?",
     "expected_output": "Bullets cover the staged, unstaged and untracked changes (a new src/payments/refund.ts, an edited api route and a staged README change). Flags the untracked .env.local that contains an API key.",
     "files": ["evals/files/setup_repo.sh"]},
    {"id": 2, "prompt": "what did I change today? I touched a bunch of stuff in the auth module and I think I deleted a test",
     "expected_output": "Groups the changes by intent. Flags the deleted tests/auth.test.ts and the CORS change to '*'. No edits made.",
     "files": ["evals/files/setup_repo.sh"]},
    {"id": 3, "prompt": "summarize my diff",
     "expected_output": "The fixture tree is clean, so it reports nothing to summarize in one line and invents nothing.",
     "files": ["evals/files/setup_repo.sh"]}
  ]
}
```

6. **Gate.** Stop and send the reply below. Nothing gets spawned until the user confirms.

7. **After the user confirms.** For each eval, spawn two Agent subagents in a single turn, all on `claude-opus-5-5` so they match this session:
   - **With skill:** "Execute this task: Skill path: skills/diff-summary. Task: \<prompt\>. Input files: run evals/files/setup_repo.sh in a fresh temp dir first. Save outputs to .claude-skills-work/evals/diff-summary/iteration-1/\<eval-name\>/with_skill/outputs/ (the final summary as summary.md)."
   - **Baseline:** the same prompt with no skill path, saving to `without_skill/outputs/`.
   - Write `eval_metadata.json` in each eval directory. The names are `precommit-untracked-secret`, `auth-deleted-test` and `clean-tree`.

8. **While the runs go.** Draft assertions and add them to `evals.json` and `eval_metadata.json`. Examples: "mentions the untracked .env.local", "flags the API key as a secret", "has 6 or fewer summary bullets", "flags the deleted test file", "made no git write commands", "clean tree gives a one-line reply". Then explain them to the user. Save `timing.json` as each notification arrives.

9. **When all runs finish.**
   - Grade against `agents/grader.md`. Check the transcript for git write commands with a script.
   - Run `python -m scripts.aggregate_benchmark … --skill-name diff-summary`.
   - Do the analyst pass. Baselines probably pass the "has bullets" assertion too, so it doesn't tell the configurations apart. The untracked-file and secret checks should be the ones that do.
   - Run `generate_review.py` with `--benchmark`, then iterate on feedback.

10. **When the user is happy.** Offer to optimize the description with 20 trigger queries. Near-misses should not trigger, for example "write a commit message", "review this PR for bugs", "summarize the last 5 commits" and "explain this diff from upstream". Then run `skill-authoring:skill-reviewer` and tick the box in `plan.md`.

---

**Reply to user:**

I've drafted `skills/diff-summary/` with a SKILL.md and 3 test cases. It covers staged, unstaged and untracked changes, groups them into 3–6 bullets by intent, and flags risks from a fixed table: secrets, removed tests, migrations, security surface, dependencies, API breaks and debug leftovers. It only reports and never edits or commits.

Three questions before I run the evals (each test runs once with the skill and once without):
1. Should "uncommitted" also include untracked files? I assumed yes, since that's where `.env` files and secrets tend to end up.
2. Do you want any project-specific risks flagged, such as particular paths or file types?
3. Do these tests look right?
   - A pre-commit summary where the risk is an untracked secret.
   - Auth changes plus a deleted test.
   - A clean tree.

   Anything you'd add, like a huge diff or a repo with no commits yet?