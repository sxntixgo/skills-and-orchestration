I'll build it, but I'm keeping the evals. Rule 8 in this repo says every skill ships `evals/evals.json` and a baseline comparison. That matters most for simple skills: `security-review` looked obviously useful and measured 0.00 lift, so it was folded into `code-review`. Generic changelog formatting is something the model already does well, so the evals are how we find out whether this skill adds anything.

**What I'd do, in order**

1. TodoWrite with 5 items: Clarify intent (gate), Frontmatter, Body, Scaffold + evals, Hand off.
2. Write `./.claude-skills-work/format-changelog/plan.md`. This is a draft, and I'm assuming every detail in it:

```markdown
# format-changelog — plan (Stage 1, awaiting approval)

## Trigger (draft)
Use when the user asks to write, add, format or normalize CHANGELOG entries
(e.g. from commits, PR titles, or a rough list) or to cut a release section.

## Scope
DOES: turn raw changes into entries in the project's changelog format;
group by type; place under Unreleased / a version heading; match existing style.
Does NOT: bump versions, tag, publish releases, edit code, or invent changes
not present in the input.

## Success criteria (observable)
- Entries land in the right section of CHANGELOG.md, matching existing format
- Each change classified (Added/Changed/Fixed/Removed/Security/Deprecated)
- No invented entries; ambiguous items flagged, not guessed
- Breaking changes called out explicitly

## Open questions
see reply

Status: STOP — awaiting user approval. Resume: answer questions, then Stage 2.
```

3. Stop here. I won't read the reference files or draft anything until you approve this, so there are no frontmatter, body or scaffold files yet.

**Reply to you**

> I wrote a draft plan to `./.claude-skills-work/format-changelog/plan.md`. Before I draft anything, I need answers to these:
>
> 1. **Format:** Keep a Changelog, Conventional Commits/semantic-release style, or your own house format?
> 2. **Input:** git log or commit range, PR titles, freeform notes, or a mix?
> 3. **Output:** edit `CHANGELOG.md` in place under `## [Unreleased]`, or just print the entries?
> 4. **Process:** what should the skill do that a plain "format these as a changelog" request gets wrong today? Some examples: dropping internal or chore commits, writing user-facing wording, linking PR or issue numbers, or flagging breaking changes. If nothing comes to mind, the skill may not earn its token cost, and the evals will show it.
>
> Once you approve the plan, I'll do the frontmatter, then the body, then scaffold with `scripts/new_skill.sh format-changelog` and write 3–5 eval cases. Then I'll hand it to `skill-reviewer` for the baseline comparison.