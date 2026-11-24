I'm not writing the plan yet. "A URL shortener" doesn't give me enough to plan from, and the skill says to stop and clarify rather than invent requirements. The four "maybe later" features also clash with the skill's YAGNI rule, so they need a decision from you first.

**What I'd do, in order:**
1. Add TodoWrite items for the skill's five steps: ground, decompose, detail, gates/risks, write and hand off.
2. Step 1: look for a spec or design doc and any existing code in the repo. The task names none, so I treat them as not found and plan as a new project.
3. Stop at the Step 1 gate and send the questions below. I would write nothing to `docs/plans/` until you answer, and I wouldn't load `references/plan-structure.md` until I reach Step 3.

**Reply:**

I need a few answers before I can write the plan:

1. **Core behaviour:** Do links use random short codes, custom aliases, or both? Can links expire or be deleted? Should redirects be 301 or 302?
2. **Users:** Is it anonymous, or do people need accounts to create links? If accounts, who can edit or delete a link?
3. **Scale and limits:** Roughly how many links and redirects per day? Do you need rate limiting or abuse and malware checks on target URLs?
4. **Stack and deployment:** Which language, framework and database? Where will it be hosted? Is there an existing repo I should build on?
5. **Success criteria:** What does "v1 done" look like? For example: "POST a URL, get a short link, and GET it redirects in under 50 ms."

On future-proofing: I won't build in support for analytics, teams, custom domains or billing. Speculative design adds cost now and usually guesses wrong about what the real feature will need. Instead, the plan will:
- List all four under **Out of scope (YAGNI)**.
- Keep v1 simple enough to extend: a single place where redirects are handled, so analytics can hook in later, and links stored behind a clean data-access layer.
- Point out any choice that would be expensive to undo later. The main one is whether a short code has to be unique globally or only within each domain.

If any of the four is actually likely in the next release, tell me and I'll plan it as a real phase.

Once you answer, I'll write `docs/plans/2026-11-23-url-shortener-plan.md`. It will be split into phases you can check one at a time, starting with the smallest working piece (create a link and redirect it). Each task will state what to change, where, and how to verify it, with review gates between phases. You can then build it phase by phase with `software-development`.