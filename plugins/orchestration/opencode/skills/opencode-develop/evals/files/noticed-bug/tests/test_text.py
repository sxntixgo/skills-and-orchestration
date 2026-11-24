import unittest

from text import initials


class InitialsTest(unittest.TestCase):
    def test_two_words(self):
        self.assertEqual(initials("Ada Lovelace"), "AL")
