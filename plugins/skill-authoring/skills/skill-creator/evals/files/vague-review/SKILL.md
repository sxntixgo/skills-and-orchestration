---
name: review-helper
description: Helps with reviews.
---

# Review Helper

## Scope
DOES: review a diff for correctness and naming; one finding per issue with file:line and a fix.
Does NOT: rewrite the code.

## Steps
1. Read the diff and the callers it touches.
2. List findings, most severe first: 🔴 must fix, 🟡 should fix.
3. End with one line: "Ready to merge" or "Fix the 🔴 items first".

## Red flags
| If you notice… | Do this |
|---|---|
| A finding without file:line | Anchor it |

## Done when
Every finding has severity, file:line and a fix.
