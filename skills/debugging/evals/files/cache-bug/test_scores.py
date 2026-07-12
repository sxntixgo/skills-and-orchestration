from scores import get_score


def test_scores_are_per_season():
    # ann in spring: base 10 + len("ann")=3 -> 13
    assert get_score("ann", "spring") == 13
    # ann in summer: base 20 + 3 -> 23  (currently returns the cached 13)
    assert get_score("ann", "summer") == 23


if __name__ == "__main__":
    test_scores_are_per_season()
    print("PASS")
