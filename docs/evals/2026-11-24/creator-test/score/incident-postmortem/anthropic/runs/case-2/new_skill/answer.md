The postmortem is drafted, but the notes are too thin to pin down a root cause. The trigger is clear: an index rebuild job overloaded the DB behind search-api. Why the job could do that is not in the notes, so the root cause is marked **undetermined** and I'd ask you the questions at the end.

**What I'd do, in order**

1. **TodoWrite**, one item per step:
   1. Save the notes.
   2. Build the timeline.
   3. Extract the facts.
   4. Write `postmortem.md`.
   5. Run the self-check and reply.
2. **Write the work dir** `./.claude-skills-work/incident-postmortem/2026-11-20-search-api-latency/`. I'm assuming it doesn't exist yet, so this is a fresh start.
   - `notes.md`: a verbatim copy of `case-files/2/incident-notes-thin.md`.
   - `timeline.md`: the export header says UTC, so no zone assumption is needed.
     ```markdown
     Assumptions: none (export header states UTC)
     | Time (UTC) | Event | Source |
     | 2026-11-20 09:10 UTC | Index rebuild job starts (reported later) | L4 |
     | 2026-11-20 09:15 UTC | Alert: search-api p95 latency > 4s | L3 |
     | 2026-11-20 09:17 UTC | On-call links latency to rebuild job load on DB | L4 |
     | 2026-11-20 09:31 UTC | Rebuild paused; latency recovering | L5 |
     | 2026-11-20 09:40 UTC | Latency back to normal | L6 |
     Durations: trigger→detect 5m; detect→mitigate 16m; mitigate→resolve 9m;
     alert→resolve 25m; trigger→resolve 30m. When user impact began: unknown.
     ```
   - `facts.md`:
     ```markdown
     ## Impact
     - p95 latency > 4s (alert threshold; actual peak Unknown) — L3
     - Duration: 09:15–09:40 UTC = 25m from alert (09:40−09:15); 30m from job start 09:10 — L3,L4,L6
     - Requests/users affected, error rate, SLO burn: Unknown — measure from search-api metrics
     - Severity: Unknown — not in notes
     ## Trigger
     - Index rebuild job (started 09:10) put heavy load on the DB used by search-api — L4
     ## Root cause
     - Undetermined. Notes don't say why the job could saturate the shared DB
       (no throttling? wrong schedule? new data volume? no isolation?).
     ## Contributing factors (candidates, unconfirmed)
     - The alert fired on latency, not on DB load or the job, so the cause was found by hand — L3–L4
     - Mitigation was a manual pause, 14m after diagnosis; no info on a runbook — L4–L5
     ## Action-item candidates
     - Limit how much DB load the rebuild job can generate, or isolate it from serving traffic (prevent)
     - Alert on DB saturation or long-running batch jobs (detect)
     - Runbook entry, or automatic job pause on latency SLO breach (mitigate)
     - Decide whether the paused rebuild should be resumed or completed (follow-up)
     All: Owner TBD, Due TBD
     ```
   - `postmortem.md`: written from the skill's template.
     - **Header:** title "search-api latency degradation (2026-11-20)", Status Draft, Severity Unknown, Authors TBD.
     - **Summary:** On 2026-11-20 an index rebuild job started at 09:10 UTC and loaded the database behind search-api. p95 latency went above 4s, and an alert fired at 09:15 UTC. The on-call engineer linked it to the job at 09:17 and paused the job at 09:31. Latency was back to normal at 09:40 UTC, 25 minutes after the alert. How many users were affected is unknown.
     - **Impact:** the numbers from `facts.md`. Every missing figure is marked Unknown.
     - **Timeline:** the table above, with names replaced by "on-call engineer".
     - **Root cause:** Undetermined, with what's needed to find it (see the questions below).
     - **Contributing factors:** the two candidates, marked unconfirmed.
     - **What went well:** the alert fired within 5m of the job starting. The cause was found 2m after the alert. Pausing the job worked on the first try.
     - **Action items:** the four candidates (prevent / detect / mitigate / follow-up), all with Owner TBD and Due TBD.
     - **Open gaps:** see below.
3. **Self-check:** every Impact number has a source line in `facts.md`. Every time ends in UTC, and the durations match the timeline. Every action item has Owner/Due set to TBD and maps to a cause. No one is named as a cause. Every Unknown and TBD is listed under Open gaps.

**Final reply**

> I drafted `./.claude-skills-work/incident-postmortem/2026-11-20-search-api-latency/postmortem.md`. The incident lasted 25 min from alert (09:15) to recovery (09:40 UTC). An index rebuild job loading the search DB triggered it, and pausing the job fixed it. **Root cause is undetermined** because the notes don't say why the job could overload the DB.
>
> Open gaps (please fill in what you can):
> - **Root cause:** why did the rebuild run at 09:10? Is it scheduled, manual or new? Does it have throttling, or isolation from serving traffic? Did it change recently? (Job owner / search team)
> - **Impact:** actual peak p95, error rate, requests or users affected, SLO burn. (search-api dashboards)
> - **Customer impact start:** did latency degrade before the 09:15 alert?
> - **Severity:** not stated.
> - **Rebuild state:** was the paused job resumed or completed later?
> - **Action items 1–4:** Owner and Due are both TBD.
> - **Authors:** TBD.
>
> Once I have the root-cause answers I'll update the Root cause and Contributing factors sections.