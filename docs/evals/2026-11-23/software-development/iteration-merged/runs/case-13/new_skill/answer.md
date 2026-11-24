**Assumptions:** the repo has a single `src/app/utils.py` (Python, pytest + pytest-cov). It holds `slugify(text)`, `parse_iso_date(s)` (raises `ValueError` on bad input), `chunk(items, size)` (raises `ValueError` when size ≤ 0) and `safe_divide(a, b)` (returns `None` when b == 0). There are existing tests in `tests/test_utils.py`. There's no plan or phase involved, so I'd skip Stage 0. This is the "only adding tests" path.

## What I'd do, in order

**1. TodoWrite:** Understand → List cases → Write tests → Run → Report. Notes go in `./.claude-skills-work/software-development/utils-coverage/notes.md`.

**2. Understand.** I'd read `src/app/utils.py` and `tests/test_utils.py`, then get a baseline:
```
pytest --cov=app.utils --cov-branch --cov-report=term-missing tests/test_utils.py
```
I'd assume it reports about 70%, with these gaps: `parse_iso_date`'s error branch, `chunk`'s size ≤ 0 guard and `safe_divide`'s zero branch.

**3. List the cases first** (logged to notes.md). I'd pick them by behaviour and risk, not by the line numbers coverage reports:
- `slugify`: basic, empty string, unicode (`"Café Ünï"` → `"cafe-uni"`), repeated separators and leading/trailing ones.
- `parse_iso_date`: valid date, with offset, empty string, garbage, `None`. Each error case checks for `ValueError`.
- `chunk`: empty list, one item, exact multiple, remainder, size 0 and −1 (raise), size larger than the list.
- `safe_divide`: normal, b = 0 → `None`, negative values, 0/x.

**4. Write the tests** by appending to `tests/test_utils.py`:
```python
import pytest
from app.utils import slugify, parse_iso_date, chunk, safe_divide

@pytest.mark.parametrize("raw,expected", [
    ("Hello World", "hello-world"), ("", ""), ("Café Ünï", "cafe-uni"),
    ("  a--b  ", "a-b"),
])
def test_slugify_normalises_to_lowercase_hyphenated_ascii(raw, expected):
    assert slugify(raw) == expected

def test_parse_iso_date_keeps_utc_offset():
    assert parse_iso_date("2026-01-02T03:04:05+02:00").utcoffset().total_seconds() == 7200

@pytest.mark.parametrize("bad", ["", "not-a-date", "2026-13-01", None])
def test_parse_iso_date_rejects_invalid_input(bad):
    with pytest.raises(ValueError):
        parse_iso_date(bad)

@pytest.mark.parametrize("items,size,expected", [
    ([], 2, []), ([1], 2, [[1]]), ([1, 2, 3, 4], 2, [[1, 2], [3, 4]]),
    ([1, 2, 3], 2, [[1, 2], [3]]), ([1, 2], 5, [[1, 2]]),
])
def test_chunk_splits_into_groups_of_size(items, size, expected):
    assert chunk(items, size) == expected

@pytest.mark.parametrize("size", [0, -1])
def test_chunk_rejects_non_positive_size(size):
    with pytest.raises(ValueError):
        chunk([1, 2], size)

def test_safe_divide_returns_none_when_divisor_is_zero():
    assert safe_divide(5, 0) is None

@pytest.mark.parametrize("a,b,expected", [(6, 3, 2), (-6, 3, -2), (0, 4, 0)])
def test_safe_divide_divides(a, b, expected):
    assert safe_divide(a, b) == expected
```

**5. Run and check that the tests can fail.** I'd run the same pytest/coverage command. Then I'd briefly break the `size <= 0` guard and the zero check to confirm the matching tests go red, and revert both changes. After that I'd run the full suite plus the repo's lint and typecheck (`ruff check`, `mypy`), and call each function once in a Python shell to see the real output.

**6. Report.** No `git commit` unless you ask.

## Final reply

> I added 22 test cases to `tests/test_utils.py`. Coverage of `app/utils.py` went from about 70% to 100% (line and branch). Every untested failure mode is now covered: bad and empty dates, a chunk size of 0 or less, and division by zero. I also covered boundary and unicode inputs.
>
> 100% wasn't really the target. I chose tests for behaviour and risk, and the number followed because the file is small. I wouldn't add a coverage gate on it.
>
> To check the tests actually catch bugs, I broke the chunk-size guard and the zero check one at a time, and the matching tests failed. The full suite, `ruff` and `mypy` all pass. Nothing is committed.

This is a dry run, so the numbers and file contents above are assumed, not observed.