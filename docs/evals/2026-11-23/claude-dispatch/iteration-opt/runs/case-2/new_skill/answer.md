Exit 4 means opencode couldn't reach the model server (the LLM endpoint). The task itself isn't at fault. I'd pause all dispatching and wouldn't retry.

1. **Stop dispatching.** I wouldn't start or redispatch any task, including T2, and I wouldn't retry in a loop. Runs that are already going are left alone; their exits come in as usual.
2. **Check the server once** (assuming the endpoint is set in the opencode config as an OpenAI-compatible local server reached from the devcontainer):
   ```bash
   curl -sS -m 5 http://host.docker.internal:1234/v1/models; echo "rc=$?"
   ```
   I'd also check the ops status if the project has a status note or health script. I wouldn't open `dispatch.sh` or read the whole log. At most I'd run `tail -5 <log>` to see the connection error.
3. **Log it in `board.md`:**
   ```
   | T2 | blocked | attempt 1 | DISPATCH exit=4 result=no — model server unreachable; dispatching paused (2026-11-23 HH:MM) |
   ## Run status: PAUSED — LLM endpoint unreachable, awaiting user
   ```
   T2 stays on attempt 1. It never really ran, so this isn't a send-back and doesn't count as a failed attempt.
4. **Keep working on things that don't need the model**, such as reviewing or merging results that have already finished and writing upcoming tasks.

**Reply to user:**
> T2 didn't run: dispatch.sh exited with code 4, which means opencode couldn't reach the model server at `<endpoint>`. `curl` result: `<connection refused / timeout>`. I've paused all dispatching and won't retry automatically. Please check that the model server is up and reachable from the devcontainer, then tell me. Once it's back, I'll redispatch T2 as a first attempt (no `--continue`). Its worktree is reused if it exists; if not, a new one is created. Then the rest of the queue continues.