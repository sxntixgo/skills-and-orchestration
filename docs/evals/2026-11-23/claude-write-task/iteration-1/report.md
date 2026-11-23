# claude-write-task — eval 2026-11-23

new = working tree (b76d2b9+worktree), baseline = skill at HEAD; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 6/6 | 6/6 |
| 2 | 2/3 | 3/3 |
| 3 | 4/4 | 4/4 |
| 4 | 5/5 | 5/5 |
| 5 | 4/4 | 2/4 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.933 | 21/22 | 23849.8 | 26.643 |
| baseline | 0.9 | 20/22 | 23543.0 | 29.311 |
| **delta** | **+0.033** | | +306.8 | -2.668 |

Failed assertions:

- case 2 new: Uses no 'improve/clean up' wording in a spec — The spec's frontmatter has "run: 2026-11-23-books-cleanup", and the path is ".orchestra/2026-11-23-books-cleanup/tasks/T1.task.md". The steps are concrete, but 'cleanup' wording still appears in the spec.
- case 5 baseline: It does not restate the plan's columns and all 4 test cases verbatim — Steps restate the columns "header row `id,created_at,customer_email,total`" and list all 4 tests: happy_path, empty_range, start_after_end, escapes_commas_and_quotes.
- case 5 baseline: The reply to the orchestrator is the task path only (or BLOCKED: …) — The reply is three paragraphs. It explains the api/main.py addition, the check command and the T1 dependency, so it is not just the path.
