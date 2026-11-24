I fixed the bug and `python3 test_scores.py` now prints `PASS`. The score cache was keyed only by player name, so whatever season was looked up first got returned for every season.

**Before the fix:** running `python3 test_scores.py` raised `AssertionError` at `test_scores.py:8`, because `get_score("ann", "summer")` returned 13 instead of 23.

**Cause (confirmed):** in `scores.py:12`, `key = player` leaves out the season. After the spring call, `_cache` held `{'ann': 13}`, so the summer lookup returned that stored spring score. With the cache cleared, the same summer call returned 23, which shows the cache was the only problem.

**Fix:** one line in `scores.py:12`:
```python
key = (player, season)
```

**Regression test:** I added two assertions to `test_scores.py` that look up spring and summer again. This checks that each season's score still comes back correctly once it's stored in the cache.

**After the fix:** `python3 test_scores.py` prints `PASS`.

I logged the steps in `.claude-skills-work/debugging/score-cache-key/notes.md`.