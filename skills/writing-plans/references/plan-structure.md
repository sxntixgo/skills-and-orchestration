# Anatomy of a good plan

A plan is executable by someone who wasn't in the conversation. Optimize for
that reader.

## Top of the plan
- **Goal** — one or two sentences: what changes and the observable "done".
- **Success criteria** — how anyone can tell it works (a behavior, a passing
  test, a metric).
- **Context/constraints** — the spec/design link, key files, and any hard
  constraints (stack, compatibility, deadlines).

## Phases
Order by dependency; each phase independently verifiable, ideally shippable.

```markdown
### Phase 1 — <smallest slice that delivers real behavior>
- [ ] Task: <what to change> in `<file/seam>`
      Verify: <test to write/run, or behavior to observe>
- [ ] Task: …
      Verify: …
Gate: <what to check / show the user before Phase 2>
```

## Task format (the core discipline)
Every task carries three things — if any is missing, it's not a task yet:
1. **What** — the specific change.
2. **Where** — the file(s) or seam it touches.
3. **How to verify** — a concrete check: "add a test asserting 409 on duplicate
   email", "curl the endpoint and see 201", "render the component and confirm
   the empty state". "It works" is not a verification.

Good vs weak:
| Weak | Good |
|------|------|
| "Improve error handling" | "In `handlers/user.py`, return 400 on missing email; verify with a test that posts `{}` and asserts 400" |
| "Add caching" | "Cache `getUser` results in-memory with a 60s TTL in `services/user.js`; verify a second call within 60s hits the cache (spy/assert one DB call)" |
| "Make it faster" | "Batch the N per-item queries into one `WHERE id IN (...)` in `repo.js`; verify with a test that asserts a single query for 10 items" |

## Gates
Between phases, insert a checkpoint: what to run/show and what decision it
unblocks. Gates are where the executor pauses for the user rather than plowing
ahead — especially before anything hard to reverse (migrations, deletes,
outward-facing changes).

## Risks, assumptions, out-of-scope
- **Risks** — what could go wrong and the mitigation (data loss, breaking
  callers, race conditions).
- **Assumptions** — what you're taking as given; flag any that, if wrong, change
  the plan.
- **Out of scope (YAGNI)** — list the tempting extras you deliberately did NOT
  plan (future features, generalizations). This is what keeps a plan small.
- **Open questions** — anything that needs an answer before/while executing.

## Sizing
Prefer more, smaller phases over a few big ones. A phase you can't verify in one
sitting is too big. If Phase 1 doesn't produce something observable, re-slice.
