The test now passes every time: 30 out of 30 runs in random order. The problem was a bug in `cart.py`, not in the test.

**What was failing:** 4 of 5 runs failed on `test_single_item_total` with `AssertionError: 9 != 2`. Run by itself, that test passed. It failed whenever it ran after `test_add_returns_the_items`. When I ran those two tests in that order, the module's cart still held `[('bag', 7), ('pen', 2)]` afterwards, so 7 + 2 = 9.

**Cause:** `add_item(name, price, items=_cart)` used one module-level list as its default. Every call that didn't pass a list added to that same list, so items from one test carried into the next. The test file shuffles the test order, which is why it only failed some of the time.

**Fix (`cart.py`):** the default is now `items=None`, and the function creates a new list on each call. I removed the unused `_cart` global. If you wanted one shared cart on purpose, that would need a different design, but none of your tests rely on it.

**Regression test (`test_cart.py`):** I added `test_default_cart_is_fresh_each_call`. It calls `add_item("bag", 7)` and then checks that `add_item("pen", 2)` returns only `[("pen", 2)]`. I didn't run this new test against the old code, but the old code gave exactly the leaked state it checks for.