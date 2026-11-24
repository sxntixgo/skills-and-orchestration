"""Word helpers."""


def truncate_words(s, n):
    """Keep the first n words; add '…' when words were cut."""
    words = s.split()
    return " ".join(words[:n]) + "…"
