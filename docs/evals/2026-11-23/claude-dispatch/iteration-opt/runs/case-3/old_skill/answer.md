T3 goes back to opencode with `--continue`, so it reuses the same worktree and session. The exact steps are below.

**Assumptions:** `.orchestra/` holds one active run, `2026-11-21-csv-export`. When review sent T3 back, it already raised `attempt` to 2 in `tasks/T3.task.md` and filled in `## Notes from review`. `config.json` uses the defaults (`concurrency: 2`, `max_rejections: 3`). T3's worktree `.worktrees/2026-11-21-csv-export/T3` and `logs/T3.session` both exist from attempt 1.

**1. Preconditions** (read-only checks):
```bash
cd /workspaces/<repo>
ls .orchestra/                                   # → the run name
grep -nE '^(attempt|depends_on):' .orchestra/2026-11-21-csv-export/tasks/T3.task.md
grep -n -A8 '^## Notes from review' .orchestra/2026-11-21-csv-export/tasks/T3.task.md
test -d .worktrees/2026-11-21-csv-export/T3 && test -s .orchestra/2026-11-21-csv-export/logs/T3.session
git branch --merged main | grep -F 'orchestra/2026-11-21-csv-export/T1'   # depends_on [T1] merged
```
Then I check `board.md`:
- T3 has fewer than `max_rejections` (3) rejections. If it has reached 3, I don't dispatch; it goes to a Claude takeover through `claude-review-merge`.
- No task still marked `dispatched` owns any of T3's files.

If the review notes are missing or `attempt` wasn't raised, I stop and tell you: re-running would send opencode a message pointing at notes that aren't in the task file.

**2. Dispatch in the background** (Bash, `run_in_background: true`):
```bash
bash plugins/orchestration/skills/claude-dispatch/scripts/dispatch.sh 2026-11-21-csv-export T3 --continue
```
I don't open a new worktree. The script deletes the old `RESULT.md`, resumes session `T3.session` with the message "The task file was updated after review… rewrite RESULT.md", and logs to `logs/T3.2.jsonl`.

**3. Log to `board.md`:**
- Task table row: `T3 | dispatched (attempt 2) | 2026-11-23 <HH:MM>`
- Log: `<HH:MM> T3 sent back after review → dispatched --continue (attempt 2), log logs/T3.2.jsonl`

**4. While it runs:** I do other run work, such as reviewing another result or writing the next spec. I don't poll and don't touch T3's worktree.

**5. When it exits, I read the last line** `DISPATCH T3 exit=<rc> result=<yes|no> log=<path>`:
- `exit=0 result=yes` → `claude-review-merge` on T3.
- `exit=0 result=no` → I check `tail -50` of the log, then send it back once more with "write RESULT.md". This counts as a rejection.
- `exit=3` → no free slot. I wait for a running task to finish, then retry.
- `exit=4` → the LLM endpoint is unreachable. I check atlas in Gatus, pause dispatching and tell you.
- `exit=124` → it timed out. I read the log tail, then split the task or take it over.
- `exit=125` → it stalled. I check atlas (`lms ps`, the LM Studio log). If atlas is fine I redispatch once; if not, I pause and tell you.
- Any other exit → I run `tail -50` on the log and fix the setup or take the task over.

Whatever happens, I add the outcome as a line in `board.md`.

**Reply to you:**
> T3 re-dispatched (attempt 2, `--continue`, same worktree and session) with the review notes. I'll send it to review when it finishes.