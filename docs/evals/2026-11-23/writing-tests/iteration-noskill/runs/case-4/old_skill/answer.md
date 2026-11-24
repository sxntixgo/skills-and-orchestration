## What I'd do, in order

**1. Find the file and the test setup**
```bash
git ls-files | grep -iE '(^|/)utils?\.(py|ts|js)$'
ls pyproject.toml setup.cfg package.json 2>/dev/null
git ls-files | grep -iE 'test.*utils|utils.*test'
```
I'm assuming this finds one match, `src/app/utils.py`, in a pytest project with `pytest-cov` and an existing `tests/test_utils.py`. If it found several utils files, I'd stop and ask which one.

**2. Get the baseline**
```bash
pytest tests/test_utils.py --cov=app.utils --cov-branch --cov-report=term-missing -q
```
I'm assuming this reports 78% coverage. The missing lines are an error path in `parse_duration` (bad unit), the `None` / empty-string branches in `slugify`, and the `retries exhausted` raise in `retry()`.

**3. Read `src/app/utils.py` and the existing tests** so the new tests check real behaviour, not just that lines ran.

**4. Add tests to `tests/test_utils.py`**, assuming these signatures:
```python
import pytest
from app.utils import parse_duration, slugify, retry


@pytest.mark.parametrize("raw", ["10x", "", "abc"])
def test_parse_duration_rejects_bad_input(raw):
    with pytest.raises(ValueError, match="duration"):
        parse_duration(raw)


@pytest.mark.parametrize("raw,expected", [(None, ""), ("", ""), ("  --  ", "")])
def test_slugify_empty_inputs(raw, expected):
    assert slugify(raw) == expected


def test_retry_raises_after_exhausting_attempts():
    calls = []

    @retry(times=3, delay=0)
    def always_fails():
        calls.append(1)
        raise ConnectionError("down")

    with pytest.raises(ConnectionError):
        always_fails()
    assert len(calls) == 3


def test_retry_returns_on_eventual_success():
    attempts = iter([ConnectionError("x"), "ok"])

    @retry(times=3, delay=0)
    def flaky():
        r = next(attempts)
        if isinstance(r, Exception):
            raise r
        return r

    assert flaky() == "ok"
```

**5. Re-run coverage, then the full suite**
```bash
pytest tests/test_utils.py --cov=app.utils --cov-branch --cov-report=term-missing -q
pytest -q
```
I'd keep going until line and branch coverage both show 100% and the full suite passes.

**6. Rules I'd follow**
- I wouldn't use `# pragma: no cover`, delete code, or weaken assertions to reach the number.
- If a line truly can't be reached (dead code), I'd point it out and ask whether to remove it, not hide it.
- I wouldn't change `utils.py` itself. If a test exposes a bug, I'd report it and mark the test `xfail` with the reason, not quietly fix the code.
- I wouldn't commit unless asked.

## Final reply (assuming everything passes)

`app/utils.py` is now at 100% line and branch coverage (it was 78%). I added 4 tests in `tests/test_utils.py` that cover bad input to `parse_duration`, empty inputs to `slugify`, and both outcomes of `retry` (it gives up after the last attempt, or returns once a call succeeds). The full suite passes. I didn't change `utils.py`, didn't use any coverage exclusions, and haven't committed anything.