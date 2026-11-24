I won't skip the evals. Rule 8 requires `evals/evals.json` for every skill, and a short skill still needs evidence that it beats having no skill. I'll keep the evals small: 3 cases. Before drafting anything I need you to answer a few questions.

**What I'd do in the session:**

1. Create TodoWrite items for the 5 stages: Clarify intent (gate), Frontmatter, Body, Scaffold + evals, Hand off to `skill-reviewer`.
2. Write a provisional Stage 1 plan to `./.claude-skills-work/changelog-format/plan.md` (no other files yet):

```markdown
# changelog-format — Stage 1 (awaiting approval)

## Trigger (provisional)
Use when the user asks to add, write, or tidy entries in a CHANGELOG file.

## Scope
DOES: format new or existing entries to the project's changelog convention
(sections, version/date header, entry wording, ordering).
Does NOT: pick version numbers, generate entries from git history,
cut releases, tag, or push.

## Success criteria (observable)
- Entries land under the correct `## [Unreleased]` / version section.
- Each entry sits under the correct change-type heading.
- Wording follows the convention (imperative/past tense, one line, PR/issue ref).
- Existing entries are left untouched unless the user asks.

## Open questions (blocking)
1. Convention: Keep a Changelog, Conventional Commits-style, or a house format?
2. Input: raw notes from the user, commit messages, or a PR description?
3. Scope: format only, or also insert into CHANGELOG.md?
4. Location: `skills/` (frugal-skills) or its own plugin?

## Evals (rule 8, not optional)
3 cases planned for Stage 4: messy notes → correct sections; an entry
in the wrong section; a request outside scope ("bump version") → declined.

Status: STOP — waiting for user approval.
```

3. Stop and reply.

**Reply to you:**

> I won't skip the evals. Every skill in this repo needs them (rule 8), and `skill-reviewer` needs them to show the skill does better than no skill. For a simple skill I'll write 3 short cases, so it costs little. The draft plan is in `.claude-skills-work/changelog-format/plan.md`. Please answer these four questions before I draft anything:
> 1. Which convention should entries follow: Keep a Changelog, Conventional Commits-style, or your own format? If it's your own, please paste an example.
> 2. What will you give the skill to work from: raw notes, commit messages, or PR descriptions?
> 3. Should the skill only format entries, or also insert them into `CHANGELOG.md`?
> 4. Where should it live: `skills/` (frugal-skills) or a separate plugin?
>
> One more thing to consider: frontier models already know Keep a Changelog well. A skill that only restates that format may measure close to 0 benefit, as `security-review` did. The skill is worth more if it enforces your house rules or a fixed process (for example, never editing released sections).