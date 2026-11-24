## Final reply
Done. `slugify` added to text.py (`re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")`) plus 4 tests; wrote the test first (failed on ImportError), then implemented.

`python3 -m unittest -q` → Ran 5 tests, OK (exit 0). Report in RESULT.md.

## Tool calls, in order
1. skill [error]
2. shell `ls -la; echo ---; cat text.py 2>/dev/null; echo ---; ls tests; echo ---; cat tests/test_text.py 2>/dev/null` → exit 0
```text

class TitleCaseTest(unittest.TestCase):
    def test_words(self):
        self.assertEqual(title_case("hello world"), "Hello World")


if __name__ == "__main__":
    unittest.main()
```
3. edit tests/test_text.py
4. shell `cat tests/test_text.py; echo ---; python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text
    from text import slugify, title_case
ImportError: cannot import name 'slugify' from 'text' (/tmp/oceval-1795555629/old_skill/case-1/wt/text.py)


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
```
5. edit text.py
6. shell `python3 -m unittest -q; echo "exit=$?"; git diff --stat` → exit 0
```text
----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK
exit=0
 tests/test_text.py | 16 +++++++++++++++-
 text.py            |  7 +++++++
 2 files changed, 22 insertions(+), 1 deletion(-)
```
7. write RESULT.md

## Files changed vs the fixture (git status)
```text
M tests/test_text.py
 M text.py
?? RESULT.md
```

## Diff (RESULT.md excluded)
```diff
diff --git a/tests/test_text.py b/tests/test_text.py
index 3f2a3d3..e807ffb 100644
--- a/tests/test_text.py
+++ b/tests/test_text.py
@@ -1,6 +1,6 @@
 import unittest
 
-from text import title_case
+from text import slugify, title_case
 
 
 class TitleCaseTest(unittest.TestCase):
@@ -8,5 +8,19 @@ class TitleCaseTest(unittest.TestCase):
         self.assertEqual(title_case("hello world"), "Hello World")
 
 
+class SlugifyTest(unittest.TestCase):
+    def test_basic(self):
+        self.assertEqual(slugify("Hello, World!"), "hello-world")
+
+    def test_extra_whitespace(self):
+        self.assertEqual(slugify("  a  b "), "a-b")
+
+    def test_existing_dash(self):
+        self.assertEqual(slugify("Already-slug"), "already-slug")
+
+    def test_empty(self):
+        self.assertEqual(slugify(""), "")
+
+
 if __name__ == "__main__":
     unittest.main()
diff --git a/text.py b/text.py
index d3345f8..2725155 100644
--- a/text.py
+++ b/text.py
@@ -1,6 +1,13 @@
 """Small text helpers."""
 
+import re
+
 
 def title_case(s):
     """'hello world' -> 'Hello World'."""
     return " ".join(w.capitalize() for w in s.split())
+
+
+def slugify(s):
+    """'Hello, World!' -> 'hello-world'."""
+    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
```

## RESULT.md
# T1: Add slugify(s) to text.py

status: done

## Changes
- `text.py`: added `slugify(s)` in the style of `title_case` (docstring shows an example), plus a top-level `import re`. Implementation: lowercase, collapse every run of non `[a-z0-9]` characters into one `-`, then strip leading/trailing `-`.
- `tests/test_text.py`: added `SlugifyTest` covering the four required cases: `"Hello, World!" -> "hello-world"`, `"  a  b " -> "a-b"`, `"Already-slug" -> "already-slug"`, `"" -> ""`.

TDD order: tests were added first and failed with `ImportError: cannot import name 'slugify'`; implementation then made them pass.

## Verification
```
$ python3 -m unittest -q
Ran 5 tests in 0.000s
OK
exit=0
```

Only the two listed files were modified (`git diff --stat`: text.py +7, tests/test_text.py +16/-1). Nothing committed; no other files touched.

## Notes / assumptions
- `re` is imported at module top (after the docstring), which is the conventional placement rather than inside the function; `title_case` needed no imports so there was no in-file precedent to copy.
- Since `-` is itself "not a-z or 0-9", existing dashes are treated as separators and collapse with adjacent ones (e.g. `"a--b"` -> `"a-b"`), matching the stated rule literally.

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK
EXIT=0
```
