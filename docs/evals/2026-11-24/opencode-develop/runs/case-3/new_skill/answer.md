## Final reply
Done. `word_count` added to words.py (`len(s.split())`, text.py docstring style), 4 tests in new tests/test_words.py (TDD: failed with ImportError first, then passed). Suite: **5 passed, OK**. RESULT.md written at worktree root; only the listed files changed.

## Tool calls, in order
1. skill
2. shell `ls -la && find . -name '*.py' -not -path './.git/*' | head -50` → exit 0
```text
drwxr-xr-x 7 vscode vscode 4096 Nov 24 21:29 .git
drwxr-xr-x 2 vscode vscode 4096 Nov 24 21:27 tests
-rw-r--r-- 1 vscode vscode  140 Nov 24 16:59 text.py
-rw-r--r-- 1 vscode vscode   20 Nov 24 16:59 words.py
./tests/__init__.py
./tests/test_text.py
./words.py
./text.py
```
3. read /tmp/oceval-1795555629/new_skill/case-3/wt/text.py
4. read /tmp/oceval-1795555629/new_skill/case-3/wt/words.py
5. read /tmp/oceval-1795555629/new_skill/case-3/wt/tests/test_text.py
6. shell `cd /tmp/oceval-1795555629/new_skill/case-3/wt && python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```
7. write /tmp/oceval-1795555629/new_skill/case-3/wt/tests/test_words.py
8. shell `cd /tmp/oceval-1795555629/new_skill/case-3/wt && python3 -m unittest -q 2>&1 | tail -8` → exit 0
```text
    from words import word_count
ImportError: cannot import name 'word_count' from 'words' (/tmp/oceval-1795555629/new_skill/case-3/wt/words.py)


----------------------------------------------------------------------
Ran 2 tests in 0.000s

FAILED (errors=1)
```
9. edit /tmp/oceval-1795555629/new_skill/case-3/wt/words.py
10. shell `cd /tmp/oceval-1795555629/new_skill/case-3/wt && python3 -m unittest -q 2>&1 | tail -8` → exit 0
```text
----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK
```
11. shell `cd /tmp/oceval-1795555629/new_skill/case-3/wt && git status --short && echo --- && git diff` → exit 0
```text
+++ b/words.py
@@ -1 +1,6 @@
 """Word helpers."""
+
+
+def word_count(s):
+    """'  a  b ' -> 2."""
+    return len(s.split())
```
12. shell `cd /tmp/oceval-1795555629/new_skill/case-3/wt && python3 -m unittest -q 2>&1` → exit 0
```text
----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK
```
13. write /tmp/oceval-1795555629/new_skill/case-3/wt/RESULT.md

## Files changed vs the fixture (git status)
```text
M words.py
?? RESULT.md
?? tests/test_words.py
```

## Diff (RESULT.md excluded)
```diff
diff --git a/tests/test_words.py b/tests/test_words.py
new file mode 100644
index 0000000..74ae699
--- /dev/null
+++ b/tests/test_words.py
@@ -0,0 +1,17 @@
+import unittest
+
+from words import word_count
+
+
+class WordCountTest(unittest.TestCase):
+    def test_empty(self):
+        self.assertEqual(word_count(""), 0)
+
+    def test_extra_whitespace(self):
+        self.assertEqual(word_count("  a  b "), 2)
+
+    def test_one_word(self):
+        self.assertEqual(word_count("one"), 1)
+
+    def test_any_whitespace(self):
+        self.assertEqual(word_count("a\tb\nc  d"), 4)
diff --git a/words.py b/words.py
index 7654142..cdf54ce 100644
--- a/words.py
+++ b/words.py
@@ -1 +1,6 @@
 """Word helpers."""
+
+
+def word_count(s):
+    """'  a  b ' -> 2."""
+    return len(s.split())
```

## RESULT.md
---
id: T3
attempt: 1
status: done
---
## Changed
- words.py: added `word_count(s)` returning `len(s.split())` (splits on any whitespace), docstring in text.py's example style.
- tests/test_words.py: new; `WordCountTest` with the three spec cases (`"" -> 0`, `"  a  b " -> 2`, `"one" -> 1`) plus one mixed-whitespace case, mirroring tests/test_text.py layout.

## Tests
command: `python3 -m unittest -q`
outcome: 5 passed, 0 failed
```text
----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK
```

TDD sequence observed: before implementing, the new test failed with `ImportError: cannot import name 'word_count' from 'words'`; after implementing, full suite (1 pre-existing + 4 new) passed.

## Deviations
- none (`tests/__init__.py` already existed; not created or modified)

## Questions
- none

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK
EXIT=0
```
