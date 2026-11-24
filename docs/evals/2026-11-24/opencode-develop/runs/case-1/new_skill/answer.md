## Final reply
Done. Added `slugify` to `text.py` (regex one-liner matching `title_case`'s style) and a `SlugifyTest` with the four required cases, written first and observed failing before implementation. `python3 -m unittest -q` → 2 passed, OK. Only the two listed files changed; RESULT.md written (`status: done`).

## Tool calls, in order
1. skill
2. read /tmp/oceval-1795555629/new_skill/case-1/wt/text.py
3. shell `ls -R /tmp/oceval-1795555629/new_skill/case-1/wt | head -50; cd /tmp/oceval-1795555629/new_skill/case-1/wt && python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text

/tmp/oceval-1795555629/new_skill/case-1/wt/tests:
__init__.py
test_text.py
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```
4. read /tmp/oceval-1795555629/new_skill/case-1/wt/tests/test_text.py
5. edit /tmp/oceval-1795555629/new_skill/case-1/wt/tests/test_text.py
6. shell `cd /tmp/oceval-1795555629/new_skill/case-1/wt && python3 -m unittest -q 2>&1 | tail -10` → exit 0
```text
    from text import slugify, title_case
ImportError: cannot import name 'slugify' from 'text' (/tmp/oceval-1795555629/new_skill/case-1/wt/text.py)


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
```
7. edit /tmp/oceval-1795555629/new_skill/case-1/wt/text.py
8. shell `cd /tmp/oceval-1795555629/new_skill/case-1/wt && python3 -m unittest -q 2>&1 | tail -8 && git status --short && git diff` → exit 0
```text
 def title_case(s):
     """'hello world' -> 'Hello World'."""
     return " ".join(w.capitalize() for w in s.split())
+
+
+def slugify(s):
+    """'Hello, World!' -> 'hello-world'."""
+    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
```
9. write /tmp/oceval-1795555629/new_skill/case-1/wt/RESULT.md

## Files changed vs the fixture (git status)
```text
M tests/test_text.py
 M text.py
?? RESULT.md
```

## Diff (RESULT.md excluded)
```diff
diff --git a/tests/test_text.py b/tests/test_text.py
index 3f2a3d3..4042883 100644
--- a/tests/test_text.py
+++ b/tests/test_text.py
@@ -1,6 +1,6 @@
 import unittest
 
-from text import title_case
+from text import slugify, title_case
 
 
 class TitleCaseTest(unittest.TestCase):
@@ -8,5 +8,13 @@ class TitleCaseTest(unittest.TestCase):
         self.assertEqual(title_case("hello world"), "Hello World")
 
 
+class SlugifyTest(unittest.TestCase):
+    def test_slugify(self):
+        self.assertEqual(slugify("Hello, World!"), "hello-world")
+        self.assertEqual(slugify("  a  b "), "a-b")
+        self.assertEqual(slugify("Already-slug"), "already-slug")
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
---
id: T1
attempt: 1
status: done
---
## Changed
- text.py: added `slugify(s)` (lowercase, runs of non-[a-z0-9] collapsed to one '-', stripped ends), styled after `title_case`; added `import re` for it.
- tests/test_text.py: added `SlugifyTest` covering the four required cases, matching existing test layout.

## Tests
command: `python3 -m unittest -q`
outcome: 2 passed, 0 failed
```text
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
```
TDD confirmed: before implementing, the new test failed with `ImportError: cannot import name 'slugify' from 'text'`; baseline run before any change was 1 passed, OK.

## Deviations
- none

## Questions
- none

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK
EXIT=0
```
