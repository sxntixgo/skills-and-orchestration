# claude-review-merge — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 4/4 |
| 2 | 5/5 | 4/5 |
| 3 | 3/3 | 3/3 |
| 4 | 4/4 | 4/4 |
| 5 | 4/4 | 4/4 |
| 6 | 5/5 | 5/5 |
| 7 | 4/5 | 2/5 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.971 | 29/30 | 28715.286 | 21.986 |
| baseline | 0.886 | 26/30 | 26205.0 | 26.034 |
| **delta** | **+0.085** | | +2510.286 | -4.048 |

Failed assertions:

- case 2 baseline: Notes use the form file:line — problem — fix — Only the first note has file:line ("SettingsForm.test.tsx:41"). Others lack line numbers: "SettingsForm.tsx (submit handler)", "web/src/App.tsx —", "RESULT.md —".
- case 7 new: Reads only the diff (skipping lockfiles/generated files) — It runs a full "git -C .worktrees/2026-11-23-csv/T2 diff" and cats every untracked file except RESULT.md. Nothing excludes lockfiles or generated files.
- case 7 baseline: Uses review-check.sh rather than rerunning tests by hand — No mention of review-check.sh; it reruns tests by hand: "uv run pytest tests/test_csv_writer.py -q      # the task's exact command" and "uv run pytest -q"
- case 7 baseline: Reads only the diff (skipping lockfiles/generated files) — Runs a plain "git -C $W diff" and also cats the task and result files. It never excludes lockfiles or generated files from the diff it reads; deleting caches is a scope step, not diff filtering.
- case 7 baseline: Final reply is exactly one verdict line (MERGED/REJECTED/TAKEOVER) — The reply is a multi-bullet summary starting "T2 is accepted and merged into `main`...", followed by Tests/Scope/Cleanup/Nit/Not pushed bullets. There is no single MERGED verdict line.
