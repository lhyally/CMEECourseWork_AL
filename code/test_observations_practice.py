from observations_practice import load_observations, parse_count

assert parse_count("2") == 2
assert parse_count("0") == 0
assert parse_count("") is None

for bad_count in ["-1", "many", 2]:
    try: 
        parse_count(bad_count)
    except ValueError:
        pass
    else:
        raise AssertionError(f"Invalid count accepted: {bad_count!r}")