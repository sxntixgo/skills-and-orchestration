from paginate import page


def test_pages_are_1_indexed():
    items = list(range(30))
    # Page 1 is the first ten items.
    assert page(items, 1, 10) == list(range(0, 10))
    # Page 2 is the next ten.
    assert page(items, 2, 10) == list(range(10, 20))


if __name__ == "__main__":
    test_pages_are_1_indexed()
    print("PASS")
