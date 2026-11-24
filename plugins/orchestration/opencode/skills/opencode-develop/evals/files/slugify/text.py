"""Small text helpers."""


def title_case(s):
    """'hello world' -> 'Hello World'."""
    return " ".join(w.capitalize() for w in s.split())
