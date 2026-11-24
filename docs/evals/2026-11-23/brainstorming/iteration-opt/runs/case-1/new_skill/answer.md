**What I'd do, in order**

1. **TodoWrite** with the skill's steps: Context → Clarify intent → Choose approach → Design in sections → Write to `docs/plans/` and hand off to `writing-plans`.
2. **Context (read-only):** `git log --oneline -15`, then read `README.md`, the `package.json` or equivalent, `docs/`, and the user/auth models. *Assumption, since I can't see the project:* a web app with a Node/TypeScript backend, Postgres, a React frontend, user accounts, and no notification or email infrastructure yet.
3. **Create the work-in-progress file** `./.claude-skills-work/brainstorming/notifications/design.md`:
   ```markdown
   # Notifications — design (WIP)
   ## Assumptions
   - Web app: Node/TS backend, Postgres, React frontend, existing user accounts
   - No existing notification/email/push infrastructure
   ## Open questions
   - Purpose: which events trigger notifications, and who receives them?
   - Channels: in-app, email, push?
   - Success criteria: latency, delivery guarantees, read/unread state?
   - Scope: user preferences / opt-out in or out?
   ## Candidate approaches
   A. In-app only: notifications table + polling/fetch on page load
   B. In-app + email via a transactional provider, sent from a background job
   C. Real-time in-app (WebSocket/SSE) + email + push
   ## Current lean
   A, unless the triggering events need to reach users who aren't in the app (then B)
   ## Decisions
   (none yet)
   ```
4. No subagents and no code. This is a dialogue step.

**Reply to the user**

You want users of your app to be told when something relevant happens. I'm assuming it's a web app with user accounts, a Node/Postgres backend and a React frontend, and that you have no notification system yet. I don't know yet what problem the notifications solve: which events trigger them, who needs to see them, and how fast. That decides the design, so I'll pin it down before choosing anything.

Possible approaches:
- **A. In-app only:** a `notifications` table, a bell icon with unread count, fetched on page load or by light polling. Cheapest and easy to undo, with no new infrastructure. Users only see notifications when they open the app.
- **B. In-app + email:** A, plus emails sent from a background job through a transactional provider. Reaches users who aren't in the app. Adds a provider, a job queue, templates and unsubscribe handling.
- **C. Real-time in-app + email + push:** WebSocket/SSE, plus web or mobile push. Instant everywhere, but it's the most complex option: connection management, push tokens and more failure modes.

**My lean is A**, because it's the simplest thing that works and B can be added on top later without rework. That changes if the notifications must reach people who aren't currently in the app.

**One question:** what's the main thing a notification needs to do?
(a) Tell users about activity they'll see next time they open the app (e.g. "someone commented on your post")
(b) Pull users back to the app when something happens (e.g. "your order shipped", "you were invited")
(c) Alert users within seconds about something time-critical (e.g. a monitoring alert, a chat message)
(d) Something else (describe it)