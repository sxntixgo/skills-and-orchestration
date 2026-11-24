_cart = []


def add_item(name, price, items=_cart):
    items.append((name, price))
    return items


def total(items):
    return sum(price for _, price in items)
