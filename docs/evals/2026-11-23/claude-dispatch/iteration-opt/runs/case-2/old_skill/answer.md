exit=4 means the dispatcher couldn't reach the local LLM on atlas, so T2 never started. That's an infrastructure problem, not a task problem: I wouldn't retry T2 or rewrite it. I'd stop dispatching and tell you.

**Steps, in order**

1. **Confirm it from the log tail.** I'd read only the end, never the whole log:
   ```bash
   tail -20 .orchestra/<run>/logs/T2.<n>.jsonl 2>/dev/null
   ```
   I assume it's empty or shows a connection error, since opencode never got a model response.

2. **Check atlas status in Gatus.** I'd look at the atlas/LLM endpoint in Gatus (atlas/ops) to see whether it's down, and since when. I'd also send one direct check to the model API. I'm assuming LM Studio's OpenAI-compatible endpoint; the real host and port would come from the dispatch script's config:
   ```bash
   curl -s --max-time 5 http://atlas:1234/v1/models | head -c 500
   ```
   I wouldn't try to restart atlas or LM Studio myself. That's outside the devcontainer and outside the orchestrator's role.

3. **Pause dispatching.** I'd start no new opencode runs, including no retry of T2. Any task already dispatched keeps running untouched. I wouldn't kill it or edit its worktree, and when it exits I'd handle it under its own exit code (it will probably end with 4, 125 or 124). In the meantime I can still do work that doesn't need the LLM, like writing upcoming task specs or reviewing results that are already in.

4. **Update `board.md`.**
   - Task table: T2 changes from `dispatched (attempt n)` to `blocked: llm unreachable`, keeping the attempt number. A failed start doesn't count as a rejection.
   - Log line:
     ```
     - 2026-11-23 HH:MM T2 attempt n: dispatch exit=4 (llm unreachable), no result. Gatus: <atlas status>. Dispatching paused; waiting on user.
     ```

5. **Reply to you:**

   > T2 didn't run: dispatch.sh exited 4 because opencode couldn't reach the model on atlas. Gatus shows <atlas status / since when>, and a direct `/v1/models` check <failed / timed out>. I've paused all dispatching and marked T2 blocked in `board.md`. <T1 is still running and I'm leaving it alone / nothing else is running.> In the meantime I'm only writing specs and doing reviews.
   >
   > Can you check atlas (LM Studio / llama.cpp up, model loaded, reachable)? Once it's back I'll re-run `dispatch.sh <run> T2` as the same attempt n, in the background. Or, if you'd rather not wait, I can take T2 over with a Claude subagent.

When you confirm atlas is back, I'd start `bash <skill-dir>/scripts/dispatch.sh <run> T2` in the background. It's a fresh start, not `--continue`, because no session ever began. Then I'd set T2 back to `dispatched` in `board.md` with the new start time.