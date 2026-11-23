I'll build it, but I won't skip the evals: the skill-creator skill requires them (rule 8, and "skipping evals because it obviously works" is listed as a red flag). They're only 3–5 short cases. The skill also has a mandatory stop at Stage 1, so I'm asking a few questions before drafting anything.

**What I'd do, in order**

1. **TodoWrite:** add 5 items: Stage 1 Clarify intent (⛔ gate), Stage 2 Frontmatter, Stage 3 Body, Stage 4 Scaffold + evals, Stage 5 Hand off. Mark Stage 1 in progress.
2. **Write `./.claude-skills-work/format-changelog/plan.md`** (working name `format-changelog`). I'd assume Keep a Changelog style, but I'd mark it as unconfirmed:
   ```markdown
   # format-changelog — plan (Stage 1, AWAITING APPROVAL)

   ## Trigger (draft)
   Use when the user asks to write, add, or tidy a CHANGELOG entry, or to turn
   commits/PR titles into release notes for a version.

   ## Scope (draft)
   DOES: format given changes into a changelog entry; categorize them; place the
   entry in CHANGELOG.md under the right version/date heading.
   DOES NOT: pick the version number, tag releases, publish, or edit code.
   (Open questions below may change this.)

   ## Success criteria (draft)
   - Entry follows the agreed format (headings, categories, bullet style).
   - Every input change appears exactly once, in the right category.
   - Existing CHANGELOG.md content is untouched apart from the new entry.

   ## Open questions
   1-5 (see reply to user)

   ## Note
   User asked to skip evals; declined per rule 8. 3–5 cases will be scaffolded in Stage 4.
   ```
3. **Stop.** I wouldn't read the reference files, draft frontmatter or body, or run `scripts/new_skill.sh` until you approve the plan. The references are loaded at Stages 2–4.

**Reply to the user**

> I'm not skipping the evals: the authoring rules require them (rule 8). It's only 3–5 short realistic cases in `evals/evals.json`, and `skill-reviewer` needs them to check that the skill does better than no skill. A simple skill also means simple evals.
>
> Before I draft anything I need the requirements, so I'm not inventing them. Draft plan: `./.claude-skills-work/format-changelog/plan.md`.
>
> 1. **Format:** Keep a Changelog (`## [1.2.0] - 2026-11-23` with Added/Changed/Fixed/Removed/Deprecated/Security), Conventional Commits-style, or your repo's own convention? If it's your own, can you point me to an example?
> 2. **Input:** what does it start from? Commits since the last tag, PR titles, a list you paste in, or a rough draft entry to clean up?
> 3. **Output:** should it edit `CHANGELOG.md` in place (new entry at the top, under `[Unreleased]`?), or just print the entry?
> 4. **Versioning:** should it ever choose or bump the version number, or always take it from you or leave it as `Unreleased`?
> 5. **Style rules:** any wording rules, such as imperative vs. past tense, PR/issue links, author credits, or a line-length limit?
>
> Once you answer or approve the plan, I'll do the frontmatter, then the body, then scaffold the skill and its evals, and finally hand off to `skill-reviewer`.