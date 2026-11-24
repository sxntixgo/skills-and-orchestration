## Final reply
Done — status: **done**. Full details are in `RESULT.md` at the worktree root.

- `duration.py`: added `parse_duration(text)` -> int seconds. Regex parses `<digits><unit>`, then delegates the unit lookup to the existing `utils.units.to_seconds` (no duplicated s/m/h/d table). Invalid input raises `ValueError`: `""`/`"m"` fail the match, `"5x"` comes from `to_seconds`.
- `tests/test_duration.py` (new): 8 tests — 90s→90, 5m→300, 2h→7200, 1d→86400, int return type, and ValueError for `""`, `"5x"`, `"m"`.
- TDD: wrote the test first (red: `ImportError: cannot import name 'parse_duration'`), then implemented (green).

Verification (`Done when` command):
```
python3 -m unittest -q  → Ran 10 tests ... OK   (exit 0)
```
8 new + the 2 pre-existing `test_units.py` tests, untouched and still passing. No test was skipped, weakened or deleted.

Scope: only the two permitted paths changed (`M duration.py`, `?? tests/test_duration.py`); no commits/pushes/network/containers; `.git/` untouched.

Ambiguity notes (also listed in RESULT.md):
- One added guard — `isinstance(text, str)` — so "invalid input raises ValueError" also holds for non-string config values instead of leaking a `TypeError` from `re`. Happy to drop it if you prefer regex-only matching.
- Deliberately not implemented (out of scope): whitespace (`"90 s"`), fractional/negative values (`"1.5h"`, `"-5s"`) — all raise ValueError; no CLI or scheduler wiring.

One environment note: the requested `opencode-develop` skill wouldn't load (`Unable to load skill opencode-develop`; only `opencode` and `report` are available), so I followed its workflow manually — TDD plus RESULT.md at the worktree root.

## Tool calls, in order
1. shell `pwd && echo "---" && ls -la && echo "--- duration.py ---" && [ -f duration.py ] && cat duration.py; echo "--- tests dir ---"; ls -la tests 2>/dev/null` → exit 0
```text
--- duration.py ---
"""Parse human-readable durations."""
--- tests dir ---
total 12
drwxr-xr-x 2 vscode vscode 4096 Nov 24 21:27 .
drwxr-xr-x 5 vscode vscode 4096 Nov 24 21:28 ..
-rw-r--r-- 1 vscode vscode    0 Nov 24 16:59 __init__.py
-rw-r--r-- 1 vscode vscode  276 Nov 24 16:59 test_units.py
```
2. skill [error]
3. shell `cd /tmp/oceval-1795555629/old_skill/case-2/wt && echo "--- test_units.py ---" && cat tests/test_units.py && echo "--- utils ---" && ls -la utils && for f in utils/*; do echo "== $f =="; cat "$f"; done; echo "--- git status ---"; git status --short; echo "--- python ---"; python3 --version` → exit 0
```text
    """to_seconds(5, "m") -> 300. Raises ValueError for an unknown unit."""
    try:
        return value * _SECONDS[unit]
    except KeyError:
        raise ValueError(f"unknown unit: {unit!r}") from None
--- git status ---
--- python ---
Python 3.12.3
```
4. shell `cd /tmp/oceval-1795555629/old_skill/case-2/wt && python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
```
5. write /tmp/oceval-1795555629/old_skill/case-2/wt/tests/test_duration.py
6. shell `cd /tmp/oceval-1795555629/old_skill/case-2/wt && python3 -m unittest -q 2>&1 | tail -8` → exit 0
```text
    from duration import parse_duration
ImportError: cannot import name 'parse_duration' from 'duration' (/tmp/oceval-1795555629/old_skill/case-2/wt/duration.py)


----------------------------------------------------------------------
Ran 3 tests in 0.000s

FAILED (errors=1)
```
7. write /tmp/oceval-1795555629/old_skill/case-2/wt/duration.py
8. shell `cd /tmp/oceval-1795555629/old_skill/case-2/wt && python3 -m unittest -q; echo "EXIT=$?"` → exit 0
```text
----------------------------------------------------------------------
Ran 10 tests in 0.000s

OK
EXIT=0
```
9. shell `cd /tmp/oceval-1795555629/old_skill/case-2/wt && python3 -c "
from duration import parse_duration
for bad in ['', '5x', 'm', '5 s', '-5s', None, 90]:
    try:
        print(repr(bad), '->', parse_duration(bad))
    except ValueError as e:
        print(repr(bad), '-> ValueError:', e)
" && echo "--- git status ---" && git status --short && git diff --stat` → exit 0
```text
'-5s' -> ValueError: invalid duration: '-5s'
None -> ValueError: invalid duration: None
90 -> ValueError: invalid duration: 90
--- git status ---
 M duration.py
?? tests/test_duration.py
 duration.py | 14 ++++++++++++++
 1 file changed, 14 insertions(+)
```
10. write /tmp/oceval-1795555629/old_skill/case-2/wt/RESULT.md
11. shell `cd /tmp/oceval-1795555629/old_skill/case-2/wt && cat duration.py && echo "=== full run ===" && python3 -m unittest -q; echo EXIT=$?; git status --short` → exit 0
```text
----------------------------------------------------------------------
Ran 10 tests in 0.000s

OK
EXIT=0
 M duration.py
?? RESULT.md
?? tests/test_duration.py
```

## Files changed vs the fixture (git status)
```text
M duration.py
?? RESULT.md
?? tests/test_duration.py
```

## Diff (RESULT.md excluded)
```diff
diff --git a/duration.py b/duration.py
index 125ff95..4621168 100644
--- a/duration.py
+++ b/duration.py
@@ -1 +1,15 @@
 """Parse human-readable durations."""
+
+import re
+
+from utils.units import to_seconds
+
+_NUMBER_AND_UNIT = re.compile(r"(\d+)(\D+)")
+
+
+def parse_duration(text):
+    """parse_duration("90s") -> 90. Raises ValueError for invalid input."""
+    match = _NUMBER_AND_UNIT.fullmatch(text) if isinstance(text, str) else None
+    if match is None:
+        raise ValueError(f"invalid duration: {text!r}")
+    return to_seconds(int(match.group(1)), match.group(2))
diff --git a/tests/test_duration.py b/tests/test_duration.py
new file mode 100644
index 0000000..34a1ebb
--- /dev/null
+++ b/tests/test_duration.py
@@ -0,0 +1,36 @@
+import unittest
+
+from duration import parse_duration
+
+
+class ParseDurationTest(unittest.TestCase):
+    def test_seconds(self):
+        self.assertEqual(parse_duration("90s"), 90)
+
+    def test_minutes(self):
+        self.assertEqual(parse_duration("5m"), 300)
+
+    def test_hours(self):
+        self.assertEqual(parse_duration("2h"), 7200)
+
+    def test_days(self):
+        self.assertEqual(parse_duration("1d"), 86400)
+
+    def test_returns_int(self):
+        self.assertIsInstance(parse_duration("2h"), int)
+
+    def test_empty(self):
+        with self.assertRaises(ValueError):
+            parse_duration("")
+
+    def test_unknown_unit(self):
+        with self.assertRaises(ValueError):
+            parse_duration("5x")
+
+    def test_missing_number(self):
+        with self.assertRaises(ValueError):
+            parse_duration("m")
+
+
+if __name__ == "__main__":
+    unittest.main()
```

## RESULT.md
# RESULT — T2: add parse_duration(text) to duration.py

status: done

## What changed
- `duration.py` (modified): added `parse_duration(text)` -> int seconds.
  - Parses `<digits><unit>` with one regex, then delegates the unit lookup to the
    existing `utils.units.to_seconds`, so the s/m/h/d table stays in one place (DRY).
  - Invalid input raises `ValueError`: empty string / missing number (`""`, `"m"`) fail
    the pattern match; unknown units (`"5x"`) come from `to_seconds`.
- `tests/test_duration.py` (created): 8 tests — "90s"->90, "5m"->300, "2h"->7200,
  "1d"->86400, return type is int, and ValueError for `""`, `"5x"`, `"m"`.

## TDD trace
1. Wrote `tests/test_duration.py` first -> red: `ImportError: cannot import name 'parse_duration'` (FAILED errors=1).
2. Implemented `parse_duration` -> green.

## Verification (exact "Done when" command)
```
$ python3 -m unittest -q
Ran 10 tests in 0.000s
OK            # exit 0  (8 new + 2 pre-existing test_units.py, untouched and still passing)
```
Extra manual spot-checks: `""`, `"5x"`, `"m"`, `"5 s"`, `"-5s"`, `None`, `90` all raise ValueError.

## Scope / files touched
Only the two permitted paths (`git status`: `M duration.py`, `?? tests/test_duration.py`).
No other files, no `.git/`, no commits/pushes/network/containers. No tests were skipped,
weakened or deleted.

## Notes / decisions on ambiguity
- Reused `utils.units.to_seconds` rather than duplicating a unit->seconds map; unknown-unit
  message is therefore `"unknown unit: 'x'"`, still a ValueError as required.
- One added guard (`isinstance(text, str)`) so the documented "invalid input raises ValueError"
  contract holds for non-string config values instead of leaking TypeError from `re`. Say the word
  if you'd rather have strictly regex-only matching (TypeError on non-str).
- Out of scope and deliberately not implemented: whitespace tolerance (`"90 s"`), fractional or
  negative durations (`"1.5h"`, `"-5s"`) — all raise ValueError; no CLI, scheduler wiring or docs added.

## Skill note
The requested `opencode-develop` skill could not be loaded in this environment
(`Unable to load skill opencode-develop`; available: `opencode`, `report`). I followed the stated
workflow manually (TDD + this RESULT.md at the worktree root).

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 10 tests in 0.000s

OK
EXIT=0
```
