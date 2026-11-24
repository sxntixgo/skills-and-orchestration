## Final reply
Done. `duration.py` now has `parse_duration(text)` reusing the existing `utils.units.to_seconds` helper; tests added in `tests/test_duration.py`.

- TDD: stub → `FAILED (errors=7)` (NotImplementedError) → implementation → `python3 -m unittest -q` → **Ran 9 tests … OK**
- Diff limited to the two listed files (plus RESULT.md). No commits.

## Tool calls, in order
1. skill
2. shell `pwd && ls -la && cat duration.py 2>/dev/null; echo "---"; ls tests 2>/dev/null` → exit 0
```text
drwxr-xr-x 7 vscode vscode 4096 Nov 24 21:28 .git
-rw-r--r-- 1 vscode vscode   38 Nov 24 16:59 duration.py
drwxr-xr-x 2 vscode vscode 4096 Nov 24 21:27 tests
drwxr-xr-x 2 vscode vscode 4096 Nov 24 21:27 utils
"""Parse human-readable durations."""
---
__init__.py
test_units.py
```
3. shell `cd /tmp/oceval-1795555629/new_skill/case-2/wt && cat tests/__init__.py; echo "==="; cat tests/test_units.py; echo "==="; ls utils; echo "==="; cat duration.py; echo "==="; python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text
units.py
===
"""Parse human-readable durations."""
===
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
```
4. shell `cd /tmp/oceval-1795555629/new_skill/case-2/wt && cat utils/units.py; echo "==="; cat utils/__init__.py` → exit 0
```text

def to_seconds(value, unit):
    """to_seconds(5, "m") -> 300. Raises ValueError for an unknown unit."""
    try:
        return value * _SECONDS[unit]
    except KeyError:
        raise ValueError(f"unknown unit: {unit!r}") from None
===
```
5. write /tmp/oceval-1795555629/new_skill/case-2/wt/tests/test_duration.py
6. edit /tmp/oceval-1795555629/new_skill/case-2/wt/duration.py
7. read /tmp/oceval-1795555629/new_skill/case-2/wt/duration.py
8. shell `cd /tmp/oceval-1795555629/new_skill/case-2/wt && python3 -m unittest -q 2>&1 | tail -15` → exit 0
```text
  File "/tmp/oceval-1795555629/new_skill/case-2/wt/duration.py", line 5, in parse_duration
    raise NotImplementedError
NotImplementedError

----------------------------------------------------------------------
Ran 9 tests in 0.001s

FAILED (errors=7)
```
9. write /tmp/oceval-1795555629/new_skill/case-2/wt/duration.py
10. read /tmp/oceval-1795555629/new_skill/case-2/wt/duration.py
11. shell `cd /tmp/oceval-1795555629/new_skill/case-2/wt && python3 -m unittest -q 2>&1 | tail -8; echo "=== test file ==="; cat tests/test_duration.py; echo "=== git status/diff ==="; git status --short; git diff` → exit 0
```text
+
+
+def parse_duration(text):
+    """parse_duration("5m") -> 300. Raises ValueError for invalid input."""
+    match = _PATTERN.match(text)
+    if not match:
+        raise ValueError(f"invalid duration: {text!r}")
+    return to_seconds(int(match.group(1)), match.group(2))
```
12. shell `cd /tmp/oceval-1795555629/new_skill/case-2/wt && python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text
----------------------------------------------------------------------
Ran 9 tests in 0.000s

OK
```
13. write /tmp/oceval-1795555629/new_skill/case-2/wt/RESULT.md

## Files changed vs the fixture (git status)
```text
M duration.py
?? RESULT.md
?? tests/test_duration.py
```

## Diff (RESULT.md excluded)
```diff
diff --git a/duration.py b/duration.py
index 125ff95..a031626 100644
--- a/duration.py
+++ b/duration.py
@@ -1 +1,15 @@
 """Parse human-readable durations."""
+
+import re
+
+from utils.units import to_seconds
+
+_PATTERN = re.compile(r"^(\d+)([smhd])$")
+
+
+def parse_duration(text):
+    """parse_duration("5m") -> 300. Raises ValueError for invalid input."""
+    match = _PATTERN.match(text)
+    if not match:
+        raise ValueError(f"invalid duration: {text!r}")
+    return to_seconds(int(match.group(1)), match.group(2))
diff --git a/tests/test_duration.py b/tests/test_duration.py
new file mode 100644
index 0000000..04852f5
--- /dev/null
+++ b/tests/test_duration.py
@@ -0,0 +1,33 @@
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
---
id: T2
attempt: 1
status: done
---
## Changed
- duration.py: added `parse_duration(text)` — matches `^(\d+)([smhd])$` and converts via the existing `utils.units.to_seconds`; raises ValueError for anything else ("" , "5x", "m").
- tests/test_duration.py: new unittest module covering 90s/5m/2h/1d and the three invalid inputs, following the style of tests/test_units.py.

## Tests
command: `python3 -m unittest -q`
outcome: 9 passed, 0 failed (7 from tests/test_duration.py, 2 pre-existing in tests/test_units.py)

TDD sequence: stub raising NotImplementedError first, run showed `FAILED (errors=7)` with
NotImplementedError tracebacks; then implemented and reran.

```text
----------------------------------------------------------------------
Ran 9 tests in 0.000s

OK
```

## Deviations
- none

## Questions
- None blocking. Left alone on purpose: only non-negative integers are accepted (e.g. "1h30m",
  "90 s", "1.5h" raise ValueError) since the task lists no such formats; `parse_duration` requires
  a str (non-str input raises TypeError from `re.match`, not ValueError).

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 9 tests in 0.000s

OK
EXIT=0
```
