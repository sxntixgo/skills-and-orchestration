I fixed the bug and `python3 test_scores.py` now prints `PASS`.

**Cause:** `get_score` stored results in `_cache` under the player's name only (`key = player`) and ignored the season. So `get_score("ann", "spring")` saved `{"ann": 13}`, and the summer call returned that stored 13. The calculation itself was correct: with the cache cleared, `get_score("ann", "summer")` returns 23.

**Fix:** In `case-files/5/scores.py:12`, I changed the key to `key = (player, season)`.

**Regression test:** I added `test_cache_does_not_leak_across_seasons_or_players` to `test_scores.py`. It checks that the same player in different seasons, and different players in the same season, each get their own result, and that a repeated call still returns the right value. Both tests pass.

I saved notes on how I reproduced and confirmed the cause to `.claude-skills-work/debugging/score-cache-key/notes.md`.