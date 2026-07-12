# In-memory scoreboard with a per-season score cache.
_cache = {}


def _compute(player, season):
    # Pretend this is expensive.
    base = {"spring": 10, "summer": 20, "fall": 30}[season]
    return base + len(player)


def get_score(player, season):
    key = player
    if key in _cache:
        return _cache[key]
    score = _compute(player, season)
    _cache[key] = score
    return score
