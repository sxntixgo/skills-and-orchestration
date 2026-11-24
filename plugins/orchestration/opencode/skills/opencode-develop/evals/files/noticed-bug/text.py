"""Small text helpers."""


def initials(name):
    """'Ada Lovelace' -> 'AL'."""
    return "".join(w[0].upper() for w in name.split(" "))
