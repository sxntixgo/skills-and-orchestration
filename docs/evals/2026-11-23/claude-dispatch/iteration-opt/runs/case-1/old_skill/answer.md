T1 would be dispatched to opencode in the background. Below are the steps I'd take, in order.

**Assumptions:** the repo is `/workspaces/app`. `.orchestra/2026-11-21-export/tasks/T1.task.md` exists with `depends_on: []` and `attempt: 1`. `board.md` shows no task currently `dispatched`. `config.json` is missing, so the defaults apply: `concurrency: 2`, `base_branch: main`, `task_timeout_min: 30`.

**1. Check the preconditions** (read-only):
```bash
cd /workspaces/app
test -f .orchestra/2026-11-21-export/tasks/T1.task.md
sed -n '1,/^---$/{p}' .orchestra/2026-11-21-export/tasks/T1.task.md | head -8   # frontmatter: depends_on
grep -A3 '^## Files' .orchestra/2026-11-21-export/tasks/T1.task.md             # files T1 owns
grep -i 'dispatched' .orchestra/2026-11-21-export/board.md                      # overlap with running tasks
```
- The file exists, `depends_on` is empty, and no dispatched task owns T1's files, so T1 can go. If `depends_on` listed tasks that aren't merged into `main`, or another dispatched task owned T1's files, I would stop and say why.

**2. Start the run** (Bash with `run_in_background: true`):
```bash
bash plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh 2026-11-21-export T1
```
This creates `.worktrees/2026-11-21-export/T1` on branch `orchestra/2026-11-21-export/T1` and logs to `.orchestra/2026-11-21-export/logs/T1.1.jsonl`.

**3. Update `board.md`:**
- Set T1's row to `dispatched (attempt 1)`, started 2026-11-23 HH:MM.
- Log line: `2026-11-23 HH:MM T1 dispatched to opencode (attempt 1), log logs/T1.1.jsonl`

**4. While it runs:** I won't poll or touch the worktree. I'll do other run work, such as writing the next ready task. The notification arrives when the command exits.

**5. On exit:** I'd read the last line, `DISPATCH T1 exit=<rc> result=<yes|no> log=<path>`, then log the outcome in `board.md` and act on it:

| Result | Next step |
|---|---|
| `exit=0 result=yes` | `claude-review-merge` |
| `exit=0 result=no` | Check `tail -50` of the log, then send it back once with `--continue` and the note "write RESULT.md" |
| `exit=3` | Wait for a free slot, then retry |
| `exit=4` | Pause dispatching, check atlas/Gatus, tell you |
| `exit=124` | Read the log tail, then split the task or take it over |
| `exit=125` | Check atlas (`lms ps`, LM Studio log), then redispatch once or pause and tell you |
| anything else | Read `tail -50 <log>`, then fix the setup or take it over |

**Reply to you:**
> T1 has started in the background on branch `orchestra/2026-11-21-export/T1` (attempt 1, log `.orchestra/2026-11-21-export/logs/T1.1.jsonl`). I'll review it when it finishes.