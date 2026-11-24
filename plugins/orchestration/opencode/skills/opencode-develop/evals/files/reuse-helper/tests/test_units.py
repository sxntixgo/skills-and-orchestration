import unittest

from utils.units import to_seconds


class ToSecondsTest(unittest.TestCase):
    def test_minutes(self):
        self.assertEqual(to_seconds(5, "m"), 300)

    def test_unknown(self):
        with self.assertRaises(ValueError):
            to_seconds(1, "x")
