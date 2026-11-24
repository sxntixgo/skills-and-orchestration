import unittest

from words import truncate_words


class TruncateWordsTest(unittest.TestCase):
    def test_cuts(self):
        self.assertEqual(truncate_words("a b c", 2), "a b…")
