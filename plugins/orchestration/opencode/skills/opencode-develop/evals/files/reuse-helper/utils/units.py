"""Unit conversions shared across the project."""

_SECONDS = {"s": 1, "m": 60, "h": 3600, "d": 86400}


def to_seconds(value, unit):
    """to_seconds(5, "m") -> 300. Raises ValueError for an unknown unit."""
    try:
        return value * _SECONDS[unit]
    except KeyError:
        raise ValueError(f"unknown unit: {unit!r}") from None
