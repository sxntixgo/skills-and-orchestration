import unittest

from text import title_case


class TitleCaseTest(unittest.TestCase):
    def test_words(self):
        self.assertEqual(title_case("hello world"), "Hello World")


if __name__ == "__main__":
    unittest.main()
