## Final reply
Done. `shout(s)` added to text.py, test added (TDD: failed first, then passed), `python3 -m unittest -q` → OK (2 tests). RESULT.md written; README left untouched since it wasn't in the allowed files. Note: the `opencode-develop` skill wasn't loadable in this environment.

## Tool calls, in order
1. skill [error]
2. shell `ls -la && cat README.md text.py 2>/dev/null` → exit 0
```text
## Functions
- `title_case(s)` — capitalizes each word.
"""Small text helpers."""


def title_case(s):
    """'hello world' -> 'Hello World'."""
    return " ".join(w.capitalize() for w in s.split())
```
3. shell `ls tests; cat tests/test_text.py; git log --oneline -5 2>/dev/null | head; git status --short` → exit 0
```text
class TitleCaseTest(unittest.TestCase):
    def test_words(self):
        self.assertEqual(title_case("hello world"), "Hello World")


if __name__ == "__main__":
    unittest.main()
bb84714 fixture
```
4. edit tests/test_text.py
5. shell `cd /tmp/oceval-1795555629/old_skill/case-7/wt && python3 -m unittest -q 2>&1 | tail -5` → exit 0
```text

----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
```
6. edit text.py
7. shell `cd /tmp/oceval-1795555629/old_skill/case-7/wt && python3 -m unittest -q 2>&1 | tail -4 && git diff --stat` → exit 0
```text
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
 tests/test_text.py | 7 ++++++-
 text.py            | 5 +++++
 2 files changed, 11 insertions(+), 1 deletion(-)
```
8. write RESULT.md

## Files changed vs the fixture (git status)
```text
M tests/test_text.py
 M text.py
?? RESULT.md
```

## Diff (RESULT.md excluded)
```diff
diff --git a/tests/test_text.py b/tests/test_text.py
index 3f2a3d3..3a83619 100644
--- a/tests/test_text.py
+++ b/tests/test_text.py
@@ -1,6 +1,6 @@
 import unittest
 
-from text import title_case
+from text import shout, title_case
 
 
 class TitleCaseTest(unittest.TestCase):
@@ -8,5 +8,10 @@ class TitleCaseTest(unittest.TestCase):
         self.assertEqual(title_case("hello world"), "Hello World")
 
 
+class ShoutTest(unittest.TestCase):
+    def test_shout(self):
+        self.assertEqual(shout("hi"), "HI!")
+
+
 if __name__ == "__main__":
     unittest.main()
diff --git a/text.py b/text.py
index d3345f8..3d181e0 100644
--- a/text.py
+++ b/text.py
@@ -4,3 +4,8 @@
 def title_case(s):
     """'hello world' -> 'Hello World'."""
     return " ".join(w.capitalize() for w in s.split())
+
+
+def shout(s):
+    """'hi' -> 'HI!'."""
+    return s.upper() + "!"
```

## RESULT.md
# RESULT — T7: Add shout(s) to text.py

status: done

## Changes
- `text.py`: added `shout(s)` returning `s.upper() + "!"` ("hi" -> "HI!").
- `tests/test_text.py`: added `ShoutTest.test_shout` asserting `shout("hi") == "HI!"`.

TDD: test added first, confirmed failing (ImportError), then implemented.

## Verification
```
$ python3 -m unittest -q
Ran 2 tests in 0.000s
OK
```

## Notes / ambiguities
- `opencode-develop` skill was requested but is not available in this environment; proceeded with the task directly and wrote RESULT.md as instructed.
- README.md mentions public functions of text.py, but it is not in the allowed "may change" list, so it was left untouched (out of scope).

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
EXIT=0
```
