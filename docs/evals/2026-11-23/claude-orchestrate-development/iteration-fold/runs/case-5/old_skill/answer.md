**Neither one yet.** A task is handed over to Claude only after `max_rejections` rejections, and the default is 3. T2 has 1 and T5 has 2, so both go back to opencode with the review notes (`--continue`).

What I'd do:
1. Read `.orchestra/config.json` and `board.md` in the run directory. I'm assuming `max_rejections` is still 3 and nothing else is on the board, since I can't see either file.
2. Send T2 back to opencode as attempt 2 and T5 as attempt 3, using `claude-dispatch` with the review notes. Two at a time is within the default `concurrency` of 2, as long as T2 and T5 don't change the same files. If they do, T5 runs first and T2 waits for it.
3. Update `board.md`: set both to `dispatched` and add one log line, e.g. `HH:MM T2 re-dispatched (attempt 2), T5 re-dispatched (attempt 3)`.
4. When each run finishes, a subagent reviews it (`review_model`, or opus if the task is marked `review: opus`):
   - **T5:** if it's rejected a third time, Claude takes it over. The model is one step above the last one tried, which is opus if sonnet was used. The prompt gets the full task, all the review notes, and the TDD/YAGNI/DRY rules. The result is reviewed again and marked `taken-over (<model>)`.
   - **T2:** if it's rejected again, it goes back to opencode for attempt 3.

One exception: if a review subagent replies `TAKEOVER <id> <reason>` (for example, the notes show a design flaw opencode can't fix), I'd take that task over straight away without waiting for the third rejection. T5 is the more likely of the two to need this.