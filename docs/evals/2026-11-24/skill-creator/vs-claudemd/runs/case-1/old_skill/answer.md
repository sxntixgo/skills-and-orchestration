The skill would be `frugal-skills:diff-summary`. Nothing below has been run or written yet; this is the exact sequence I'd follow.

**One risk up front:** CLAUDE.md warns that a skill only pays for its tokens if it adds a process the model doesn't already follow. Summarizing a diff is something the model already does well. So the skill holds only the parts that are easy to skip: getting the complete uncommitted state (staged, unstaged and untracked files), a fixed checklist of risky changes, and a fixed output shape. The baseline eval decides whether it ships.

## Steps

1. **Invoke `skill-authoring:skill-creator`** (the working agreement requires it) and follow its flow. Assumptions:
   - It goes in the `frugal-skills` plugin under `skills/`, since it reviews software. It doesn't belong in `skill-authoring`.
   - The name is `diff-summary`, and the directory name matches it.

2. **Scaffold:** `plugins/skill-authoring/skills/skill-creator/scripts/new_skill.sh diff-summary skills/` (assumed signature: name plus target directory).

3. **Write `skills/diff-summary/SKILL.md`:**
   ```markdown
   ---
   name: diff-summary
   description: Summarizes the uncommitted git diff (staged, unstaged, untracked) into 3-6 bullets and flags risky changes. Use when the user asks to summarize, recap or describe "my changes", "what I changed", or the working tree before committing.
   ---
   # Diff summary

   **Does:** read-only summary of uncommitted changes + risk flags.
   **Does NOT:** stage, commit, edit or fix code, review committed history/PRs, or do a full code review (that is `code-review`).

   ## Checklist (TodoWrite)
   1. Gather: `git status --porcelain`, `git diff --stat HEAD`, `git ls-files --others --exclude-standard`. No HEAD (fresh repo) → use `git diff --cached` + untracked.
   2. Read: `git diff HEAD -- <file>` per file; read untracked files directly. Over ~1500 changed lines → summarize from `--stat` plus the top 10 files by churn, and say so.
   3. Flag risks with the table below. Cite `file:line` for every flag.
   4. Write `./.claude-skills-work/diff-summary/summary.md`, then print it.

   Empty tree → reply "No uncommitted changes." and STOP.

   ## Risk table
   | Flag | Signal |
   |---|---|
   | Secret | keys/tokens/passwords, `.env*`, `*.pem` added |
   | Auth/permissions | auth checks, roles, CORS, crypto touched or removed |
   | Data | migrations, schema, `DROP`/`DELETE`, serialization formats |
   | Deps/infra | lockfiles, manifests, CI, Dockerfile, IaC |
   | Public API | exported signatures, routes, CLI flags changed/removed |
   | Safety nets | tests deleted/skipped, error handling or validation removed |
   | Bulk | deletions >200 lines, renames, binaries, generated files |

   ## Output
   **Summary** — 3-6 bullets, grouped by intent (not by file).
   **Risky** — `⚠ <flag>: <what> (file:line)`, or "None found."
   **Not covered** — anything skipped (size cap, binaries).

   ## Red flags
   - Summarizing only `git diff` (misses staged/untracked) → always use `HEAD` + untracked.
   - Suggesting fixes or refactors → out of scope; offer `code-review` instead.
   - Vague risk ("might be risky") → name the flag and `file:line`, or drop it.
   - One bullet per file → group by intent.

   Resume: if `summary.md` exists and `git diff --stat HEAD` is unchanged, reuse it.
   ```

4. **Write `skills/diff-summary/evals/evals.json`** with 5 cases. Each fixture is a small setup script that builds a temporary repo in a known dirty state.
   1. `files/feature.sh`: a small feature touching 3 files, plus one untracked new file. Expect 3-6 bullets that include the untracked file, and "None found" for risks.
   2. `files/risky.sh`: `.env` gets an API key, an `if (!user.isAdmin)` check is removed, and a test gets `.skip`. Expect three flags (Secret, Auth, Safety nets), each with `file:line`.
   3. `files/staged_only.sh`: the changes are only staged. Expect them to be reported, not "no changes".
   4. `files/clean.sh`: a clean tree. Expect "No uncommitted changes." and nothing else.
   5. Negative trigger: "review PR #42 for bugs". Expect the skill not to fire.

5. **Update docs:** add the skill to the skills table in `README.md`, add an entry to `plan.md` and tick its box when done, and change the skill count in CLAUDE.md from 8 to 9.

6. **Invoke `skill-authoring:skill-reviewer`** on `skills/diff-summary`. This runs the conventions review plus the baseline comparison: subagent runs with the skill and without it. Results are aggregated to `.claude-skills-work/evals/diff-summary/iteration-1/benchmark.json`.

7. **Gate:** if lift is ≤ about 0.05 for the extra tokens (the `security-review` pattern), stop and recommend dropping the skill or adding the risk table to `code-review`, rather than shipping it.

No commit or push without your go-ahead.

## Reply to you

I'd create `diff-summary` in `skills/`. It fires on requests like "summarize my changes" and only reads; it never stages, commits or fixes anything.

- **Coverage:** it summarizes staged, unstaged and untracked changes in 3-6 bullets grouped by intent.
- **Risk flags:** it checks for secrets, auth changes, data or migration changes, dependency and infra changes, public API changes, removed tests or checks, and bulk changes, and cites `file:line` for each flag.
- **Output:** it writes the result to `.claude-skills-work/diff-summary/summary.md` and prints it.

Five eval cases are in `evals/evals.json`, and `skill-reviewer` runs the baseline comparison. Plain Claude already summarizes diffs well, so if the measured lift is close to zero I'd recommend adding the risk checklist to `code-review` instead of shipping a separate skill. Should I go ahead with that gate?