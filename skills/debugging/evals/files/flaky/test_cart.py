import random
import unittest

from cart import add_item, total


class CartTest(unittest.TestCase):
    def test_add_returns_the_items(self):
        items = add_item("bag", 7)
        self.assertIn(("bag", 7), items)

    def test_single_item_total(self):
        items = add_item("pen", 2)
        self.assertEqual(total(items), 2)

    def test_two_items_total(self):
        items = add_item("book", 10, [])
        add_item("mug", 5, items)
        self.assertEqual(total(items), 15)


if __name__ == "__main__":
    # tests run in a random order, as with pytest-randomly in CI
    unittest.TestLoader.sortTestMethodsUsing = lambda _, a, b: random.choice([-1, 1])
    unittest.main()
