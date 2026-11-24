Plan: build `parse_date` for one format only, ISO 8601 `YYYY-MM-DD`, using TDD. I won't add the configurable/extensible part now (YAGNI); one line in the final reply says why.

**Assumptions:** a Python project using pytest, with the code in `src/dates.py` and tests in `tests/test_dates.py`. The input is an ISO date string like `"2026-11-23"`. Bad input raises `ValueError`.

### 1. TodoWrite
- Understand
- Plan the slice
- TDD loop
- DRY/YAGNI/KISS
- Run it

### 2. Notes: `./.claude-skills-work/software-development/parse-date/notes.md`
```
Done = parse_date("YYYY-MM-DD") -> datetime.date; invalid/empty/None -> ValueError.
Assumption: ISO 8601 calendar date is the only format in use today.
YAGNI: no format registry/config until a second real format exists.
Slice: src/dates.py + tests/test_dates.py.
```

### 3. Red: write `tests/test_dates.py` first
```python
import pytest
from datetime import date
from src.dates import parse_date

def test_parses_iso_date():
    assert parse_date("2026-11-23") == date(2026, 11, 23)

def test_strips_surrounding_whitespace():
    assert parse_date(" 2026-11-23 ") == date(2026, 11, 23)

@pytest.mark.parametrize("bad", ["", "   ", "2026-13-01", "2026-02-30", "23/11/2026", "2026-11-23T10:00"])
def test_rejects_invalid(bad):
    with pytest.raises(ValueError):
        parse_date(bad)

def test_rejects_none():
    with pytest.raises(ValueError):
        parse_date(None)

def test_boundaries():
    assert parse_date("2024-02-29") == date(2024, 2, 29)   # leap day
    assert parse_date("0001-01-01") == date.min
    assert parse_date("9999-12-31") == date.max
```
Run `pytest tests/test_dates.py`. It should fail with `ImportError` because `parse_date` doesn't exist yet, which is the right reason.

### 4. Green: write `src/dates.py`
```python
from datetime import date, datetime

ISO_DATE = "%Y-%m-%d"

def parse_date(value: str) -> date:
    """Parse an ISO 8601 calendar date (YYYY-MM-DD)."""
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"Expected a date string, got {value!r}")
    return datetime.strptime(value.strip(), ISO_DATE).date()
```
I'm using `strptime` instead of `date.fromisoformat`. On Python 3.11+, `fromisoformat` also accepts `20261123` and `2026-W47-1`, which would break the strict-format contract. Run `pytest tests/test_dates.py` and expect all tests to pass.

### 5. Refactor / DRY / YAGNI / KISS
One function and no config, registry or strategy classes, so there's nothing to remove. Rerun the tests: still green.

### 6. Run it
- `pytest`: the full suite.
- `python -c "from src.dates import parse_date; print(parse_date('2026-11-23')); parse_date('23/11/2026')"`: should print `2026-11-23`, then raise `ValueError: time data '23/11/2026' does not match format '%Y-%m-%d'`.
- Write what I ran and what it printed to `notes.md`.

### Final reply to user
> I added `parse_date(value) -> date` in `src/dates.py`. It parses ISO 8601 dates (`YYYY-MM-DD`). Empty, `None`, malformed or impossible dates (e.g. `2026-02-30`) raise `ValueError`.
>
> Tests are in `tests/test_dates.py`: the happy path, whitespace, invalid inputs, `None`, a leap day and the min/max dates. All pass, and I ran the function by hand: `'2026-11-23'` returns `date(2026, 11, 23)`, and `'23/11/2026'` raises `ValueError`.
>
> I assumed ISO is the only format you need today. I didn't build a configurable format system (YAGNI): with only one real format, we'd be guessing what "extensible" means. When a second format comes up, I can add a `formats=` parameter tried in order, or a small list of formats, based on that real case. If you already have another format in use, tell me which one.