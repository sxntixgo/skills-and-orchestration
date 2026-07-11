# Code review checklist (per dimension)

Language-agnostic. Apply what fits the change; prioritize correctness.

## Correctness (highest priority)
- Does it actually do what the change claims / the ticket asks?
- Edge cases: empty, null/undefined, zero, negative, single element, max, very
  large, unicode.
- Off-by-one in loops, slices, ranges, pagination.
- Error/exception paths: are failures handled, or do they crash / corrupt state?
- Concurrency: shared mutable state, races, non-atomic read-modify-write.
- Resource cleanup: files, connections, locks, listeners released on all paths.
- Return values and types match what callers expect.

## Naming & readability
- Names reveal intent. Flag `data`, `info`, `tmp`, `obj`, `handle`, `process`,
  `do`, and single letters outside tiny scopes.
- Booleans read as predicates (`isActive`, `hasAccess`).
- No misleading names (a `getX` that also mutates).
- Comments explain WHY, not WHAT; delete commented-out code.

## Function & complexity
```
// 🔴 deep nesting
if (a) { if (b) { if (c) { do() } } }
// ✅ guard clauses
if (!a) return; if (!b) return; if (!c) return; do();
```
- One job per function; extract when it grows past a screenful or mixes levels
  of abstraction.
- High cyclomatic complexity (many branches) → split or table-drive.

## Error handling
```
// 🔴 silent swallow
try { risky() } catch (e) {}
// ✅ handle or propagate with context
try { risky() } catch (e) { throw new Error(`loading config: ${e.message}`) }
```
- No empty catches; no catching everything and continuing blindly.
- Error messages are actionable and include context (ids, not secrets).
- The unhappy path returns/roll-backs cleanly.

## Duplication & simplicity
- **DRY**: the same *knowledge* encoded in 3+ places → extract. But don't merge
  code that merely looks alike yet changes for different reasons.
- **YAGNI**: unused params, dead branches, config no one reads, "flexible"
  abstractions with one caller → remove.
- **KISS**: prefer the straightforward solution; flag cleverness that costs
  readability for no measurable gain.

## Consistency
- Matches the module's existing patterns: structure, naming, error format,
  imports, framework idioms. A change that invents a new pattern for no reason
  adds cost.

## Tests (adequacy, not authoring)
- New/changed behavior has tests, including at least one edge and one error case.
- Tests assert behavior, not implementation details.
- No obviously flaky constructs (real time/network/order dependence).

## Prioritize
Correctness bugs > missing error handling > design/duplication > naming >
style. Don't let a pile of 🟢 nits bury a single 🔴.
