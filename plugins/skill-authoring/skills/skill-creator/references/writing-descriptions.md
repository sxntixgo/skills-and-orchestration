# Writing the skill description (Stage 2)

The `description` is the ONLY text Claude sees when deciding whether to load a
skill. If the trigger is vague, the skill either never fires or fires wrongly.
This is the highest-leverage sentence in the whole skill.

## Format

```
<what it does>. Use when <concrete trigger>.
```

- **Third person**, present tense ("Reviews code…", not "I will review…" or
  "You should…").
- **What it does** first: a plain statement of the capability.
- **Use when** clause: the concrete situation, phrased the way it actually
  shows up — user requests, file types, error symptoms, keywords.

## Good vs weak

| Weak | Why it fails | Better |
|------|--------------|--------|
| "Helps with testing." | No trigger; too broad. | "Designs and writes test cases for a change. Use when adding tests, or before implementing a feature/bugfix." |
| "A skill for code." | Says nothing. | "Reviews a diff for correctness and quality. Use when finishing a change or before merging." |
| "Security stuff." | Vague; won't match. | "Reviews code for security vulnerabilities (injection, authz, secrets). Use when a change touches auth, input handling, or external I/O." |

## Checklist
- [ ] Starts with what it does, in third person.
- [ ] Has a concrete "Use when …" trigger.
- [ ] Names the real signals (requests, file types, symptoms, keywords) that
      should fire it.
- [ ] Distinct from sibling skills — no overlapping triggers.
- [ ] Would a fresh Claude, seeing only this line, know when to reach for it?

## Test the trigger
Sanity-check the description against the skill's eval prompts (Stage 4): each
`prompt` in `evals.json` should plausibly cause *this* description to fire and
not a sibling skill's. If a prompt wouldn't trigger it, the trigger is too
narrow or mis-worded.
