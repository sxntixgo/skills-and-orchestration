**What I'd do, in order:**

1. **TodoWrite** these items: Understand context · Clarify intent · Explore approaches · Validate design in sections · Write design and hand off. Mark the first one in progress.

2. **Read the project before asking anything** (read-only):
   - `git log --oneline -15` and `git status`
   - `ls`, `README.md`, and `package.json` (or `pyproject.toml` / `go.mod`) to learn the stack
   - Search for existing pieces: `grep -ril "notif\|email\|mailer\|websocket\|push\|queue\|job" src/ app/`, plus the user model / DB schema

   *Assumed findings:* a web app with a TypeScript/Node backend, a React frontend and Postgres. There's a `User` table and an email library already used for password resets. There's no notification code, job queue or websocket. Nothing in `docs/plans/` covers notifications.

3. **Create the checkpoint file** `./.claude-skills-work/brainstorming/notifications/design.md`:
   ```markdown
   # Notifications — WIP design (brainstorming checkpoint)
   Status: step 2 (clarifying intent)

   ## Context (observed)
   - Stack: Node/TS backend, React frontend, Postgres
   - Existing: User table; email sending used for password resets
   - Not present: notification code, job queue, websockets/realtime

   ## Restated idea
   Add notifications so users find out about relevant events in the app.
   (Channel, triggers, audience: TBD)

   ## Open questions
   - [ ] Purpose: which events, and why users need to know
   - [ ] Channel(s): in-app / email / push
   - [ ] Success criteria (latency, read state, opt-out)
   - [ ] Constraints & scope (out-of-scope list)

   ## Decisions
   (none yet)
   ```

4. **Update TodoWrite:** "Understand context" done, "Clarify intent" in progress.

5. **Stop and wait for the user's answer.** I wouldn't propose approaches or a design in this turn. Later turns would go:
   - One question per turn: what triggers notifications → success criteria → constraints → what's out of scope.
   - Then 2–3 approaches with a recommendation, for example:
     - In-app table plus polling (simplest)
     - In-app plus email through a jobs table (durable, no new infrastructure)
     - Websockets or a third-party service like Knock or Novu (real-time, but more moving parts)
   - Then the design in sections (architecture, components, data flow, errors, testing), checking each one with the user.
   - Then write `docs/plans/2026-11-23-notifications-design.md` and hand off to `writing-plans`.

**Final reply to the user:**

> From the repo, this looks like a Node/TypeScript + React app on Postgres. You already send email for password resets, but there's no notification system, job queue or real-time channel yet. If I've got that right, the idea is: **let users know when something relevant happens in the app, without them having to go looking.** Correct me if I'm off.
>
> First question: **what's the main way users should get these notifications?**
> - **(a)** In-app only: a bell icon with an unread count and a list
> - **(b)** Email only
> - **(c)** In-app plus email (for example, email when something is important or the user hasn't seen it)
> - **(d)** Mobile or browser push as well
>
> My guess is **(a)** to start, with email added later if needed. Does that fit?