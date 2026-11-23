I can't confirm it yet. `case-files/3/` contains only the new `SKILL.md`, so I have nothing to compare it against. The only change is the description, so "better" means "triggers more accurately", and that has to be measured. Below is what I'd do in the real session.

**1. Get the old version**
```
git log --oneline -3 -- skills/code-review/SKILL.md
git diff HEAD -- skills/code-review/SKILL.md      # if uncommitted; else HEAD~1..HEAD
```
- I'd confirm that only the `description:` line changed. If the body changed too, I'd also run an output A/B on 3–4 sample diffs.
- I'd copy both versions to `./.claude-skills-work/skill-reviewer/code-review/{old,new}/SKILL.md`.
- I'm assuming the old description was longer and listed more trigger phrases.

**2. Write `trigger-evals.json`** (20 queries, saved in the same folder)
- **Should trigger (10):** these include requests that never say "review":
  - "review this PR"
  - "can you look over my diff before I merge"
  - "sanity-check `src/cart.ts`"
  - "any feedback on this function?"
  - "is this change OK to ship?"
  - "check this refactor for bugs"
- **Should not trigger (10):** near-misses:
  - "security audit of the auth middleware"
  - "check this PR for secrets / injection"
  - "write tests for `parseDate`"
  - "refactor this file"
  - "fix these ESLint errors"
  - "explain what this code does"
  - "write a PR description"
  - "merge `main` into my branch"
  - "resolve this rebase conflict"

**3. Run both descriptions**
- I'd run each query 3 times per version. Each run is a fresh Agent subagent (`model: sonnet`, the model the skill targets) with only that version installed.
- I'd record whether the Skill tool fired: 20 × 3 × 2 = 120 runs.
- I'd log per-query trigger rates to `results.md`.

**4. Decide**
- The new version counts as better only if:
  - recall on should-trigger queries is ≥ old,
  - false triggers on should-not queries are ≤ old,
  - no single query flips from reliable (3/3) to unreliable.
- A difference of one or two queries is within run-to-run noise, not an improvement.

**Things I'd specifically check in the new description:**
- **Security reviews:** the body says this is "not a security audit", but the description doesn't. "Security-review this PR" will probably trigger it. Adding "Not for security audits" would fix that.
- **"Before merging a change":** this could fire on plain merge or rebase requests.
- **Dropped phrases:** if tightening removed casual phrasings like "look over" or "feedback on my code", recall on those queries will drop. The diff in step 1 will show this.

**Final reply (template):**
> Old vs new on 20 queries × 3 runs: should-trigger X/30 → Y/30, false triggers A/30 → B/30. Regressions: … New version is [better / no different / worse]. Suggested fix: …