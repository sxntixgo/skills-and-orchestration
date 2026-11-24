The test is fixed: it now passes 50 out of 50 runs. Before the fix it failed 12 out of 20.

**Cause:** `cart.py` had `def add_item(name, price, items=_cart)`. That default is a single module-level list, so every call without a cart added to the same list. The test file runs tests in random order. When `test_add_returns_the_items` ran first, `test_single_item_total` saw both items in the cart and failed with `9 != 2`. In the other order, both tests passed. I confirmed this by running the two orders separately before changing anything.

**Fix:**
- **`cart.py`:** the default is now `items=None`, and the function creates a new list when no cart is passed. I removed `_cart`; nothing else used it.
- **`test_cart.py`:** added `test_default_carts_are_independent`. It checks that two calls without a cart don't share items, so this bug can't come back unnoticed.

I didn't make the test pass by changing its order or skipping it, because the bug was real. Any code that calls `add_item` without a cart was sharing one cart across calls.