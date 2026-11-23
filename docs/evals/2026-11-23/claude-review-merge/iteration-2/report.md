# claude-review-merge — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 4/4 | 3/4 |
| 2 | 5/5 | 5/5 |
| 3 | 3/3 | 3/3 |
| 4 | 4/4 | 4/4 |
| 5 | 4/4 | 4/4 |
| 6 | 5/5 | 5/5 |
| 7 | 5/5 | 2/5 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 1.0 | 30/30 | 14535.143 | 14.961 |
| baseline | 0.879 | 26/30 | 24143.571 | 22.286 |
| **delta** | **+0.121** | | -9608.428 | -7.325 |

Failed assertions:

- case 1 baseline: Runs the mechanical checks (scope + the task's test command + suite), via review-check.sh where available — Scope check, task test command and full suite all run by hand ("uv run pytest tests/test_csv_export.py -q", "uv run pytest -q"), but review-check.sh is never mentioned, checked for or used.
- case 7 baseline: Uses review-check.sh rather than rerunning tests by hand — No review-check.sh; reruns by hand: "uv run pytest tests/test_csv_import.py -q", "uv run pytest -q", "uv run ruff check ."
- case 7 baseline: Reads only the diff (skipping lockfiles/generated files) — Reads whole files besides the diff: "cat .worktrees/2026-11-23-csv/T2/tests/test_csv_import.py". No mention of skipping lockfiles or generated files.
- case 7 baseline: Final reply is exactly one verdict line (MERGED/REJECTED/TAKEOVER) — The reply is a multi-line paragraph plus a bullet list: "T2 is rejected and back with the implementer as attempt 2... The reasons:" It has no single REJECTED verdict line.
