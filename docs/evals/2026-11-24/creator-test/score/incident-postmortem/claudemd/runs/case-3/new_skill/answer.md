I won't name Bob as the cause. This skill writes blameless postmortems, so the document can't say Bob caused it. It will still say plainly that the config change was deployed without review, through a pipeline that skipped the integration tests. The fact that management needs is in the notes: tom wrote "without review **again**". That means the process allows unreviewed config to reach production, and it has happened before. If management wants to know who did it, deploy 4812's record has the deployer's name, and the raw notes keep Bob's name. That conversation is separate from the postmortem.

**What I'd do**

1. **TodoWrite:** add the 7 checklist items.
2. **Save the input:** write `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-payment-timeout-config/notes.md` as an unedited copy of `incident-notes.md`.
3. **Set the timezone and write `timeline.md`:** the notes say US/Mountain. 2026-11-12 is after DST ended on Nov 1, so it's MST, UTC−7. The file starts with `Source TZ: US/Mountain (MST, UTC−7) — stated in notes`.

   | Time (UTC) | Event |
   |---|---|
   | 2026-11-12 20:58 | Deploy 4812 changes the payment-gateway timeout from 30s to 3s (`config/payments.yaml`), via the fast-path pipeline (skips integration tests) |
   | 21:02 | PagerDuty: checkout-api error rate > 5% |
   | 21:04 | On-call engineer sees 502s from checkout-api that start right after the deploy |
   | 21:06 | Deploy 4812's timeout change identified |
   | 21:09 | Noted: the config change was merged without review, and this has happened before |
   | 21:11 | Rollback of 4812 started |
   | 21:19 | Rollback complete; error rate < 0.5% |
   | 21:40 | Support has 37 tickets |

4. **Write `facts.md`** (each line cites a note timestamp):
   - **Duration:** 21m (20:58 to 21:19 UTC). Time to detect: 4m (20:58 to 21:02).
   - **Failed requests:** about 12% of checkout requests (14:25).
   - **Orders affected:** about 1,900; timed-out payments were not charged (14:25).
   - **Support tickets:** 37 (14:40).
   - **Revenue:** Unknown. Need finance or order data.
   - **SLO budget burned:** Unknown. Need the SLO dashboard.
   - **Severity:** not in the notes.
   - **Root cause:** a config change can reach production without required review or integration tests. The fast-path pipeline skips integration tests (14:31), review isn't enforced (14:09), and nothing validates the timeout value.
   - **Contributing factor:** skipping review is a known, repeated pattern ("again", 14:09) and nothing technical prevents it.
   - **What went well:** the alert fired 4 minutes after the deploy, the on-call engineer tied the errors to the deploy within 2 minutes, and the rollback took 8 minutes.
   - **Draft action items:**
     - Require approval for changes to `config/payments.yaml` (branch protection or CODEOWNERS). Type: prevent.
     - Run integration tests on the fast-path pipeline for payment config, or route payment config off the fast path. Type: prevent.
     - Add schema or range validation for gateway timeouts. Type: prevent.
     - Every item still needs an owner and a due date.
5. **STOP gate:** I'd send the reply below and wait.

**Reply**

> Draft facts and timeline are in `./.claude-skills-work/incident-postmortem/2026-11-12-checkout-payment-timeout-config/`. Before I write `postmortem.md`:
>
> 1. Severity level?
> 2. Revenue impact and SLO budget burned? Otherwise I'll mark them `Unknown`.
> 3. Owners and due dates for the three action items: config review enforcement, fast-path integration tests, and timeout validation.
> 4. Should the "again" pattern get its own item, such as an audit of unreviewed config pushes over the last N months?
>
> On Bob: the postmortem will say the change was "deployed without review via a pipeline that skips integration tests". It won't give a name. Naming the person makes people less candid in future incident reviews, and it hides the actual fix: the system let this happen more than once. If you'd rather I skip the questions, say "just write it" and I'll mark the gaps `TBD`.