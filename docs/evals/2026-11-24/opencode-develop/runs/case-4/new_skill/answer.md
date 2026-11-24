## Final reply
Done. `words.py` now raises `ValueError` for `n <= 0` and only appends `…` when words were actually cut; tests added for both review notes (verified failing first, then passing). `python3 -m unittest -q`: 3 passed, 0 failed. RESULT.md written at the worktree root.

## Tool calls, in order
1. skill
2. read /tmp/oceval-1795555629/new_skill/case-4/wt/words.py
3. read /tmp/oceval-1795555629/new_skill/case-4/wt/tests/test_words.py
4. shell `cd /tmp/oceval-1795555629/new_skill/case-4/wt && python3 -m unittest -q 2>&1 | tail -20 && git status --short && git log --oneline -3` → exit 0
```text
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
03f6697 fixture
```
5. edit /tmp/oceval-1795555629/new_skill/case-4/wt/tests/test_words.py
6. shell `cd /tmp/oceval-1795555629/new_skill/case-4/wt && python3 -m unittest -q 2>&1 | tail -20` → exit 0
```text
  File "/tmp/oceval-1795555629/new_skill/case-4/wt/tests/test_words.py", line 14, in test_nonpositive_n_raises
    with self.assertRaises(ValueError):
AssertionError: ValueError not raised

----------------------------------------------------------------------
Ran 3 tests in 0.000s

FAILED (failures=2)
```
7. edit /tmp/oceval-1795555629/new_skill/case-4/wt/words.py
8. shell `cd /tmp/oceval-1795555629/new_skill/case-4/wt && python3 -m unittest -q 2>&1 | tail -10; echo ---; git status --short; git diff` → exit 0
```text
+    if n <= 0:
+        raise ValueError("n must be positive")
     words = s.split()
-    return " ".join(words[:n]) + "…"
+    text = " ".join(words[:n])
+    if len(words) > n:
+        text += "…"
+    return text
```
9. write /tmp/oceval-1795555629/new_skill/case-4/wt/RESULT.md

## Files changed vs the fixture (git status)
```text
M RESULT.md
 M tests/test_words.py
 M words.py
```

## Diff (RESULT.md excluded)
```diff
diff --git a/tests/test_words.py b/tests/test_words.py
index 7566d6f..3fdbebb 100644
--- a/tests/test_words.py
+++ b/tests/test_words.py
@@ -6,3 +6,12 @@ from words import truncate_words
 class TruncateWordsTest(unittest.TestCase):
     def test_cuts(self):
         self.assertEqual(truncate_words("a b c", 2), "a b…")
+
+    def test_no_cut(self):
+        self.assertEqual(truncate_words("a b", 2), "a b")
+
+    def test_nonpositive_n_raises(self):
+        with self.assertRaises(ValueError):
+            truncate_words("a b", 0)
+        with self.assertRaises(ValueError):
+            truncate_words("a b", -1)
diff --git a/words.py b/words.py
index c470ea5..e815850 100644
--- a/words.py
+++ b/words.py
@@ -3,5 +3,10 @@
 
 def truncate_words(s, n):
     """Keep the first n words; add '…' when words were cut."""
+    if n <= 0:
+        raise ValueError("n must be positive")
     words = s.split()
-    return " ".join(words[:n]) + "…"
+    text = " ".join(words[:n])
+    if len(words) > n:
+        text += "…"
+    return text
```

## RESULT.md
---
id: T4
attempt: 2
status: done
---
## Changed
- words.py: `truncate_words` now raises ValueError for n <= 0 and appends '…' only when words were actually cut (fixes review note: `truncate_words("a b", 2)` returned `"a b…"`).
- tests/test_words.py: added `test_no_cut` (no ellipsis when nothing is cut) and `test_nonpositive_n_raises` (ValueError for n = 0 and n = -1), covering the review notes.

## Tests
command: `python3 -m unittest -q`
outcome: 3 passed, 0 failed
```text
----------------------------------------------------------------------
Ran 3 tests in 0.000s

OK
```

TDD followed: both new tests were written first and failed for the right reasons (`'a b…' != 'a b'`, `ValueError not raised`) before the implementation was changed; the baseline run before any change passed (1 test).

## Deviations
- none

## Questions
- none

## Independent rerun of `python3 -m unittest -q` by the eval harness after the run
```text
----------------------------------------------------------------------
Ran 3 tests in 0.000s

OK
EXIT=0
```
