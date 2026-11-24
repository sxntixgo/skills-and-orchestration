I fixed the bug and `python3 test_paginate.py` now prints `PASS`.

**Before:** the test failed with an `AssertionError` at `test_paginate.py:7`. With 30 items, `page(items, 1, 10)` returned 10..19, page 2 returned 20..29 and page 3 returned `[]`.

**Cause:** in `paginate.py:3`, `start = page_num * per_page` treats the page number as if pages started at 0. That pushes every page one page too far, so you never get the first ten items and the last page comes back empty. The page 3 result confirmed this before I changed anything.

**Fix:** a one-line change in `paginate.py`:
```python
start = (page_num - 1) * per_page
```

**Regression test:** the existing test now passes. I also added checks for both ends, since the bug lost the first page and emptied the last one: page 3 returns 20..29 and page 4 returns `[]`.

**Not changed:** `page_num <= 0` isn't rejected. Page 0 gives `items[-10:0]`, which is `[]`, and negative pages give odd negative slices. Adding a check for that would be a separate decision.