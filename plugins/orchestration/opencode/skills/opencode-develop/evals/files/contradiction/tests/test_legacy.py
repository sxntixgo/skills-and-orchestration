import unittest

from words import truncate_words


class LegacyTest(unittest.TestCase):
    """Owned by the export team: do not edit."""

    def test_short_text_keeps_ellipsis(self):
        self.assertEqual(truncate_words("a b", 2), "a b…")
