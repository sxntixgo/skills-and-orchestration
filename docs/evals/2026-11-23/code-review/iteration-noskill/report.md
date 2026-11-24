# code-review — eval 2026-11-23

new = working tree (0f6b1d6+worktree), baseline = no skill; model opus; `claude -p --safe-mode`, dry runs, blind judge.

| Case | new | baseline |
|---|:---:|:---:|
| 1 | 2/4 | 2/4 |
| 2 | 3/3 | 3/3 |
| 3 | 3/3 | 2/3 |
| 4 | 3/3 | 1/3 |

| | pass rate | assertions | tokens (mean) | time s (mean) |
|---|:---:|:---:|:---:|:---:|
| new | 0.875 | 11/13 | 15545.0 | 16.482 |
| baseline | 0.625 | 8/13 | 6667.25 | 8.433 |
| **delta** | **+0.25** | | +8877.75 | +8.049 |

Failed assertions:

- case 1 new: Flags the missing bound check on discount (e.g. >1 or <0 produces a wrong/negative total) as the top correctness issue — The bound check is flagged as Must fix #2: "with `discount > 1` the total goes negative... With `discount < 0` it raises the price." However, #1 (the NaN regression) is ranked above it, so it is not the top issue.
- case 1 new: Findings are anchored to specific lines and each has a concrete fix — Most findings cite a line, e.g. "(src/cart.js:3)", and give a fix. But #5 "No tests for the new behaviour" has no line anchor, and all line numbers rest on an assumed file path.
- case 1 baseline: Flags the missing bound check on discount (e.g. >1 or <0 produces a wrong/negative total) as the top correctness issue — The bound check is flagged as Blocking item 2 ('A negative discount raises the price. A discount above 1 gives a negative total'). Item 1, the NaN from a missing argument, is ranked above it, so it is not the top issue.
- case 1 baseline: Does not rewrite the entire change; suggests rather than replaces — It ends with 'Suggested version:', a complete replacement of the function that adds a JSDoc, renames the parameter, adds validation and rounds the result. That rewrites the whole change.
- case 3 baseline: Identifies the silent exception swallow (bare except: pass) as a Must-fix, not a style nit — The answer rejects the code ("No, this isn't okay") and lists the issue under "Problems", but it never labels it Must-fix or blocking. No explicit severity is given.
- case 4 baseline: Notes that indentation/formatting is handled by Prettier/lint and does not spend the review on it — It devotes a full section to formatting ('Indentation: the file uses 4 spaces but the config says 2'; quote fix on orders.js:5) rather than deferring it to tooling. Only afterwards does it say 'npx prettier --write orders.js fixes both issues.'
- case 4 baseline: Still addresses genuine naming/readability issues with line references — It gives naming suggestions ('`proc` → `getPaidTotalForCustomer`', '`d` → `orders`'), but none have line references. Line refs appear only for the quote issue (:5) and the bug (:4).
