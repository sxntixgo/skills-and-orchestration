## Final reply
Done. Summary:

- **calc.py**: added `sub(a, b) -> a - b` mirroring `add()`.
- **tests/test_calc.py**: added `test_sub` (`sub(5, 3) == 2`) alongside `test_add`, same style.
- **TDD**: baseline `1 passed` → red with test only (`ImportError: cannot import name 'sub'`) → green `2 passed`.
- **Test command nuance**: bare `python3 -m pytest -q` can't find pytest in this image (it lives in the `/usr/local/py-utils` venv); ran the exact command with a `PYTHONPATH` bridge and also the environment's own `pytest -q` — both give `2 passed`. Documented in RESULT.md for reproduction.
- Self-check: diff touches only the two listed files; nothing committed. Report at worktree root `RESULT.md` (status: done).

## Tool calls, in order
1. skill [error]
2. glob **/SKILL.md
3. shell `ls -la /tmp/oceval-1795555629/old_skill/case-5/wt; find / -name "*opencode-develop*" 2>/dev/null | head` → exit 0
```text
/opt/skills/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/iteration-opt/snap/old_skill/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/iteration-opt/snap/new_skill/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/vs-claudemd/snap/old_skill/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/vs-claudemd/snap/new_skill/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/vs-anthropic/snap/old_skill/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/vs-anthropic/snap/new_skill/plugins/orchestration/opencode/skills/opencode-develop
/opt/skills/.claude-skills-work/evals/skill-reviewer/iteration-2026-11-23/snap/old_skill/plugins/orchestration/opencode/skills/opencode-develop
```
4. shell `cat ~/.config/opencode/skills/opencode-develop/SKILL.md 2>/dev/null || ls -R ~/.config/opencode/skills/opencode-develop` → exit 0
```text
- Blocked: say what you tried and the exact error.

## Don't
- Edit files outside the list, add dependencies the task doesn't name, or "fix" other things
  you notice (mention them under Questions instead).
- Change a test so it passes instead of fixing the code.
- Commit (not even RESULT.md), push, or switch branches. Use the network only when a task step
  needs it (e.g. `npm install`).
```
5. shell `ls tests && cat tests/*.py; git status --short; git branch --show-current`
6. read /tmp/oceval-1795555629/old_skill/case-5/wt/calc.py
7. read /tmp/oceval-1795555629/old_skill/case-5/wt/tests
8. read /tmp/oceval-1795555629/old_skill/case-5/wt/tests/test_calc.py
9. shell `python3 -m pytest -q` → exit 1
```text
/usr/local/python/current/bin/python3: No module named pytest
```
10. shell `which -a python3 pytest; ls /usr/local/bin | head -50` → exit 0
```text
gitk
opencode
opencode-1.19.6
scalar
starship
systemctl
uv
uvx
```
11. shell `head -1 /usr/local/py-utils/bin/pytest; echo "$PATH"; python3 -m pip --version 2>&1 | head -1` → exit 0
```text
#!/usr/local/py-utils/venvs/pytest/bin/python
~/.local/bin:/usr/local/python/current/bin:/usr/local/py-utils/bin:/usr/local/jupyter:/usr/local/share/nvm/current/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
pip 24.0 from /usr/lib/python3/dist-packages/pip (python 3.12)
```
12. shell `ls /usr/local/py-utils/venvs/pytest/lib; cat /usr/local/py-utils/venvs/pytest/pyvenv.cfg 2>/dev/null; python3 -V; /usr/bin/python3 -V; PYTHONPATH=/usr/local/py-utils/venvs/pytest/lib/python3.12/site-packages python3 -m pytest -q` → exit 0
```text
include-system-site-packages = true
version = 3.12.3
executable = /usr/bin/python3.12
command = /usr/bin/python3 -m venv --without-pip --system-site-packages /usr/local/py-utils/venvs/pytest
Python 3.12.3
Python 3.12.3
.                                                                        [100%]
1 passed in 0.00s
```
13. edit /tmp/oceval-1795555629/old_skill/case-5/wt/tests/test_calc.py
14. shell `PYTHONPATH=/usr/local/py-utils/venvs/pytest/lib/python3.12/site-packages python3 -m pytest -q 2>&1 | tail -8` → exit 0
```text
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests/test_calc.py:1: in <module>
    from calc import add, sub
E   ImportError: cannot import name 'sub' from 'calc' (/tmp/oceval-1795555629/old_skill/case-5/wt/calc.py)
=========================== short test summary info ============================
ERROR tests/test_calc.py
!!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!
1 error in 0.03s
```
15. edit /tmp/oceval-1795555629/old_skill/case-5/wt/calc.py
16. shell `PYTHONPATH=/usr/local/py-utils/venvs/pytest/lib/python3.12/site-packages python3 -m pytest -q 2>&1 | tail -5` → exit 0
```text
..                                                                       [100%]
2 passed in 0.00s
```
17. shell `pytest -q 2>&1 | tail -3` → exit 0
```text
..                                                                       [100%]
2 passed in 0.00s
```
18. shell `git --no-pager diff` → exit 0
```text
 
 
 def test_add():
     assert add(2, 3) == 5
+
+
+def test_sub():
+    assert sub(5, 3) == 2
```
19. shell `git status --short` → exit 0
```text
 M calc.py
 M tests/test_calc.py
```
20. write /tmp/oceval-1795555629/old_skill/case-5/wt/RESULT.md

## Files changed vs the fixture (git status)
```text
M calc.py
 M tests/test_calc.py
?? RESULT.md
```

## Diff (RESULT.md excluded)
```diff
diff --git a/calc.py b/calc.py
index 03afa4f..5773038 100644
--- a/calc.py
+++ b/calc.py
@@ -3,3 +3,7 @@
 
 def add(a, b):
     return a + b
+
+
+def sub(a, b):
+    return a - b
diff --git a/tests/test_calc.py b/tests/test_calc.py
index d509f32..da23aeb 100644
--- a/tests/test_calc.py
+++ b/tests/test_calc.py
@@ -1,5 +1,9 @@
-from calc import add
+from calc import add, sub
 
 
 def test_add():
     assert add(2, 3) == 5
+
+
+def test_sub():
+    assert sub(5, 3) == 2
```

## RESULT.md
---
id: T5
attempt: 1
status: done
---
## Changed
- calc.py: added `sub(a, b)` returning `a - b`, same style as `add()`.
- tests/test_calc.py: extended import to `from calc import add, sub`; added `test_sub` asserting `sub(5, 3) == 2`, mirroring `test_add`.

## Tests
command: `PYTHONPATH=/usr/local/py-utils/venvs/pytest/lib/python3.12/site-packages python3 -m pytest -q`
outcome: 2 passed, 0 failed
```text
..                                                                       [100%]
2 passed in 0.00s
```

Also confirmed with the image's own runner on PATH: `pytest -q` → `2 passed in 0.00s`.

TDD sequence: baseline before changes was `1 passed`; after adding only the test it failed for exactly the right reason (`ImportError: cannot import name 'sub' from 'calc'`); after implementing `sub()` both tests pass.

## Deviations
- The bare command `python3 -m pytest -q` fails in this image with `No module named pytest`: the default interpreter `/usr/local/python/current/bin/python3` has no pytest, and the devcontainer installs it into an isolated venv (`/usr/local/py-utils/venvs/pytest`, Python 3.12.3 — same version as python3). I ran the exact task command with only `PYTHONPATH=/usr/local/py-utils/venvs/pytest/lib/python3.12/site-packages` set (no files, network, or installs involved) plus plain `pytest -q`; both pass. To rerun: use that PYTHONPATH prefix, or `/usr/local/py-utils/bin/pytest -q`.

## Questions
- none

## Independent rerun of `python3 -m pytest -q` by the eval harness after the run
```text
/usr/local/python/current/bin/python3: No module named pytest
EXIT=1
```
